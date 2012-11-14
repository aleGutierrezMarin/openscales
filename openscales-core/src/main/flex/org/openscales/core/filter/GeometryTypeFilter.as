package org.openscales.core.filter
{
	import org.openscales.core.feature.Feature;
	
	/**
	 * Filter matching features according to the type of their geometry
	 */
	public class GeometryTypeFilter implements IFilter{
		
		private var _types:Vector.<Class>;		
		
		public function GeometryTypeFilter(types:Vector.<Class>){
			
			this._types = types;
		}
		
		public function matches(feature:Feature):Boolean {
			
			for each(var type:Class in this._types){
				
				if(feature.geometry is type){
					
					return true;
				}
			}
			
			return false;
		}
		
		public function clone():IFilter	{
			
			return new GeometryTypeFilter(this._types);
			
		}
		
		public function get sld():String {
			return null;
		}
		public function set sld(sld:String):void {
			//TODO
		}
	}
}