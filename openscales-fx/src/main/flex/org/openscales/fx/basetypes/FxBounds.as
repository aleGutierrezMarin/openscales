package org.openscales.fx.basetypes
{
	import mx.core.UIComponent;
	
	import org.openscales.geometry.basetypes.Bounds;

	/**
	 * Abstract Bounds Flex wrapper
	 */
	public class FxBounds extends UIComponent
	{
		private var _bounds:Bounds;	
		
		public function FxBounds()
		{
			this._bounds = new Bounds(NaN,NaN,NaN,NaN,null);
			super();
		}

		public function set west(value:Number):void {
			if(this.bounds != null)
				this.bounds.left = value;
		}

		public function set south(value:Number):void {
			if(this.bounds != null)
				this.bounds.bottom = value;
		}

		public function set east(value:Number):void {
			if(this.bounds != null)
				this.bounds.right = value;
		}

		public function set north(value:Number):void {
			if(this.bounds != null)
				this.bounds.top = value;
		}
		
		public function set projection(value:String):void {
			this._bounds.projSrsCode = value;
		}

		public function get bounds():Bounds {
			return this._bounds;
		}

	}
}