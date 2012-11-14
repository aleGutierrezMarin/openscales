package org.openscales.core.style.symbolizer
{
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
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
		
		public function TextSymbolizer(propertyName:String=null,font:Font = null, halo:Halo = null)
		{
			super();
			this._propertyName = propertyName;
			this._font = font;
			this._halo = halo;
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
		
		public function set anchorPointYX(value:Number):void
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
			label.x += px.x-label.textWidth*_anchorPointX+_displacementX;
			label.y += px.y-label.textHeight*_anchorPointY+_displacementY;
			
			if(_labelPlacement==PointPlacementLabel) {
				label.x += px.x-label.textWidth*_anchorPointX+_displacementX;
				label.y += px.y-label.textHeight*_anchorPointY+_displacementY;
				// rotation
				if(_rotation!=0) {
					var point:Point = new Point(label.x+label.textWidth/2,label.y+label.textHeight/2);
					var m:Matrix=label.transform.matrix;
					m.tx -= point.x;
					m.ty -= point.y;
					m.rotate (45*(Math.PI/180));
					m.tx += point.x;
					m.ty += point.y;
					label.transform.matrix=m;
				}
			}
			
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
				res+="<sld:PerpendicularOffset>0</sld:PerpendicularOffset>\n";
				res+="</sld:LinePlacement>\n";
				res+="</sld:LabelPlacement>\n";
			}
			
			var fill:Fill;
			if(this._font) {
				res+="<sld:Font>\n";
				res+="<sld:CssParameter name=\"font-family\">"+font.family+"</sld:CssParameter>\n";
				res+="<sld:CssParameter name=\"font-size\">"+font.size+"</sld:CssParameter>\n";
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
				res+="<sld:Radius><ogc:Literal>"+this._halo.radius+"</ogc:Literal><sld:Radius>\n";
				fill = new SolidFill(halo.color,halo.opacity);
				res+=fill.sld+"\n";
				res+="</sld:Halo>\n";
			}
			if(this._font) {
				fill = new SolidFill(font.color,font.opacity);
				res+=fill.sld+"\n";
			}
			
			res+="</sld:TextSymbolizer>";
			return res;
		}
		
		override public function set sld(sldRule:String):void {
			use namespace sldns;
			use namespace ogcns;
			
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
				childs = node.CssParameter;
				for each(node in childs) {
					if(node.@name == "font-family") {
						this._font.family = node[0].toString();
					} else if(node.@name == "font-weight") {
						if(node[0].toString().toLowerCase()=="bold")
							this._font.weight = Font.BOLD;
					}
					else if(node.@name == "font-style") {
						if(node[0].toString().toLowerCase()=="italic")
							this._font.style = Font.ITALIC;
					}
					else if(node.@name == "font-size") {
						this._font.size = node[0].toString();
					}
				}
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
						this._anchorPointX = Number(childs[0][0]);
						childs = subNode.AnchorPointY;
						this._anchorPointY = Number(childs[0][0]);
					}
					childs = node.AnchorPoint;
					if(childs.length()>0) {
						subNode = childs[0];
						childs = subNode.DisplacementX;
						this._displacementX = Number(childs[0][0]);
						childs = subNode.DisplacementY;
						this._displacementY = Number(childs[0][0]);
					}
				} else {
					childs = node.LinePlacement;
					if(childs.length()>0) {
						this._labelPlacement = LinePlacementLabel;
					}
				}
			}
			
			childs = dataXML.Halo;
			if(childs.length()>0) {
				this._halo = new Halo();
				dataXML = childs[0];
				childs = dataXML.Radius;
				if(childs.length()>0) {
					node = childs[0];
					childs = node.Literal;
					if(childs.length()>0)
						this._halo.radius = Number(childs[0]);
				}
				childs = dataXML.Fill;
				if(childs.length()>0) {
					dataXML = childs[0];
					childs = dataXML.CssParameter;
					for each(node in childs) {
						if(node.@name == "fill") {
							this._halo.color = parseInt(node[0].toString().replace("#",""),16);
						} else if(node.@name == "fill-opacity") {
							this._halo.opacity = Number(node[0].toString());
						}
					}
				}
			}
		}
	}
}