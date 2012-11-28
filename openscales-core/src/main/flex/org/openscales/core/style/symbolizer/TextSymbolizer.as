package org.openscales.core.style.symbolizer
{
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.style.fill.Fill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.font.Font;
	import org.openscales.core.style.halo.Halo;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	public class TextSymbolizer extends Symbolizer
	{
		
		private var _font:Font = null;
		private var _halo:Halo = null;
		private var _propertyName:String = null;
		private var _xOffset:Number = 0;
		private var _yOffset:Number = 0;
		
		public function TextSymbolizer(propertyName:String=null,font:Font = null, halo:Halo = null)
		{
			super();
			this._propertyName = propertyName;
			this._font = font;
			this._halo = halo;
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
			if(this._halo)
				s.halo = this._halo.clone();
			return s;
		}
		
		/**
		 * 
		 */
		public function drawTextField(f:Feature, text:String = null):void {

			if(this._propertyName && f.attributes && f.attributes[this._propertyName]) {
				text = f.attributes[this._propertyName];
			} else if(!text){
				return;
			}
			
			var label:TextField = new TextField();
			label.selectable = true;
			label.mouseEnabled = false;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.antiAliasType = AntiAliasType.ADVANCED;
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
				if(this._font.family) {
					textFormat.font = this._font.family;
				}
				label.alpha = this._font.opacity;
				label.setTextFormat(textFormat);
			}
			
			if(this._halo) {
				label.filters=[this._halo.getFilter()];
			}
			
			// on calcul le centre et on place le label
			var loc:Location = f.geometry.bounds.center;
			//var px:Pixel = f.layer.map.getMapPxFromLocation(loc);
			var px:Pixel = f.layer.getLayerPxForLastReloadedStateFromLocation(loc);
			label.x += px.x-label.textWidth/2 + this._xOffset;
			label.y += px.y-label.textHeight/2 + this._yOffset;
			f.addChild(label);
		}
		/**
		 * halo
		 */
		public function get halo():Halo
		{
			return _halo;
		}
		/**
		 * @private
		 */
		public function set halo(value:Halo):void
		{
			_halo = value;
		}
		
		override public function get sld():String {
			var res:String = "<sld:TextSymbolizer>\n";
			res+="<sld:Label>\n";
			res+="<ogc:PropertyName>"+this.propertyName+"</ogc:PropertyName>\n";
			res+="</sld:Label>\n";
			var fill:Fill;
			if(this._font) {
				res+="<sld:Font>\n";
				res+="<sld:CssParameter name=\"font-family\">"+font.family+"</sld:CssParameter>\n";
				if(font.weight == Font.BOLD) {
					res+="<sld:CssParameter name=\"font-weight\">bold</sld:CssParameter>\n";
				}
				if(font.style == Font.ITALIC) {
					res+="<sld:CssParameter name=\"font-style\">italic</sld:CssParameter>\n";
				}
				res+="</sld:Font>\n";
			}
			if(this._halo) {
				res+="<sld:Halo>\n";
				fill = new SolidFill(halo.color,halo.opacity);
				res+=fill.sld+"\n";
				res+="</sld:Halo>\n";
			}
			if(this._font) {
				fill = new SolidFill(font.color,font.opacity);
				res+=fill.sld+"\n";
			}
			//TODO : LabelPlacement
			
			res+="</sld:TextSymbolizer>";
			return res;
		}
		
		override public function set sld(sldRule:String):void {
			// parse sld
		}
		
		/**
		 * Offset that will be applied to the label display
		 */
		public function get xOffset():Number
		{
			return this._xOffset;
		}
		
		/**
		 * @private
		 */
		public function set xOffset(value:Number):void
		{
			this._xOffset = value;
		}
		
		/**
		 * Offset that will be applied to the label display
		 */
		public function get yOffset():Number
		{
			return this._yOffset;
		}
		
		/**
		 * @private
		 */
		public function set yOffset(value:Number):void
		{
			this._yOffset = value;
		}
	}
}