package org.openscales.core.style.symbolizer
{
	public class Geometry
	{
		private var _functionName:String = null;
		private var _propertyName:String = null;
		
		private namespace sldns="http://www.opengis.net/sld";
		
		// see : http://docs.geoserver.org/stable/en/user/filter/function_reference.html#filter-function-reference
		
		public function Geometry(propertyName:String=null,functionName:String=null)
		{
			this._propertyName = propertyName;
			this._functionName = functionName;
		}
		
		public function clone():Geometry {
			return new Geometry(this._propertyName,this._functionName);
		}

		public function get functionName():String
		{
			return _functionName;
		}

		public function set functionName(value:String):void
		{
			_functionName = value;
		}

		public function get propertyName():String
		{
			return _propertyName;
		}

		public function set propertyName(value:String):void
		{
			_propertyName = value;
		}

		public function get sld():String {
			if(!this._propertyName)
				return "";
			var ret:String = "<sld:Geometry>\n";
			if(this._functionName)
				ret+= "<ogc:Function name=\""+this._functionName+"\">\n";
			ret+= "<ogc:PropertyName>"+this._propertyName+"</ogc:PropertyName>\n";
			if(this._functionName)
				ret+= "</ogc:Function>\n";
			ret+= "</sld:Geometry>\n";
			return ret;
		}
		
		public function set sld(value:String):void {
			use namespace sldns;
			this._functionName = null;
			this._propertyName = null;
			var dataXML:XML = new XML(sld);
			var childs:XMLList = dataXML..*::PropertyName;
			var node:XML;
			if(childs.length()>0) {
				node = childs[0];
				this._propertyName = node;
			}
			childs = dataXML..*::Function;
			if(childs.length()>0) {
				node = childs[0];
				this._functionName = node;
			}
		}
	}
}