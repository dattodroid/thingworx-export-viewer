
class ModelCheck {

	constructor() {
		this.results = null; // the XML model is static : just cache the results after first run
	}

	execute(model) {

		if (this.results === null) { 
			this.results = [];
			this.checkModelGlobal(model, this.results);
			this.checkModelEntities(model, this.results);
		}
		return this.results;  // [{name : string, severity : int, comment : string, results : [{item : EntItem, message : string}}]}
	}

	checkModelGlobal(model, results = []) {

		return this.checkRules(Rule.ModelRules, model, results);
	}

	checkModelEntities(model, results = []) {

		model.entities.forEach((entity) => {
			const result = this.checkEntity(entity, results);
		});
		return results; // [{name : string, severity : int, comment : string, results : [{item : EntItem, message : string}]}]
	}

	checkEntity(entity, results = []) {
		return this.checkRules(Rule.EntityRules, entity, results);
	}

	checkRules(rules, obj, results = []) {

		rules.forEach((rule) => {
			const rule_results = rule.callback(obj);
			if (rule_results.length > 0) {
				results.push({ name: rule.name, severity: rule.severity, comment: rule.description, results: rule_results });
			}
		});
		return results; // [{name : string, severity : int, comment : string, results : [{item : EntItem, message : string}]}]
	}

	/* Entity callbacks */
	static _FindOrphanBindings(entity, item_type, binding_type) {

		let orphans = [];

		const bindings = entity.getEntItemsByType(binding_type);
		bindings.forEach((bind) => {
			const prop_def = entity.getEntItemByName(item_type, bind.name);
			if (prop_def === undefined) // binding without definition = orphan
				orphans.push({ item: bind, message: null });
		});
		return orphans;
	}

	static ECB_OrphanRemotePropertyBindings(entity) {
		return ModelCheck._FindOrphanBindings(entity, "PropertyDefinition", "RemotePropertyBinding");
	}

	static ECB_OrphanLocalPropertyBindings(entity) {
		return ModelCheck._FindOrphanBindings(entity, "PropertyDefinition", "PropertyBinding");
	}

	static ECB_TypeMismatchLocalPropertyBindings(entity) {
		
		let badbinds = [];

		const bindings = entity.getEntItemsByType("PropertyBinding");
		bindings.forEach((bind) => {
			const prop_def = entity.getEntItemByName("PropertyDefinition", bind.name);
			if (prop_def != undefined) { // ignore orphans 
				const src_ent = entity.model.getEntityByTypeAndName(THING, bind.data.src_thing);
				const src_prop = src_ent.getEntItemByName("PropertyDefinition", bind.data.src_prop);
				if (src_prop != undefined) { // maybe a java property like isConnected
					if (src_prop.data.type != prop_def.data.type) {
						badbinds.push({ item: bind, message: src_prop.data.type + " &gt; " + prop_def.data.type });
					}
				}
			}
		});
		return badbinds;
	}

	static ECB_OrphanRemoteServiceBinding(entity) {
		return ModelCheck._FindOrphanBindings(entity, "ServiceDefinition", "RemoteServiceBinding");
	}

	/* Model callbacks */

	static _SearchInXML(model, collect_descendent, xpath) {

		let xml_items = [];

		if (model.xml === null)
			return xml_items;

		let xpath_result = model.xml.evaluate(xpath, model.xml, null, XPathResult.UNORDERED_NODE_ITERATOR_TYPE, null);
		let node = xpath_result.iterateNext();
		while (node) {
			const entity = model.getEntityByTypeAndName(node.nodeName, node.getAttribute('name'));
			xml_items.push({ item: entity, message: null });
			node = xpath_result.iterateNext();
		}

		return xml_items;
	}

	static _SearchInCode(model, collect_descendent, regex1, test1 = true, regex2 = null, test2 = true) {

		let code_items = [];

		const code_els = model.html.querySelectorAll(CODE_SEL);
		code_els.forEach((code_el) => {
			let found = false;
			if (regex1.test(code_el.textContent) == test1) {
				if (regex2 === null) {
					found = true;
				}
				else {
					found = (regex2.test(code_el.textContent) == test2);
				}
			}
			if (found) {
				let eitems_ar = model.getEntItemsById(code_el.dataset.id);
				eitems_ar.forEach((eitem) => code_items.push({ item: eitem, message: null }))
			}
		});
		return code_items;
	}

	static MCB_StreamModif(model) {
		const regex = new RegExp("(UpdateStreamEntry|DeleteStreamEntry)", 'g');
		return ModelCheck._SearchInCode(model, false, regex);
	}

	static MCB_CreateThingNoTryCatch(model) {
		const regex1 = new RegExp("CreateThing", 'g');
		const regex2 = new RegExp("try[\\S\\s]*CreateThing[\\S\\s]*catch", 'g');
		return ModelCheck._SearchInCode(model, false, regex1, true, regex2, false);
	}

	static MCB_FrequentTimer(model) {
		return ModelCheck._SearchInXML(model, false, "(//Thing|//ThingTemplate|//ThingShape)[.//updateRate[number(text()) < 10000]]");
	}
}

ModelCheck.instance = new ModelCheck();


class Rule {

	constructor(name, severity, description, callback) {
		this.name = name
		this.severity = severity;
		this.description = description;
		this.callback = callback;
	}
}

Rule.EntityRules = [
	new Rule("OrphanRemotePropertyBindings", 1, "TW-27276", ModelCheck.ECB_OrphanRemotePropertyBindings),
	new Rule("OrphanLocalPropertyBindings", 1, "PSPT-5507", ModelCheck.ECB_OrphanLocalPropertyBindings),
	new Rule("TypeMismatchLocalPropertyBindings", 1, "PSPT-7786", ModelCheck.ECB_TypeMismatchLocalPropertyBindings),
];

Rule.ModelRules = [
	//new Rule("UpdateStreamEntry / DeleteStreamEntry", 3, "services not for casual use", ModelCheck.MCB_StreamModif),
	new Rule("CreateThing not in try / catch", 1, "may create Ghost entities", ModelCheck.MCB_CreateThingNoTryCatch),
	new Rule("Frequent Timers", 2, "update rate < 10 sec", ModelCheck.MCB_FrequentTimer)
];

var regex = "try[\S\s]*myMethod[\S\s]*catch";
