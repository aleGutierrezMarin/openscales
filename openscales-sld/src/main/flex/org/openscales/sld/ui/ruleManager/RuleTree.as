package org.openscales.sld.ui.ruleManager
{
	import mx.collections.ArrayCollection;
	
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.symbolizer.Symbolizer;
	
	import org.openscales.sld.skin.ruleManager.DefaultRuleTree;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class RuleTree extends SkinnableComponent
	{
		private var _rules:ArrayCollection = null;
		private var _currentRule:Rule = null;
		private var _currentSymbolizer:Symbolizer = null;
		
		public function RuleTree()
		{
			super();
			this.setStyle("skinClass",DefaultRuleTree);
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
		}

		[Bindable]
		public function get currentSymbolizer():Symbolizer
		{
			return _currentSymbolizer;
		}

		public function set currentSymbolizer(value:Symbolizer):void
		{
			_currentSymbolizer = value;
		}

	}
}