package org.openscales.core.feature
{
	import flash.geom.Point;
	
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * A discrete circle feature wich will respect projection deformation.
	 */ 
	public class DiscreteCircleFeature extends PolygonFeature
	{
		private static var _usedProjection:ProjProjection = ProjProjection.getProjProjection("EPSG:4326");
		
		/**
		 * @param center expressed in EPSG:3857
		 * @param radius expressed in meters
		 */ 
		public function DiscreteCircleFeature(center:Location, radius:Number, data:Object=null, style:Style=null, isEditable:Boolean=false)
		{
			_center = center.reprojectTo(_usedProjection);
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
			var circleLinearRing:LinearRing = new LinearRing(null,_center.projection);
			
			for (var i:uint=0; i <=discretization; i++) {
				var point:org.openscales.geometry.Point = destination(center.lat,center.lon,this.radius,i*2*Math.PI/discretization);
				circleLinearRing.addComponent(point);
			}
			
			if(super.geometry)super.geometry.destroy();
			super.geometry = new Polygon(new <Geometry>[circleLinearRing],circleLinearRing.projection);
		}

		private function destination(lata:Number,lona:Number,dist:Number,brng:Number):org.openscales.geometry.Point { // destination along great circle.  returns values in degrees
			var latSrc:Number =  lata * Math.PI/180;
			var lonSrc:Number = lona * Math.PI/180;
			
			var latRes:Number = Math.asin(Math.sin(latSrc)*Math.cos(dist/6371) + Math.cos(latSrc)*Math.sin(dist/6371)*Math.cos(brng));
			var lonRes:Number = lonSrc+Math.atan2(Math.sin(brng)*Math.sin(dist/6371)*Math.cos(latSrc), Math.cos(dist/6371)-Math.sin(latSrc)*Math.sin(latRes));
			
			/*lonRes = lonRes * 180/Math.PI;
			latRes = latRes * 180/Math.PI;
			*/
			return new org.openscales.geometry.Point(lonRes,latRes,ProjProjection.getProjProjection("EPSG:4326"));
			
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
			if(_center) _center = _center.reprojectTo(_usedProjection);
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