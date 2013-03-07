package org.openscales.core.feature
{
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;
	
	/**
	 * A discrete circle feature wich will respect projection deformation.
	 */ 
	public class DiscreteCircleFeature extends PolygonFeature
	{
		/**
		 * @param center expressed in EPSG:3857
		 * @param radius expressed in meters
		 */ 
		public function DiscreteCircleFeature(center:Location, radius:Number, data:Object=null, style:Style=null, isEditable:Boolean=false)
		{
			_center = center.reprojectTo("EPSG:3857");
			_radius = radius;
			calculateGeometry();
			super(polygon, data, style, isEditable);
		}
		
		/**
		 * To obtain feature clone
		 * */
		override public function clone():Feature {
			var geometryClone:Geometry = this.geometry.clone();
			var clone:DiscreteCircleFeature = new DiscreteCircleFeature(_center, _radius, data, this.style, this.isEditable);
			clone._originGeometry = this._originGeometry;
			clone.layer = this.layer;
			return clone;
			
		}
		
		override public function draw():void
		{
			if(_recalculateGeometry) calculateGeometry();
			_recalculateGeometry = false;
			super.draw();
		}
		
		
		
		private function calculateGeometry():void{
			center = center.reprojectTo("EPSG:3857");
			var circleLinearRing:LinearRing = new LinearRing(null,center.projection);
			
			var discretizationAngle:Number = 360/discretization;
			
			for(var i:uint=0;i<discretization;++i){
				var angle:Number = discretizationAngle*i;
				//trace("Angle :"+angle);
				var radian:Number = angle*Math.PI/180;
				
				var x:Number = center.x + (_radius * Math.cos(radian));
				var y:Number = center.y + (_radius * Math.sin(radian));
				var point:org.openscales.geometry.Point = new org.openscales.geometry.Point(x,y,center.projection);
				circleLinearRing.addComponent(point);
			}
			
			if(super.geometry)super.geometry.destroy();
			super.geometry = new Polygon(new <Geometry>[circleLinearRing],circleLinearRing.projection);
		}

		private var _recalculateGeometry:Boolean = false;

		/**
		 * Flag to recalculate the geomtry on next redraw
		 */
		public function get recalculateGeometry():Boolean
		{
			return _recalculateGeometry;
		}

		/**
		 * @private
		 */
		public function set recalculateGeometry(value:Boolean):void
		{
			_recalculateGeometry = value;
		}

		
		private static var _discretization:Number = 48;

		/**
		 * The discretization number for drawing the circle. The greater, the nicest will look the circle. Default is 48.
		 */
		public static function get discretization():Number
		{
			return _discretization;
		}

		/**
		 * @private
		 */
		public static function set discretization(value:Number):void
		{
			_discretization = value;
		}

		
		private var _center:Location;

		/**
		 * Center of the circle. Is expressed in EPSG:3857
		 */
		public function get center():Location
		{
			return _center;
		}

		/**
		 * @private
		 */
		public function set center(value:Location):void
		{
			_center = value;
			if(_center) _center = _center.reprojectTo("EPSG:3857");
			_recalculateGeometry = true;
		}

		
		private var _radius:Number;

		/**
		 * Radius of the circle. Is expressed in meter
		 */
		public function get radius():Number
		{
			return _radius;
		}

		/**
		 * @private
		 */
		public function set radius(value:Number):void
		{
			_radius = value;
			_recalculateGeometry = true;
		}

	}
}