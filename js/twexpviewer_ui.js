const CODE_SEL = "._code";
const MORE_SEL = "._more";

class BreadCrums {

	constructor(max = 20, show = 2) {
		this.bc_arr = [];
		this.bc_curs = 0;
		this.BC_MAX_ARR = max;
		this.BC_SHOW = show;
	}

	_toHTML() {
		let html = '';
		let start = 0;
		let end = 0;

		if (this.bc_curs == 1) {
			start = 1;
			end = start + this.BC_SHOW;
		} else if (this.bc_curs == this.bc_arr.length) {
			end = this.bc_arr.length;
			start = end - this.BC_SHOW;
		} else {
			start = this.bc_curs - (this.BC_SHOW - 1);
			end = this.bc_curs + 1;
		}

		if (end > this.bc_arr.length)
			end = this.bc_arr.length;

		if (start < 1)
			start = 1;

		if (start > 1)
			html = "...";

		for (let i = start - 1; i < end; i++) {
			if (i == this.bc_curs - 1)
				html = html + "<b>" + this.bc_arr[i] + "</b>";
			else
				html = html + this.bc_arr[i];

			if (i < end - 1)
				html = html + " &gt; ";
		}

		if (end < this.bc_arr.length)
			html = html + "...";

		return html;
	}

	push(search_key) {
		if (this.bc_curs == this.BC_MAX_ARR) {
			this.bc_arr = this.bc_arr.slice(-10);
			this.bc_curs = this.bc_arr.length;
		}
		this.bc_arr[this.bc_curs] = search_key;
		this.bc_curs++;
		return this._toHTML();
	}

	prev() {
		if (this.bc_curs > 1) {
			this.bc_curs--;
		}
		return {
			html: this._toHTML(),
			search_key: this.bc_arr[this.bc_curs - 1]
		};
	}

	next() {
		if (this.bc_curs < this.bc_arr.length) {
			this.bc_curs++;
		}
		return {
			html: this._toHTML(),
			search_key: this.bc_arr[this.bc_curs - 1]
		};
	}
}

class UIComponent {

	constructor(id) {
		this.id = id;
		this.root_el = null;
	}

	_initHTML() {
		this.root_el = document.getElementById(this.id);
	}

	_initListeners() {
	}

	init() {
		this._initHTML();
		this._initListeners();
	}

	getNestedEL(selector) {
		return this.root_el.querySelector(selector);
	}

	getNestedELs(selector) {
		return this.root_el.querySelectorAll(selector);
	}

	getRootEL() {
		return this.root_el;
	}
}

class UITemplatedComponent extends UIComponent {

	constructor(id) {
		super(id);
	}

	_initHTML(template_id, parent_el) {
		let template = document.getElementById(template_id);
		let root_el = template.querySelector('.comp-root');
		let clone = document.importNode(root_el, true);
		clone.id = this.id;
		parent_el.appendChild(clone);
		super._initHTML();
	}

	_initListeners() {
	}

	addAndInit(template_id = null, parent_el = null) {
		this._initHTML(template_id !== null ? template_id : this.constructor.name, parent_el !== null ? parent_el : document.body);
		this._initListeners();
	}
}

class UIToggleDialog extends UITemplatedComponent {

	constructor(id) {
		super(id);
		this.tab_el = null;
		this.body_el = null;
		this.table_el = null;
	}

	_initHTML(template_id, parent_el) {
		super._initHTML(template_id, parent_el);
		this.tab_el = this.getNestedEL(".tog-tab");
		this.body_el = this.getNestedEL(".tog-body");
		this.table_el = this.getNestedEL(".tog-results-tbl");
	}

	_initListeners() {
		super._initListeners();
		this.tab_el.addEventListener("click", (event) => { if (event.target === this.tab_el) this.toggle() });
	}

	_clearResultTable() {
		while (this.table_el.rows[0]) this.table_el.deleteRow(0);
		return this.table_el;
	}

	get isOpened() {
		return (this.body_el.style.display === "block");
	}

	getCleanResultTableEl() {
		return this._clearResultTable();
	}

	open() {
		this.body_el.style.display = "block";
	}

	close() {
		this.body_el.style.display = "none";
	}

	toggle() {
		if (this.isOpened)
			this.close()
		else
			this.open();
	}
}

class UIDefinitionsDialog extends UIToggleDialog {

	constructor(id) {
		super(id);
		this.search_logic = null;
		this.search_el = null;
		this.search_key = null;
	}

	_initHTML(template_id, parent_el) {
		super._initHTML(template_id, parent_el);
		this.search_el = this.getNestedEL('.search');
	}

	_initListeners() {
		super._initListeners();
		this.search_el.addEventListener("keydown", (event) => { if (event.keyCode == 13) this._searchInputCB() });
	}

	doSearch(search_key) {
		this.search_logic(this.getCleanResultTableEl(), search_key);
		this.open();
	}

	_searchInputCB() {
		const search_key = this.search_el.value.trim();
		if (search_key.length === 0 || search_key === this.search_key) {
			this.open();
		} else {
			this.search_key = search_key;
			this.doSearch(this.search_key);
		}
	}

	setSearchLogic(callback) {
		this.search_logic = callback;
	}

	setDetailsLogic(callback) {
		this.search_logic = callback;
	}

	showEntityDetails(detailsCallback) {
		const table_el = this.getCleanResultTableEl();
		detailsCallback(table_el);
		this.search_key = null;
		this.open();
	}
}

class UIModelCheckDialog extends UIToggleDialog {

	constructor(id) {
		super(id);
		this.check_logic = null;
	}

	_initHTML(template_id, parent_el) {
		super._initHTML(template_id, parent_el);
	}

	_initListeners() {
		super._initListeners()
		this.getNestedEL('.check').addEventListener("click", (event) => this._checkButtonCB());
	}

	_checkButtonCB() {
		this.check_logic(this.getCleanResultTableEl());
		this.open();
	}

	setCheckLogic(callback) {
		this.check_logic = callback;
	}
}

class UIReferencesDialog extends UIToggleDialog {

	constructor(id) {
		super(id);
		this.search_logic = null;
		this.bc_el = null;
		this.search_el = null;
		this.comments_el = null;
		this.breadcrums = new BreadCrums();
	}

	_initHTML(template_id, parent_el) {
		super._initHTML(template_id, parent_el);
		this.bc_el = this.getNestedEL("span.bc");
		this.search_el = this.getNestedEL('.search');
		this.comments_el = this.getNestedEL('.comments');
	}

	_initListeners() {
		super._initListeners();
		this.search_el.addEventListener("keydown", (event) => { if (event.keyCode == 13) this._searchInputCB(event.target) });
		this.comments_el.addEventListener("change", (event) => { this._commentsInputCB(event.target) });
		this.getNestedEL(".bcprev").addEventListener("click", (event) => this._bcPrevButtonCB());
		this.getNestedEL(".bcnext").addEventListener("click", (event) => this._bcNextButtonCB());

	}

	_bcPrevButtonCB() {
		var bc = this.breadcrums.prev();
		this.bc_el.innerHTML = bc.html;
		this.doSearch(bc.search_key);
	}

	_bcNextButtonCB() {
		var bc = this.breadcrums.next();
		this.bc_el.innerHTML = bc.html;
		this.doSearch(bc.search_key);
	}

	_bcPush(search_key) {
		this.bc_el.innerHTML = this.breadcrums.push(search_key);
	}

	doSearch(search_key) {
		const ignore_comments = this.comments_el.checked;
		this.search_logic(this.getCleanResultTableEl(), search_key, ignore_comments);
		this.search_el.value = search_key;
		this._bcPush(search_key);
		this.open();
	}

	_commentsInputCB(comments_el) {
		this._searchInputCB(this.search_el);
	}

	_searchInputCB(search_el) {
		const search_key = search_el.value.trim();
		if (search_key.length > 0) {
			this.doSearch(search_key);
		}
	}

	setSearchLogic(callback) {
		this.search_logic = callback;
	}
}

class UIModalDialog extends UITemplatedComponent {

	constructor(id) {
		super(id);
	}

	_initListeners() {
		super._initListeners();
		this.root_el.addEventListener("click", (event) => { if (event.target === this.root_el) this.close() });
	}

	_initHTML(template_id, parent_el) {
		super._initHTML(template_id, parent_el);
		this.bc_el = this.getNestedEL("span.bc");
	}

	open() {
		this.root_el.style.display = "block";
	}

	close() {
		this.root_el.style.display = "none";
	}
}

class UICodeViewer extends UIModalDialog {
	constructor(id) {
		super(id);
		this.header_el = null;
		this.body_el = null;
	}

	_initHTML(template_id, parent_el) {
		super._initHTML(template_id, parent_el);
		this.header_el = this.getNestedEL(".modal-header");
		this.body_el = this.getNestedEL(".modal-body");
	}

	_initListeners() {
		super._initListeners();
	}

	showCode(itemcode_el, search_key) {
		this.close();

		this.header_el.innerHTML = "<h3>" + itemcode_el.dataset.name + itemcode_el.dataset.params + "</h3>";
		this.body_el.innerHTML = itemcode_el.innerHTML;
		let code_el = this.body_el.querySelector("pre code");
		if ((search_key !== null)) {
			const r = new RegExp(search_key, "g"); // global match and ignore case flag
			code_el.innerHTML = code_el.innerHTML.replace(r, "<span class='keyword-hl'>" + search_key + "</span>");
		}
		hljs.highlightBlock(code_el);
		this.open();
	}
}

class UIUmlViewer extends UIModalDialog {
	constructor(id) {
		super(id);
		this.canvas_el = null;
	}

	_initHTML(template_id, parent_el) {
		super._initHTML(template_id, parent_el);
		this.canvas_el = this.getNestedEL(".uml-canvas");
	}

	_initListeners() {
		super._initListeners();
	}
	
	showUML(umlCallback) {
		this.close();
		umlCallback(this.canvas_el);
		this.open();
	}
}
