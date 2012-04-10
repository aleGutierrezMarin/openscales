package org.openscales.core.style.symbolizer
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.style.font.Font;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	public class TextSymbolizer extends Symbolizer
	{
		
		private var _font:Font = null;
		private var _propertyName:String = null;
		
		public function TextSymbolizer(propertyName:String=null,font:Font = null)
		{
			super();
			this._propertyName = propertyName;
			this._font = font;
		}
		
		/**
		 * font style
		 */
		public function get font():Font
		{
			return _font;
		}
		/**
		 * @private
		 */
		public function set font(value:Font):void
		{
			_font = value;
		}
		/**
		 * property to display
		 */
		public function get propertyName():String
		{
			return _propertyName;
		}
		/**
		 * @private
		 */
		public function set propertyName(value:String):void
		{
			_propertyName = value;
		}
		
		/**
		 * clone
		 */
		override public function clone():Symbolizer{
			var s:TextSymbolizer = new TextSymbolizer();
			if(this._font)
				s.font = this._font.clone();
			return s;
		}
		
		/**
		 * 
		 */
		public function drawTextField(f:Feature):void {
			var text:String = null;
			if(this._propertyName && f.attributes && f.attributes[this._propertyName]) {
				text = f.attributes[this._propertyName];
			} else {
				return;
			}
			var label:TextField = new TextField();
			label.selectable = true;
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.CENTER;
			label.text = text;
			if(font) {
				var textFormat:TextFormat = new TextFormat();
				textFormat.color = this._font.color;
				textFormat.size = this._font.size;
				if(this._font.weight == Font.BOLD) {
					textFormat.bold = true;
				}
				if(this._font.style == Font.ITALIC) {
					textFormat.italic = true;
				}
				label.alpha = this._font.opacity;
				label.setTextFormat(textFormat);
			}
			// on calcul le centre et on place le label
			var loc:Location = f.geometry.bounds.center;
			//var px:Pixel = f.layer.map.getMapPxFromLocation(loc);
			var px:Pixel = f.layer.getLayerPxForLastReloadedStateFromLocation(loc);
			label.x += px.x-label.textWidth/2;
			label.y += px.y-label.textHeight/2;
			f.addChild(label);
		}
	}
}