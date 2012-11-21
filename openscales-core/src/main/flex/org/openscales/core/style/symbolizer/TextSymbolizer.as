package org.openscales.core.style.symbolizer
{
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
		private namespace sldns="http://www.opengis.net/sld";
		private namespace ogcns="http://www.opengis.net/ogc";
		
		public static var PointPlacementLabel:uint=1;
		public static var LinePlacementLabel:uint=2;
		public static var NoLabelPlacement:uint=0;
		
		private var _font:Font = null;
		private var _halo:Halo = null;
		private var _propertyName:String = null;
		private var _rotation:Number = 0;
		private var _anchorPointX:Number = 0.5;
		private var _anchorPointY:Number = 0.5;
		private var _displacementX:int = 0;
		private var _displacementY:int = 0;
		private var _labelPlacement:uint = PointPlacementLabel;
		private var _perpendicularOffset:int = 0;
		
		public function TextSymbolizer(propertyName:String=null,font:Font = null, halo:Halo = null)
		{
			super();
			this._propertyName = propertyName;
			this._font = font;
			this._halo = halo;
		}
		
		/**
		 * Indicates the perpendicular offset used by LinePlacement
		 */
		public function get perpendicularOffset():int
		{
			return _perpendicularOffset;
		}
		
		public function set perpendicularOffset(value:int):void
		{
			_perpendicularOffset = value;
		}
		
		/**
		 * Indicates the type of label placement
		 */
		public function get labelPlacement():uint
		{
			return _labelPlacement;
		}

		public function set labelPlacement(value:uint):void
		{
			_labelPlacement = value;
		}

		public function get displacementX():int
		{
			return _displacementX;
		}
		
		public function set displacementX(value:int):void
		{
			_displacementX = value;
		}
		
		public function get displacementY():int
		{
			return _displacementY;
		}

		public function set displacementY(value:int):void
		{
			_displacementY = value;
		}

		/**
		 * Indicates X positionning of the label. It should be a value in [0,1]. Default, 0.5 (centered)
		 */
		public function get anchorPointX():Number
		{
			return _anchorPointX;
		}

		public function set anchorPointX(value:Number):void
		{
			_anchorPointX = value;
		}
		
		/**
		 * Indicates Y positionning of the label. It should be a value in [0,1]. Default, 0.5 (centered)
		 */
		public function get anchorPointY():Number
		{
			return _anchorPointY;
		}
		
		public function set anchorPointY(value:Number):void
		{
			_anchorPointY = value;
		}

		/**
		 * Indicates the rotation of the label.
		 */ 
		public function get rotation():Number
		{
			return _rotation;
		}

		public function set rotation(value:Number):void
		{
			_rotation = value;
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
			if(this.geometry)
				s.geometry = this.geometry.clone();
			s.anchorPointX = this.anchorPointX;
			s.anchorPointY = this.anchorPointY;
			s.displacementX = this.displacementX;
			s.displacementY = this.displacementY;
			s.labelPlacement = this.labelPlacement;
			s.perpendicularOffset = this.perpendicularOffset;
			s.propertyName = this.propertyName;
			s.rotation = this.rotation;
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
			
			// let's compute the center of the label
			var loc:Location = f.geometry.bounds.center;
			var px:Pixel = f.layer.getLayerPxForLastReloadedStateFromLocation(loc);
			
			f.addChild(getTextField(text,px));
		}
		
		public function getTextField(text:String,px:Pixel):TextField {
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
			
			if(_labelPlacement==PointPlacementLabel) {
				// rotation
				if(_rotation!=0) {
					//fix rotation without embeded fonts!
				}
				label.x = px.x-label.textWidth*_anchorPointX+_displacementX;
				label.y = px.y-label.textHeight*_anchorPointY+_displacementY;
			} else {
				label.x = px.x-label.textWidth/2;
				label.y = px.y-label.textHeight/2;
				
			}
			return label;
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
			if(this.geometry) {
				res += this.geometry.sld;
			}
			res+="<sld:Label>\n";
			res+="<ogc:PropertyName>"+this.propertyName+"</ogc:PropertyName>\n";
			res+="</sld:Label>\n";
			
			if(_labelPlacement==PointPlacementLabel) {
				res+="<sld:LabelPlacement>\n";
				res+="<sld:PointPlacement>\n";
				res+="<sld:Rotation>"+this._rotation+"</sld:Rotation>\n";
				res+="<sld:Displacement>\n";
				res+="<sld:DisplacementX>"+this._displacementX+"</sld:DisplacementX>\n";
				res+="<sld:DisplacementY>"+this._displacementY+"</sld:DisplacementY>\n";
				res+="</sld:Displacement>\n";
				res+="<sld:AnchorPoint>\n";
				res+="<sld:AnchorPointX>"+this._anchorPointX+"</sld:AnchorPointX>\n";
				res+="<sld:AnchorPointX>"+this._anchorPointY+"</sld:AnchorPointX>\n";
				res+="</sld:AnchorPoint>\n";
				res+="</sld:PointPlacement>\n";
				res+="</sld:LabelPlacement>\n";
			} else if(_labelPlacement==LinePlacementLabel) {
				res+="<sld:LabelPlacement>\n";
				res+="<sld:LinePlacement>\n";
				res+="<sld:PerpendicularOffset>"+this._perpendicularOffset+"</sld:PerpendicularOffset>\n";
				res+="</sld:LinePlacement>\n";
				res+="</sld:LabelPlacement>\n";
			}

			if(this._font) {
				res+=this.font.sld;
			}
			if(this._halo) {
				res+=this._halo.sld;
			}
			if(this._font) {
				var fill:SolidFill = new SolidFill(font.color,font.opacity);
				res+=fill.sld+"\n";
			}
			res+="</sld:TextSymbolizer>";
			return res;
		}
		
		override public function set sld(sldRule:String):void {
			use namespace sldns;
			use namespace ogcns;
			super.sld = sldRule;
			
			this._font = new Font();
			this._halo = null;
			this._labelPlacement=NoLabelPlacement;
			this._rotation = 0;
			this._anchorPointX = 0;
			this._anchorPointY = 0;
			this._displacementX = 0;
			this._displacementY = 0;
			
			var dataXML:XML = new XML(sldRule);
			var childs:XMLList = dataXML..*::PropertyName;
			
			if(childs.length()>0) {
				this.propertyName = childs[0];
			}
			
			childs = dataXML.Font;
			var node:XML;
			if(childs.length()>0) {
				node = childs[0];
				this._font.sld = node.toString();
			}

			childs = dataXML.Fill;
			var sFill:SolidFill = null;
			if(childs.length()>0) {
				node = childs[0];
				sFill = new SolidFill();
				sFill.sld = node.toString();
				this._font.color = sFill.color as Number;
				this._font.opacity = sFill.opacity;
			}
			
			childs = dataXML.Halo;
			if(childs.length()>0) {
				this._halo = new Halo();
				node = childs[0];
				this._halo.sld = node.toString();
			}
			
			childs = dataXML.LabelPlacement;
			if(childs.length()>0) {
				node = childs[0];
				childs = node.PointPlacement;
				if(childs.length()>0) {
					this._labelPlacement=PointPlacementLabel;
					node = childs[0];
					childs = node.Rotation;
					var subNode:XML;
					if(childs.length()>0) {
						subNode = childs[0];
						this.rotation = Number(node[0]);
					}
					childs = node.AnchorPoint;
					if(childs.length()>0) {
						subNode = childs[0];
						childs = subNode.AnchorPointX;
						if(childs.length()>0)
							this._anchorPointX = Number(childs[0][0]);
						childs = subNode.AnchorPointY;
						if(childs.length()>0)
							this._anchorPointY = Number(childs[0][0]);
					}
					childs = node.Displacement;
					if(childs.length()>0) {
						subNode = childs[0];
						childs = subNode.DisplacementX;
						if(childs.length()>0)
							this._displacementX = Number(childs[0][0]);
						childs = subNode.DisplacementY;
						if(childs.length()>0)
							this._displacementY = Number(childs[0][0]);
					}
				} else {
					childs = node.LinePlacement;
					if(childs.length()>0) {
						this._labelPlacement = LinePlacementLabel;
						subNode = childs[0];
						childs = subNode.PerpendicularOffset;
						if(childs.length()>0) {
							this._perpendicularOffset = Number(childs[0][0]);
						}
					}
				}
			}
		}
	}
}