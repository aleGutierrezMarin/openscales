package org.openscales.core.feature
{
	import flash.display.DisplayObject;
	import flash.text.TextFormat;
	
	import org.openscales.core.style.Style;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.geometry.LabelPoint;
	import org.openscales.geometry.basetypes.Location;
	
	public class LabelFeature extends Feature
	{
		private var _font:String = "Arial";
		private var _size:Number = 12;
		private var _bold:Boolean = false;
		private var _italic:Boolean = false;
		private var _color:uint = 0x000000;
		
		/**
		 * Constructor class
		 * 
		 * @param geom
		 * @param data
		 * @param style
		 * @param isEditable
		 */
		public function LabelFeature(geom:LabelPoint=null, data:Object=null, style:Style=null, isEditable:Boolean=false)
		{
			super(geom, data, style, isEditable);
			if (!style){
				this.style = new Style();
				this.style.textFormat = new TextFormat(this._font,this._size,this._color,this._bold,this._italic);
			}
		}
		
		/**
		 * @inherits
		 */
		override public function get lonlat():Location{
			var value:Location = null;
			if(this.labelPoint != null){
				value = new Location(this.labelPoint.x, this.labelPoint.y, this.labelPoint.projSrsCode);
			}
			return value;
		}
		
		/**
		 * 
		 */
		public function set lonlat(value:Location):void{
			this.labelPoint.x = value.x;
			this.labelPoint.y = value.y;
		}
		
		/**
		 * @inherits
		 */
		override public function destroy():void{
			super.destroy();
		}
		
		/**
		 * @inherits
		 */
		override public function draw():void{
			var x:Number;
			var y:Number;
			var resolution:Number = this.layer.map.resolution.value;
			var dX:int = -int(this.layer.map.x) + this.left;
			var dY:int = -int(this.layer.map.y) + this.top;
			x = dX + labelPoint.x / resolution;
			y = dY - labelPoint.y / resolution;
			this.labelPoint.label.x = x - this.labelPoint.label.width / 2;
			this.labelPoint.label.y = y - this.labelPoint.label.height / 2;
			this.labelPoint.label.setTextFormat(this.style.textFormat);
			this.addChild(this.labelPoint.label);
		}
		
		/**
		 * To get the geometry (the LabelPoint) of the LabelFeature
		 */
		public function get labelPoint():LabelPoint{
			return this.geometry as LabelPoint;
		}
		
		/**
		 * The font of the label
		 */
		public function get font():String{
			return this._font;
		}
		public function set font(value:String):void{
			this._font = value;
			this.style.textFormat = new TextFormat(this._font,this._size,this._color,this._bold,this._italic);
		}
		
		/**
		 * The size of the label
		 */
		public function get size():Number{
			return this._size;
		}
		public function set size(value:Number):void{
			this._size = value;
			this.style.textFormat = new TextFormat(this._font,this._size,this._color,this._bold,this._italic);
		}
		
		/**
		 * To define if the label is bold or not
		 */
		public function get bold():Boolean{
			return this._bold;
		}
		public function set bold(value:Boolean):void{
			this._bold = value;
			this.style.textFormat = new TextFormat(this._font,this._size,this._color,this._bold,this._italic);
		}
		
		/**
		 * To define if the label is italic or not
		 */
		public function get italic():Boolean{
			return this._italic;
		}
		public function set italic(value:Boolean):void{
			this._italic = value;
			this.style.textFormat = new TextFormat(this._font,this._size,this._color,this._bold,this._italic);
		}
		
		/**
		 * To define the color of the label
		 */
		public function get color():uint{
			return this._color;
		}
		public function set color(value:uint):void{
			this._color = value;
			this.style.textFormat = new TextFormat(this._font,this._size,this._color,this._bold,this._italic);
		}
	}
}