package org.openscales.core.style.symbolizer
{
	import org.openscales.core.style.marker.Marker;
	
	public class PointSymbolizer extends Symbolizer
	{
		private namespace sldns="http://www.opengis.net/sld";
		
		private var _graphic:Marker;
		
		public function PointSymbolizer(graphic:Marker = null)
		{
			this._graphic = graphic;
		}
		
		public function get graphic():Marker{
			
			return this._graphic;
		}
		
		public function set graphic(value:Marker):void{
			
			this._graphic = value;
		}
		
		override public function clone():Symbolizer{
			var pointSymbolizer:PointSymbolizer = new PointSymbolizer(this._graphic.clone());
			pointSymbolizer.geometry = this.geometry == null ? null : this.geometry.clone();
			return pointSymbolizer;
		}
		
		override public function get sld():String {
			var res:String = "<sld:PointSymbolizer>\n";
			if(this.geometry) {
				res += this.geometry.sld;
			}
			if(this.graphic) {
				var sld:String = this.graphic.sld;
				if(sld)
					res+=sld+"\n";
			}
			res+="</sld:PointSymbolizer>";
			return res;
		}
		
		override public function set sld(sldRule:String):void {
			use namespace sldns;
			super.sld = sldRule;
			var dataXML:XML = new XML(sldRule);
			if(this._graphic)
				this._graphic = null;
			// TODO
			
		}
	}
}