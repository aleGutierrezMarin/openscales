package org.openscales.core.style.symbolizer
{
	import org.openscales.core.style.graphic.Graphic;
	
	public class PointSymbolizer extends Symbolizer
	{
		private namespace sldns="http://www.opengis.net/sld";
		
		private var _graphic:Graphic;
		
		public function PointSymbolizer(graphic:Graphic = null)
		{
			if(graphic)
				this._graphic = graphic;
			else
				this._graphic = new Graphic();
		}
		
		public function get graphic():Graphic{
			
			return this._graphic;
		}
		
		public function set graphic(value:Graphic):void{
			
			this._graphic = value;
		}
		
		override public function clone():Symbolizer{
			var pointSymbolizer:PointSymbolizer = new PointSymbolizer();
			pointSymbolizer.graphic = this.graphic == null ? null : this.graphic.clone();
			pointSymbolizer.geometry = this.geometry == null ? null : this.geometry.clone();
			return pointSymbolizer;
		}
		
		override public function get sld():String {
			var res:String = "<sld:PointSymbolizer>\n";
			if(this.geometry) {
				res += this.geometry.sld;
			}
			if(this.graphic) {
				res += this.graphic.sld;
			}
			res+="</sld:PointSymbolizer>";
			return res;
		}
		
		override public function set sld(sldRule:String):void {
			use namespace sldns;
			super.sld = sldRule;
			if(this._graphic)
				this._graphic = null;
			var dataXML:XML = new XML(sldRule);
			var childs:XMLList = dataXML.Graphic;
			if(childs[0]) {
				this.graphic = new Graphic();
				this.graphic.sld = childs[0].toString();
			}
		}
	}
}