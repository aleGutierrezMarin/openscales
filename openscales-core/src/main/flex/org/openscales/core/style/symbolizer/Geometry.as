package org.openscales.core.style.symbolizer
{
	public class Geometry
	{
		private var _functionName:String = null;
		private var _propertyName:String = null;
		
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
			// TODO
		}
	}
}