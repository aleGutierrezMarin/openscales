package org.openscales.core.style.fill
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.style.graphic.Graphic;
	
	public class GraphicFill implements Fill
	{
		private namespace sldns="http://www.opengis.net/sld";
		private var _graphic:Graphic;
		public function GraphicFill(graphic:Graphic = null)
		{
			if(graphic)
				this._graphic = _graphic;
			else
				this._graphic = new Graphic();
		}
		
		public function configureGraphics(graphics:Graphics, feature:Feature):void
		{
			var bitmap:Bitmap = null;
			if(this._graphic) {
				var source:DisplayObject = this._graphic.getDisplayObject(feature, true);
				var size:Number = this._graphic.getSizeValue(feature);
				var bitmapData:BitmapData = new BitmapData( size , size , true, 0x0 );
				bitmapData.draw( source, null, null, null, null, true );
				graphics.beginBitmapFill(bitmapData, null, true, true);
			}
		}
		
		public function clone():Fill
		{
			return new GraphicFill(this._graphic.clone());
		}
		
		public function get sld():String
		{
			var res:String = "<sld:Fill>\n";
			res+="<sld:GraphicFill>\n";
			if(this._graphic)
				res+=this._graphic.sld;
			res+="</sld:GraphicFill>\n";
			res+="</sld:Fill>\n";
			return res;
		}
		
		public function set sld(sld:String):void
		{
			use namespace sldns;
			if(this._graphic)
				this._graphic = null;
			var dataXML:XML = new XML(sld);
			var childs:XMLList = dataXML.GraphicFill;
			if(childs[0]) {
				dataXML = childs[0];
				childs = dataXML.Graphic;
				if(childs[0]) {
					this._graphic = new Graphic();
					this._graphic.sld = childs[0].toString();
				}
			}
		}

		public function get graphic():Graphic
		{
			return _graphic;
		}

		public function set graphic(value:Graphic):void
		{
			_graphic = value;
		}

	}
}