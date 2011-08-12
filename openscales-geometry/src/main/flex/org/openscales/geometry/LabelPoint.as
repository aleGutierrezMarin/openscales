package org.openscales.geometry
{
	import org.openscales.geometry.basetypes.Bounds;
	import spark.components.Label;
	
	/**
	 * Description of the class
	 */
	public class LabelPoint extends Geometry
	{
		private var _label:Label = new Label();
		
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
			this._label.x = x;
			this._label.y = y;
			this._label.text = text;
		}
		
		/**
		 * @inherits
		 */
		override public function clone():Geometry{
			return new LabelPoint(this._label.text, this._label.x, this._label.y);
		}
		
		/**
		 * @inherits
		 */
		override public function calculateBounds():void{
			this._bounds = new Bounds(this._label.x, this._label.y, this._label.x, this._label.y, this.projSrsCode);
		}
		
		/**
		 * Coordinates getters and setters
		 */
		public function get x():Number{
			return this._label.x;
		}
		public function set x(value:Number):void{
			this._label.x = value;
		}
		
		public function get y():Number{
			return this._label.y;
		}
		public function set y(value:Number):void{
			this._label.y = value;
		}
		
	}
}