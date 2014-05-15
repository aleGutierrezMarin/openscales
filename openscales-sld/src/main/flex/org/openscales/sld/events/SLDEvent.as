package org.openscales.sld.events
{
	import flash.events.Event;
	
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.symbolizer.Symbolizer;
	
	public class SLDEvent extends Event
	{
		
		public static var RULE_ADDED:String = "SLDEvent.ruleadded";
		public static var RULE_REMOVED:String = "SLDEvent.ruleremoved";
		public static var ADD_RULE:String = "SLDEvent.addrule";
		public static var REMOVE_RULE:String = "SLDEvent.removerule";
		public static var CURRENT_RULE_CHANGED:String = "SLDEvent.curentrulechanged";
		public static var RULE_UPDATED:String = "SLDEVENT.ruleupdated";
		
		public static var SYMBOLIZER_ADDED:String = "SLDEvent.symbolizeradded";
		public static var SYMBOLIZER_REMOVED:String = "SLDEvent.symbolizerremoved";
		public static var ADD_SYMBOLIZER:String = "SLDEvent.addsymbolizer";
		public static var REMOVE_SYMBOLIZER:String = "SLDEvent.removesymbolizer";
		public static var CURRENT_SYMBOLIZER_CHANGED:String = "SLDEvent.curentsymbolizerchanged";
		public static var SYMBOLIZER_UPDATED:String = "SLDEVENT.ruleupdated";
		
		private var _rule:Rule = null;
		private var _symbolizer:Symbolizer = null;
		
		public function SLDEvent(type:String, rule:Rule, symbolizer:Symbolizer, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._rule = rule;
			this._symbolizer = symbolizer;
		}

		public function get rule():Rule
		{
			return _rule;
		}
		
		public function get symbolizer():Symbolizer
		{
			return _symbolizer;
		}
		
		override public function clone():Event {
			return new SLDEvent(this.type,this.rule,this.symbolizer,this.bubbles,this.cancelable);
		}

	}
}