const THING = "Thing";
const THINGTEMPLATE = "ThingTemplate";
const THINGSHAPE = "ThingShape";
const MASHUP = "Mashup";
const EXTENSION = "Extension";
const PROP_DEF = "PropertyDefinition";
const SRV_DEF = "ServiceDefinition";
const SUBS_DEF = "Subscription";
const LBIND_DEF = "PropertyBinding";
const BASE_TEMPLATE_SEL = "._template";
const BASE_SHAPE_SEL = "._shape";
const ITEM_SEL = "._item";
const ENTITY_SEL = "._entity";
const SRV_PARAMS_SEL = "._params";
const PROP_TYPE_SEL = "._prop";
const LBIND_SOURCE_SEL = "._lbind";
const TYPE_SEP = "|";
const SERVICE_SEP = "::";
const PROP_SEP = "@";

function FULLNAME(type, name) { return type + TYPE_SEP + name }

'use strict';

class ModelItem {

	constructor(owner, id, name, type) {
		this.owner = owner;
		this.type = type;
		this.name = name;
		this.id = id;
		this.enabled = true;
		this.data = null;
	}

	get fullname() {
		return FULLNAME(this.type, this.name);
	}

	disable() {
		this.enabled = false;
	}

	_initDataFromHTML(el) {

		if (this.data === null) {
			switch (this.type) {
				case SRV_DEF:
					const params_el = el.querySelector(SRV_PARAMS_SEL);
					this.data = { params: params_el.textContent };
					break;
				case PROP_DEF:
					const type_el = el.querySelector(PROP_TYPE_SEL);
					this.data = { type: type_el.textContent };
					break;
				case LBIND_DEF:
					const src_el = el.querySelector(LBIND_SOURCE_SEL);
					const src = src_el.textContent.split('@');
					this.data = { src_prop: src[0], src_thing: src[1] };
					break;
				default:
					this.data = {}
			}
		}
	}
}

class Entity extends ModelItem {

	constructor(model, id, name, type) {
		super(model, id, name, type);
		this.expanded = false;
		this.entitems = [];
		this.itemtypes = new Set();
		this.parents = [];
		this.descendents = [];
		//this.owner.items.set(this.id, this);
	}

	get model() {
		return this.owner;
	}

	getParents() {
		this._expand();
		return this.parents;
	}

	getDescendents() {
		this.model._expand();
		return this.descendents;
	}

	getEntItems() {
		this._expand();
		return this.entitems;
	}

	getEntItemTypes() {
		this._expand();
		return this.itemtypes;
	}

	getEntItemsByType(type) {
		return this.getEntItems().filter(item => item.type === type);
	}

	getEntItemByName(type, name) {
		return this.getEntItems().filter(item => (item.type === type && item.name === name))[0];
	}

	initFromHTML(el) {
		this._initParentsFromHTML(el);
		this._initEntItemsFromHTML(el);
		return this;
	}

	getParentsGoData(nodedata = null, linkdata = null) {

		if (nodedata === null)
			nodedata = [];

		if (linkdata === null)
			linkdata = [];

		let properties = [];
		let methods = [];

		this.getEntItems().forEach(item => {
			if (item.path === null) {
				switch (item.type) {
					case SRV_DEF:
						methods.push({ name: item.name, parameters: item.data.params, visibility: "public" });
						break;
					case PROP_DEF:
						properties.push({ name: item.name, type: item.data.type, visibility: "public" });
						break;
				}
			}
		});

		nodedata.push({ key: this.id, name: this.name, type: this.type, properties: properties, methods: methods, events: undefined, subscriptions: undefined });

		this.getParents().forEach((parent) => {
			linkdata.push({ from: this.id, to: parent.id, relationship: "generalization" });
			parent.getParentsUMLData(nodedata, linkdata);
		});
		return { nodedata: nodedata, linkdata: linkdata };
	}

	getParentsNomnomData() {

		const SEP = " :: ";
		let nodenoml = "[";

		switch (this.type) {
			case THING:
				nodenoml += "<instance>";
				break;
			case THINGSHAPE:
				nodenoml += "<abstract>";
				break;
		}
		nodenoml += this.name + SEP + this.type;

		let srvs = null;
		let props = null;
		this.getEntItems().forEach(item => {
			if (item.path === null) {
				switch (item.type) {
					case SRV_DEF:
						if (srvs === null)
							srvs = "|";
						else
							srvs += ";";
						srvs += item.name + item.data.params;
						break;
					case PROP_DEF:
						if (props === null)
							props = "|";
						else
							props += ";";
						props += item.name + " : " + item.data.type;
						break;
				}
			}
		});
		nodenoml += (props !== null ? props : "") + (srvs !== null ? srvs : "");
		nodenoml += "]\n";

		this.getParents().forEach((parent) => {
			nodenoml += parent.getParentsNomnomData();
			nodenoml += "[" + parent.name + SEP + parent.type + "]<:-[" + this.name + SEP + this.type + "]\n";
		});
		return nodenoml;
	}

	getDescendentsNomnomData() {

		const SEP = " :: ";
		let nodenoml = "[";

		switch (this.type) {
			case THING:
				nodenoml += "<instance>";
				break;
			case THINGSHAPE:
				nodenoml += "<abstract>";
				break;
		}
		nodenoml += this.name + SEP + this.type;
		nodenoml += "]\n";

		this.getDescendents().forEach((child) => {
			nodenoml += child.getDescendentsNomnomData();
			nodenoml += "[" + this.name + SEP + this.type + "]<:-[" + child.name + SEP + child.type + "]\n";
		});
		return nodenoml;
	}

	_addItem(item) {
		this.entitems.push(item);
		this.itemtypes.add(item.type);
	}

	_initParentsFromHTML(el) {
		const tplEl = el.querySelector(BASE_TEMPLATE_SEL);
		if (tplEl !== null) {
			this.parents.push(FULLNAME(THINGTEMPLATE, tplEl.dataset.name));
		}
		const shapeEls = el.querySelectorAll(BASE_SHAPE_SEL);
		if (shapeEls !== null) {
			shapeEls.forEach((shEl) => {
				this.parents.push(FULLNAME(THINGSHAPE, shEl.dataset.name));
			});
		}
	}

	_initEntItemsFromHTML(el) {
		const item_els = el.querySelectorAll(ITEM_SEL);
		if (item_els !== null) {
			item_els.forEach((item_el) => {
				const item = new ModelItem(this, item_el.id, item_el.dataset.name, item_el.dataset.type);
				item._initDataFromHTML(item_el)
				this._addItem(new EntItem(this, item));
			});
		}
	}

	_expand() {
		if (!this.expanded) {
			for (let pp = 0; pp < this.parents.length; pp++) {
				const parent = this.model.getEntityByFullName(this.parents[pp]);
				if (parent != undefined) { // parent was maybe not exported
					parent.getEntItems().forEach((mi) => {
						const found = this.entitems.some(li => li.type === mi.type && li.name === mi.name);
						if (!found)
							this._addItem(mi.cloneExpanded(this, pp));
					});
					parent.descendents.push(this);
					this.parents[pp] = parent;
				}
				else {
					console.log("Missing Entity definition : " + this.parents[pp]);
				}

			}
			this.expanded = true;
		}
		return this;
	}
}

class EntItem {

	constructor(entity, item, path = null) {
		this.item = item;
		this.path = path;
		this.entity = entity;
	}

	get name() {
		return this.item.name;
	}

	get type() {
		return this.item.type;
	}

	get id() {
		return this.item.id;
	}

	get owner() {
		return this.item.owner;
	}

	get fullname() {
		return this.item.fullname;
	}

	get data() {
		return this.item.data;
	}

	cloneExpanded(entity, id) {
		return new EntItem(entity, this.item, [id].concat(this.path === null ? [] : this.path));
	}
}

class Model {

	constructor() {
		this.entities = new Map(); // key : FullName, value : entity
		this.expanded = false;
		this.html = null;
		this.xml = null;
		this.eitem_cache = null; // key : id, value : eitem
	}

	_expand() {
		if (!this.expanded) {
			this.entities.forEach((entity) => entity._expand());
			this.expanded = true;
		}
		return this;
	}

	loadFromHTML(html_el, xml_el = null) {
		this.html = html_el;
		this.xml = xml_el;
		const elList = html_el.querySelectorAll(ENTITY_SEL);
		elList.forEach((el) => {
			const e = this.newEntityFromHTML(el);
			this.entities.set(e.fullname, e);
		});
	}

	newEntityFromHTML(el) {
		let id = el.id;
		let name = el.dataset.name;
		let type = el.dataset.type;

		if (name === null) {
			let id_tokens = id.split(TYPE_SEP);
			type = id_tokens[0];
			name = id_tokens[1];
		}

		let e = new Entity(this, id, name, type);
		return e.initFromHTML(el);
	}

	getEntItemsById(id) {

		let results = [];

		this.entities.forEach((entity) => {
			entity.getEntItems().forEach((eitem) => {
				if (eitem.id === id) {
					results.push(eitem);
				}
			});
		});
		return results; // [eitems]  
	}

	getEntityByFullName(fullname) {
		return this.entities.get(fullname);
	}

	getEntityByTypeAndName(type, name) {
		return this.getEntityByFullName(FULLNAME(type, name));
	}

	getEntityIdByTypeAndName(type, name) {
		return this.getEntityByTypeAndName(type, name).id;
	}

	searchEntItemsByName(search_key) {
		let results = new Map();
		this.entities.forEach((entity) => {
			entity.getEntItems().forEach((eitem) => {
				if (eitem.name.indexOf(search_key) !== -1) {
					let eitems_ar = results.get(eitem.type);
					if (eitems_ar === undefined) {
						results.set(eitem.type, [eitem]);
					}
					else {
						eitems_ar.push(eitem);
					}
				}
			});
		});
		return results; // key: type, value: [items]  
	}

	searchEntitiesByName(search_key) {
		let results = new Map();
		this.entities.forEach((entity) => {
			if (entity.name.indexOf(search_key) !== -1) {
				let ents_ar = results.get(entity.type);
				if (ents_ar === undefined) {
					results.set(entity.type, [entity]);
				}
				else {
					ents_ar.push(entity);
				}
			}
		});
		return results; // key: type, value: [items]  
	}
}

