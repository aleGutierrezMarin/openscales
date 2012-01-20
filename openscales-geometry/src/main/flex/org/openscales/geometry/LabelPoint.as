package org.openscales.geometry
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * Description of the class
	 */
	public class LabelPoint extends Geometry
	{
		private var _x:Number = NaN;
		private var _y:Number = NaN;
		private var _label:TextField = new TextField();
		
		/**
		 * Constructor class
		 * 
		 * @param text
		 * @param x
		 * @param y
		 */
		public function LabelPoint(text:String=null, x:Number=NaN, y:Number=NaN)
		{
			super();
			this._x = x;
			this._y = y;
			this._label.selectable = true;
			this._label.mouseEnabled = false;
			this._label.autoSize = flash.text.TextFieldAutoSize.CENTER;
			if(text)
				this._label.text = text;
			else
				this._label.text = "";
		}
		
		/**
		 * @inherits
		 */
		override public function clone():Geometry{
			var cloneLabelPoint:LabelPoint = new LabelPoint(this._label.text, this._x, this._y);
			cloneLabelPoint.projection = this.projection;
			return cloneLabelPoint;
		}
		
		/**
		 * @inherits
		 */
		override public function calculateBounds():void{
			this._bounds = new Bounds(this._x, this._y, this._x, this._y, this.projection);
		}
		
		public function updateBounds(left:Number,bottom:Number,right:Number,top:Number,proj:ProjProjection):void{
			this._bounds = new Bounds(left,bottom,right,top,proj);
		}
		
		/**
		 * Coordinates getters and setters
		 */
		public function get x():Number{
			return this._x;
		}
		public function set x(value:Number):void{
			this._x = value;
		}
		
		public function get y():Number{
			return this._y;
		}
		public function set y(value:Number):void{
			this._y = value;
		}
		
		/**
		 * To get the associated TextField
		 */
		public function get label():TextField{
			return this._label;
		}
	}
}