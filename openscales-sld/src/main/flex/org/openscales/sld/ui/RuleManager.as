package org.openscales.sld.ui
{
	import mx.core.IFlexDisplayObject;
	import mx.managers.IFocusManagerContainer;
	
	import org.openscales.core.style.Rule;
	
	import org.openscales.sld.skin.ruleManager.DefaultRuleManagerSkin;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class RuleManager extends SkinnableComponent implements IFocusManagerContainer
	{
		private var _rule:Rule;
		
		public function RuleManager()
		{
			super();
			this.setStyle("skinClass",DefaultRuleManagerSkin);
		}
		
		public function get defaultButton():IFlexDisplayObject
		{
			return null;
		}
		
		public function set defaultButton(value:IFlexDisplayObject):void
		{
		}

		public function get rule():Rule
		{
			return _rule;
		}

		public function set rule(value:Rule):void
		{
			_rule = value;
		}

	}
}