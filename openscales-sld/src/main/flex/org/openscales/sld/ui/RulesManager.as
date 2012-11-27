package org.openscales.sld.ui
{
	import org.openscales.sld.events.SLDEvent;
	
	import mx.collections.ArrayCollection;
	
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.sld.skin.DefaultRulesManagerSkin;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class RulesManager extends SkinnableComponent
	{
		
		private var _rules:ArrayCollection = null;
		private var _currentRule:Rule = null;
		private var _currentSymbolizer:Symbolizer = null;
		
		public function RulesManager()
		{
			super();
			this.addEventListener(SLDEvent.REMOVE_RULE,this.removeRule);
			this.addEventListener(SLDEvent.ADD_RULE,this.addRule);
			this.setStyle("skinClass",DefaultRulesManagerSkin);
		}
		
		public function removeRule(e:SLDEvent):void {
			if(rules) {
				var i:int=_rules.getItemIndex(e.rule);
				if(i!=-1) {
					_rules.removeItemAt(i);
					this.dispatchEvent(new SLDEvent(SLDEvent.RULE_REMOVED,e.rule,null));
				}
			}
		}
		
		public function addRule(e:SLDEvent):void {
			var rule:Rule = e.rule;
			if(!rule)
				rule = new Rule();
			
			if(!rules)
				rules = new ArrayCollection();
			
			this.rules.addItem(rule);
			this.dispatchEvent(new SLDEvent(SLDEvent.RULE_ADDED,rule,null));
			
			this.currentRule = rule;
			this.dispatchEvent(new SLDEvent(SLDEvent.CURRENT_RULE_CHANGED,rule,null));
		}

		[Bindable]
		public function get rules():ArrayCollection
		{
			return _rules;
		}

		public function set rules(value:ArrayCollection):void
		{
			_rules = value;
			if(_rules && _rules.length>0)
				this.currentRule = _rules.getItemAt(0) as Rule;
		}
		
		[Bindable]
		public function get currentRule():Rule
		{
			return _currentRule;
		}

		public function set currentRule(value:Rule):void
		{
			_currentRule = value;
			this.dispatchEvent(new SLDEvent(SLDEvent.CURRENT_RULE_CHANGED,_currentRule,null));
		}
		
		[Bindable]
		public function get currentSymbolizer():Symbolizer
		{
			return _currentSymbolizer;
		}
		
		public function set currentSymbolizer(value:Symbolizer):void
		{
			_currentSymbolizer = value;
			this.dispatchEvent(new SLDEvent(SLDEvent.CURRENT_SYMBOLIZER_CHANGED,null,_currentSymbolizer));
		}

	}
}