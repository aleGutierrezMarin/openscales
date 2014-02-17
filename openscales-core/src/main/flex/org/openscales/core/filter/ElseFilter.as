package org.openscales.core.filter {
	import org.openscales.core.feature.Feature;

	public class ElseFilter implements IFilter
	{
		public function ElseFilter() {
		}

		public function matches(feature:Feature):Boolean {
			return true;
		}
		
		public function clone():IFilter{
			var elseFilter:ElseFilter = new ElseFilter();
			return elseFilter;
		}
		
		public function get sld():String {
			return null;
		}
		public function set sld(sld:String):void {
			//TODO
		}
	}
}