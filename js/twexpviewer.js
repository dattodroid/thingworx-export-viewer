class UIModelHelper {
	constructor(model) {
		this.model = model;
	}

	get html() {
		return this.model.html;
	}

	getOrphanLabel(id) {
		return "<span class='sev1'>" + id + "</span>";
	}

	getMoreHTML(id) {
		const entity_el = this.html.querySelector('#' + id);
		if (entity_el == null) {
			return this.getOrphanLabel(id);
		}
		const more_el = entity_el.querySelector(MORE_SEL);
		return (more_el === null) ? "" : more_el.innerHTML;
	}

	entityLabelHTML(entity) {
		return "<a href=\'#" + entity.id + "\'><span class='" + (entity.type === THINGSHAPE ? "i" : "n") + "'>" + entity.name + "</span></a>";
	}

	getEntityLabelMoreHTML(entity) {
		return this.entityLabelHTML(entity) + this.getMoreHTML(entity.id);
	}

	getModelItemMoreHTML(item) {
		let html;
		switch (item.type) {
			case PROP_DEF:
				html = this.getMoreHTML(item.id);
				break;
			case SRV_DEF:
				html = this.getMoreHTML(item.id);
				break;
			case SUBS_DEF:
				html = this.getMoreHTML(item.id);
				break;
		}
		return html;
	}

	getEntItemLocalLabelHTML(eitem) {
		let html;
		if (eitem.path === null)
			html = "<a href=\'#" + eitem.id + "\'>" + eitem.name + "</a>";
		else
			html = "<a href=\'#" + eitem.id + "\'>" + eitem.name + "</a> ~ " + eitem.owner.name;
		return html;
	}

	getEntItemLocalLabelMoreHTML(eitem) {
		const more = this.getModelItemMoreHTML(eitem.item);
		if (more == null || more === "")
			return this.getEntItemLocalLabelHTML(eitem);
		else
			return this.getEntItemLocalLabelHTML(eitem) + more;
	}

	getItemLocalLabelMoreHTML(item) {
		let html;

		if (item instanceof Entity) {
			html = this.getEntityLabelMoreHTML(item);
		}
		else if (item instanceof EntItem) {
			html = this.getEntItemLocalLabelMoreHTML(item);
		}
		else {
			html = "<a href=\'#" + item.id + "\'>" + item.name + "</a>";
		}
		return html;
	}

	getEntItemLabelHTML(eitem) {
		let html;
		if (eitem.path === null)
			html = "<a href=\'#" + eitem.id + "\'>" + eitem.name + "</a> ~ " + eitem.entity.name;
		else
			html = "<a href=\'#" + eitem.id + "\'>" + eitem.name + "</a> @ <a href=\'#" + eitem.entity.id + "\'>" + eitem.entity.name + "</a> ~ " + eitem.owner.name;
		return html;
	}

	getEntItemLabelMoreHTML(eitem) {
		const more = this.getModelItemMoreHTML(eitem);
		if (more == null || more === "")
			return this.getEntItemLabelHTML(eitem);
		else
			return this.getEntItemLabelHTML(eitem) + more;
	}

	showCodeLinkHTML(code_id, label, search_key = null) {
		if (search_key === null)
			return "<a href=\"javascript:TEV.showCode('" + code_id + "');\">" + label + "</a>";
		else
			return "<a href=\"javascript:TEV.showCode('" + code_id + "', '" + search_key + "');\">" + label + "</a>";
	}

	findRefsLinkHTML(search_key) {
		return "<a class='action-label' href=\"javascript:TEV.findRefs('" + search_key + "');\">\uA60F</a>";
	}

	gotoEntity(type, name) {
		location.hash = "#" + this.model.getEntityIdByTypeAndName(type, name);
	}

	doSearchDefinitions(table_el, search_key) {

		const ents_map = this.model.searchEntitiesByName(search_key);
		ents_map.forEach((entities, type) => {

			let row = table_el.insertRow(-1);
			let cell1 = row.insertCell(0);
			let cell2 = row.insertCell(1);

			cell1.innerHTML = type;

			let items_html = "<ul class='flat'>";
			entities.forEach((entity) => items_html += "<li>" + this.getEntityLabelMoreHTML(entity) + "</li>");
			items_html += "</ul>";
			cell2.innerHTML = items_html;
		});

		const items_map = this.model.searchEntItemsByName(search_key);
		items_map.forEach((eitems, type) => {

			let row = table_el.insertRow(-1);
			let cell1 = row.insertCell(0);
			let cell2 = row.insertCell(1);

			cell1.innerHTML = type;

			let items_html = "<ul class='flat'>";
			eitems.forEach((eitem) => items_html += "<li>" + this.getEntItemLabelMoreHTML(eitem) + "</li>");
			items_html += "</ul>";
			cell2.innerHTML = items_html;
		});
	}

	doModelCheck(table_el) {

		const results = ModelCheck.instance.execute(this.model);  // [{name : string, severity : int, comment : string, results : [{item : EntItem, message : string}}]}

		results.forEach((rule_result) => {
			let row = table_el.insertRow(-1);
			let cell1 = row.insertCell(0);
			let cell2 = row.insertCell(1);

			cell1.innerHTML = "<span class='sev" + rule_result.severity + "'>" + rule_result.name + "</span><br><span class='floatr'><i>" + rule_result.comment +"</i></span>";

			let item_html = "<ul class='flat'>";
			rule_result.results.forEach((eitem_result) => item_html += "<li>" + this.getItemLocalLabelMoreHTML(eitem_result.item) + (eitem_result.message != null ? " : " + eitem_result.message : "") + "</li>");
			item_html += "</ul>";
			cell2.innerHTML = item_html;
		});
	}

	doSearchReferences(table_el, search_key, ignore_comments) {

		const code_els = this.model.html.querySelectorAll(CODE_SEL);

		code_els.forEach((code_el) => {

			let found = false;
			const code = code_el.textContent;

			for (let found_idx = code.indexOf(search_key);
				found_idx >= 0 && !found;
				found_idx = code.indexOf(search_key, found_idx + 1)) {

				found = true;

				if (ignore_comments) {
					let commented = false;
					// is multi lines commented
					let start_idx = code.lastIndexOf('/*', found_idx);
					if (start_idx >= 0) {
						if (code.substring(start_idx, found_idx).indexOf('*/') < 0)
							commented = true;
					}
					if (!commented) { // is single line comment
						let nline_idx = code.lastIndexOf('\n', found_idx); // find begining of line
						if (nline_idx < 0) nline_idx = 0;
						if (code.substring(nline_idx, found_idx).indexOf('//') >= 0) // line commented
							commented = true;
					}
					if (commented)
						found = false;
				}
			}

			if (found) {
				const code_id = code_el.dataset.id;
				const code_name = code_el.dataset.name;
				const code_tokens = code_name.split(SERVICE_SEP);
				const ent_tokens = code_tokens[0].split(TYPE_SEP);

				let srv_name = null;
				const ent_type = ent_tokens[0];
				const ent_name = ent_tokens[1];
				let wu_key = ent_name;

				if (code_tokens.length > 1) {
					srv_name = code_tokens[1];
					wu_key = srv_name;
				}

				let row = table_el.insertRow(-1);
				let cell1 = row.insertCell(0);
				let cell2 = row.insertCell(1);

				cell1.innerHTML = ent_type;
				cell2.innerHTML = this.showCodeLinkHTML(code_id, (srv_name !== null) ? srv_name : "{content}", search_key) +
					" ~ " + "<a href=\'#" + code_id + "'>" + ent_name + "</a>" + this.findRefsLinkHTML(wu_key);
			}
		});
	}

	doEntityDetails(table_el, entity_fullname) {

		const entity = this.model.getEntityByFullName(entity_fullname);

		let row = table_el.insertRow(-1);
		let cell1 = row.insertCell(0);
		let cell2 = row.insertCell(1);

		cell1.innerHTML = "<ul class='tree'>" + this._listParents(entity) + "</ul>";
		let nested_tbl = document.createElement('table');
		nested_tbl.border = 0;
		cell2.appendChild(nested_tbl);

		entity.getEntItemTypes().forEach((type) => {

			let row = nested_tbl.insertRow(-1);
			let cell1 = row.insertCell(0);
			let cell2 = row.insertCell(1);

			cell1.innerHTML = type;

			let item_html = "<ul class='flat'>";
			entity.getEntItemsByType(type).forEach((eitem) => item_html += "<li>" + this.getEntItemLocalLabelMoreHTML(eitem) + "</li>");
			item_html += "</ul>";
			cell2.innerHTML = item_html;
		});
	}

	_listParents(entity) {
		if (typeof entity === 'string') {
			return this.getOrphanLabel(entity);
		} else {
			let p_html = "<li>" + this.entityLabelHTML(entity) + this.getMoreHTML(entity.id) + "<ul class='tree'>";
			entity.getParents().forEach((parent) => p_html += this._listParents(parent));
			p_html += "</ul></li>";
			return p_html;
		}
	}

	doEntityPCD(canvas_el, entity_fullname) {
		const entity = this.model.getEntityByFullName(entity_fullname);
		let umldata = "#fill:lightyellow\n #lineWidth:2\n #zoom:1.0 \n";
		umldata += entity.getParentsNomnomData();
		nomnoml.draw(canvas_el, umldata);
	}

	doEntityDCD(canvas_el, entity_fullname) {
		const entity = this.model.getEntityByFullName(entity_fullname);
		let umldata = "#fill:#e0e0ff\n #lineWidth:2\n #zoom:1.0 \n";
		umldata += entity.getDescendentsNomnomData();
		nomnoml.draw(canvas_el, umldata);
	}
}

class UIModelTable extends UIComponent {

	constructor(id) {
		super(id);
		this.gotoparent_logic = null;
	}

	_initHTML() {
		super._initHTML();
	}

	_initListeners() {
		super._initListeners();
		const templrefs = this.getNestedELs(BASE_TEMPLATE_SEL);
		templrefs.forEach(link => {
			link.addEventListener("click", (event) => this._linkClickCB(THINGTEMPLATE, event.target.dataset.name));
		});

		const shaperefs = this.getNestedELs(BASE_SHAPE_SEL);
		shaperefs.forEach(link => {
			link.addEventListener("click", (event) => this._linkClickCB(THINGSHAPE, event.target.dataset.name));
		});
	}

	_linkClickCB(type, name) {
		this.gotoparent_logic(type, name);
	}

	setGotoParentLogic(callback) {
		this.gotoparent_logic = callback;
	}
}

class TWExportViewer {

	constructor() {
		this.refs_dialog = null;
		this.defs_dialog = null;
		this.code_popup = null;
		this.uml_popup = null;
		this.mc_dialog = null;
		this.model_table = null;
		this.model = new Model();
		this.mhelper = null;
	}

	init(model_xml) {

		this.model_table = new UIModelTable("twx-model");
		this.model_table.init();
		const model_html = this.model_table.getRootEL();
		this.model.loadFromHTML(model_html, model_xml);
		this.mhelper = new UIModelHelper(this.model);
		this.model_table.setGotoParentLogic((type, name) => this.mhelper.gotoEntity(type, name));


		this.defs_dialog = new UIDefinitionsDialog("DEFS");
		this.defs_dialog.addAndInit();
		this.defs_dialog.setSearchLogic((table_el, searck_key) => this.mhelper.doSearchDefinitions(table_el, searck_key));

		this.refs_dialog = new UIReferencesDialog("REFS");
		this.refs_dialog.addAndInit();
		this.refs_dialog.setSearchLogic((table_el, search_key, ignore_commented) => this.mhelper.doSearchReferences(table_el, search_key, ignore_commented));

		this.mc_dialog = new UIModelCheckDialog("MC");
		this.mc_dialog.addAndInit();
		this.mc_dialog.setCheckLogic((table_el) => this.mhelper.doModelCheck(table_el));

		this.code_popup = new UICodeViewer("CODE");
		this.code_popup.addAndInit();

		this.uml_popup = new UIUmlViewer("UML");
		this.uml_popup.addAndInit();
	}

	showCode(code_id, search_key = null) {
		if (this.code_popup !== null) {
			const item_el = document.getElementById(code_id);
			const itemcode_el = item_el.querySelector(CODE_SEL);
			this.code_popup.showCode(itemcode_el, search_key);
		}
	}

	showPCD(entity_fullname) {
		if (this.uml_popup !== null) {
			this.uml_popup.showUML((canevas_el) => this.mhelper.doEntityPCD(canevas_el, entity_fullname));
		}
	}

	showDCD(entity_fullname) {
		if (this.uml_popup !== null) {
			this.uml_popup.showUML((canevas_el) => this.mhelper.doEntityDCD(canevas_el, entity_fullname));
		}
	}

	showDetails(entity_fullname) {
		if (this.defs_dialog !== null) {
			this.defs_dialog.showEntityDetails((table_el) => this.mhelper.doEntityDetails(table_el, entity_fullname));
		}
	}

	findDefs(search_key = null) {
		if (this.defs_dialog !== null) {
			if (search_key === null) {
				search_key = window.getSelection().toString();
			}
			this.defs_dialog.doSearch(search_key);
		}
	}

	findRefs(search_key = null) {
		if (this.refs_dialog !== null) {
			if (search_key === null) {
				search_key = window.getSelection().toString();
			}
			this.refs_dialog.doSearch(search_key);
		}
	}
}

const TEV = new TWExportViewer();

function loadAll(xml_el = null) {
	TEV.init(xml_el);
}
