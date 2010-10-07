package org.openscales.fx.basetypes
{
	import mx.core.UIComponent;
	
	import org.openscales.basetypes.Bounds;
	import org.openscales.proj4as.ProjProjection;

	public class FxBounds extends UIComponent
	{
		private var _bounds:Bounds;	
		
		public function FxBounds()
		{
			this._bounds = new Bounds();
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
		
		public function set projection(proj:String):void {
			this._bounds.projection = ProjProjection.getProjProjection(proj);
		}

		public function get bounds():Bounds {
			return this._bounds;
		}

	}
}