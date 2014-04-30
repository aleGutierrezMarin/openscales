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
			var ret:String = "<ogc:Filter>\n";
			ret+="<ogc:PropertyIsEqualTo>\n";
			if(this._types && this._types.length>0) {
				ret+="<ogc:Function name=\"in"+this._types.length+"\">\n";
				ret+="<ogc:Function name=\"geometryType\">\n";
				ret+="<ogc:PropertyName>geom</ogc:PropertyName>\n";
				ret+="</ogc:Function>\n";
				for each(var type:Class in this._types){
					ret+="<ogc:Literal>LineString</ogc:Literal>\n";
				}
				ret+="</ogc:Function>\n";
				ret+="<ogc:Literal>true</ogc:Literal>\n";
				ret+="\n";
			}
			
			ret+="</ogc:PropertyIsEqualTo>\n";
			ret+="</ogc:Filter>\n";
			return ret;
		}
		public function set sld(sld:String):void {
			//TODO
		}
	}
}