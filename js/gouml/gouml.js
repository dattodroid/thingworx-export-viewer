/* Copyright 1998-2018 by Northwoods Software Corporation. */

function initUML(div_name) {
  var $ = go.GraphObject.make;

  myDiagram =
    $(go.Diagram, div_name,
      {
        initialContentAlignment: go.Spot.Center,
        "undoManager.isEnabled": false,
        "animationManager.isEnabled": false,
        layout: $(go.TreeLayout,
                  { // this only lays out in trees nodes connected by "generalization" links
                    angle: 90,
                    path: go.TreeLayout.PathSource,  // links go from child to parent
                    setsPortSpot: false,  // keep Spot.AllSides for link connection spot
                    setsChildPortSpot: false,  // keep Spot.AllSides
                    // nodes not connected by "generalization" links are laid out horizontally
                    arrangement: go.TreeLayout.ArrangementHorizontal
                  })
      });

  // show visibility or access as a single character at the beginning of each property or method
  function convertVisibility(v) {
    switch (v) {
      case "public": return "+";
      case "private": return "-";
      case "protected": return "#";
      case "package": return "~";
      default: return v;
    }
  }

    // the item template for properties
    var propertyTemplate =
      $(go.Panel, "Horizontal",
        // property visibility/access
        $(go.TextBlock,
          { isMultiline: false, editable: false, width: 12 },
          new go.Binding("text", "visibility", convertVisibility)),
        // property name, underlined if scope=="class" to indicate static property
        $(go.TextBlock,
          { isMultiline: false, editable: true },
          new go.Binding("text", "name"),
          new go.Binding("isUnderline", "scope", function(s) { return s[0] === 'c' })),
        // property type, if known
        $(go.TextBlock, "",
          new go.Binding("text", "type", function(t) { return (t ? ": " : ""); })),
        $(go.TextBlock,
          { isMultiline: false, editable: true },
          new go.Binding("text", "type")),
        // property default value, if any
        $(go.TextBlock,
          { isMultiline: false, editable: false },
          new go.Binding("text", "default", function(s) { return s ? " = " + s : ""; }))
      );

    // the item template for methods
    var methodTemplate =
      $(go.Panel, "Horizontal",
        // method visibility/access
        $(go.TextBlock,
          { isMultiline: false, editable: false, width: 12 },
          new go.Binding("text", "visibility", convertVisibility)),
        // method name, underlined if scope=="class" to indicate static method
        $(go.TextBlock,
          { isMultiline: false, editable: true },
          new go.Binding("text", "name"),
          new go.Binding("isUnderline", "scope", function(s) { return s[0] === 'c' })),
        // method parameters
        $(go.TextBlock, "()",
          // this does not permit adding/editing/removing of parameters via inplace edits
          new go.Binding("text", "parameters"))
      );

  // this simple template does not have any buttons to permit adding or
  // removing properties or methods, but it could!
  myDiagram.nodeTemplate =
    $(go.Node, "Auto",
      {
        locationSpot: go.Spot.Center,
        fromSpot: go.Spot.AllSides,
        toSpot: go.Spot.AllSides
      },
      $(go.Shape, { fill: "lightyellow" }),
      $(go.Panel, "Table",
        { defaultRowSeparatorStroke: "black" },
        // header
        $(go.TextBlock,
          {
            row: 0, columnSpan: 2, margin: 3, alignment: go.Spot.Center,
            font: "12pt sans-serif",
            isMultiline: false, editable: false
          },
          new go.Binding("text", "name"),
          new go.Binding("isUnderline", "type", function(s) { return s === 'Thing' }),
          new go.Binding("font", "type", function(s) { return (s === 'ThingShape') ? "Italic 12pt sans-serif" : "12pt sans-serif" })),
        // properties
        $(go.TextBlock, "Properties",
          { row: 1, font: "italic 10pt sans-serif" },
          new go.Binding("visible", "visible", function(v) { return !v; }).ofObject("PROPERTIES")),
        $(go.Panel, "Vertical", { name: "PROPERTIES" },
          new go.Binding("itemArray", "properties"),
          {
            row: 1, margin: 3, stretch: go.GraphObject.Fill,
            defaultAlignment: go.Spot.Left, background: "lightyellow",
            itemTemplate: propertyTemplate
          }
        ),
        // methods
        $(go.TextBlock, "Methods",
          { row: 2, font: "italic 10pt sans-serif" },
          new go.Binding("visible", "visible", function(v) { return !v; }).ofObject("METHODS")),
        $(go.Panel, "Vertical", { name: "METHODS" },
          new go.Binding("itemArray", "methods"),
          {
            row: 2, margin: 3, stretch: go.GraphObject.Fill,
            defaultAlignment: go.Spot.Left, background: "lightyellow",
            itemTemplate: methodTemplate
          }
        ),
        // Events
        $(go.TextBlock, "Events",
          { row: 2, font: "italic 10pt sans-serif" },
          new go.Binding("visible", "visible", function(v) { return !v; }).ofObject("EVENTS")),
        $(go.Panel, "Vertical", { name: "EVENTS" },
          new go.Binding("itemArray", "events"),
          {
            row: 2, margin: 3, stretch: go.GraphObject.Fill,
            defaultAlignment: go.Spot.Left, background: "lightyellow",
            itemTemplate: propertyTemplate
          }
        ),
        // Subscriptions
        $(go.TextBlock, "Subscriptions",
          { row: 2, font: "italic 10pt sans-serif" },
          new go.Binding("visible", "visible", function(v) { return !v; }).ofObject("SUBSCRIPTIONS")),
        $(go.Panel, "Vertical", { name: "SUBSCRIPTIONS" },
          new go.Binding("itemArray", "subscriptions"),
          {
            row: 2, margin: 3, stretch: go.GraphObject.Fill,
            defaultAlignment: go.Spot.Left, background: "lightyellow",
            itemTemplate: methodTemplate
          }
        ),
      )
    );

  function convertIsTreeLink(r) {
    return r === "generalization";
  }

  function convertFromArrow(r) {
    switch (r) {
      case "generalization": return "";
      default: return "";
    }
  }

  function convertToArrow(r) {
    switch (r) {
      case "generalization": return "Triangle";
      case "aggregation": return "StretchedDiamond";
      default: return "";
    }
  }

  myDiagram.linkTemplate =
    $(go.Link,
      { routing: go.Link.Orthogonal },
      new go.Binding("isLayoutPositioned", "relationship", convertIsTreeLink),
      $(go.Shape),
      $(go.Shape, { scale: 1.3, fill: "white" },
        new go.Binding("fromArrow", "relationship", convertFromArrow)),
      $(go.Shape, { scale: 1.3, fill: "white" },
        new go.Binding("toArrow", "relationship", convertToArrow))
    );

  return myDiagram;
}

function buildModel(nodedata, linkdata) {
  var $ = go.GraphObject.make;
  
  return $(go.GraphLinksModel,
		{
			copiesArrays: true,
			copiesArrayObjects: true,
			nodeDataArray: nodedata,
			linkDataArray: linkdata
    });
}