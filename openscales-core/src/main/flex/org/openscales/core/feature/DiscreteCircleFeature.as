package org.openscales.core.feature
{
	import flash.geom.Point;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.style.Style;
	import org.openscales.core.utils.Util;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * A discrete circle feature wich will respect projection deformation.
	 * 
	 * You can change the discrization value, the greater the better will the circle look. Beware of performance.
	 * 
	 */ 
	public class DiscreteCircleFeature extends PolygonFeature
	{
		private static var _usedProjection:ProjProjection = ProjProjection.getProjProjection("EPSG:4326");
		
		/**
		 * @param center Center of the circle will be reprojected in ESPG:4326
		 * @param radius Radius of the circle, expressed in meters
		 */ 
		public function DiscreteCircleFeature(center:Location, radius:Number, data:Object=null, style:Style=null, isEditable:Boolean=false)
		{
			super(polygon, data, style, isEditable);
			_center = center.reprojectTo(_usedProjection);
			_radius = radius;
			os_internal::calculateGeometry();
			setAttributes();
			
		}
		
		/**
		 * To obtain a feature clone 
		 */
		override public function clone():Feature {
			var geometryClone:Geometry = this.geometry.clone();
			var clone:DiscreteCircleFeature = new DiscreteCircleFeature(_center, _radius, data, this.style, this.isEditable);
			clone._originGeometry = this._originGeometry;
			clone.layer = this.layer;
			return clone;
			
		}
		
		override public function draw():void
		{
			if(_recalculateGeometry) os_internal::calculateGeometry();
			_recalculateGeometry = false;
			super.draw();
		}
		
		
		
		os_internal function calculateGeometry():void{
			var circleLinearRing:LinearRing = new LinearRing(null,_center.projection);
			
			var angleStep:Number = 2*Math.PI/_discretization;
			var angle:Number = 0;
			var theta:Number = Util.degtoRad(center.x);
			var phi:Number =  Util.degtoRad(center.y);
			var coords:Array;
			
			while(angle < Math.PI*2){
				angle += angleStep;
				coords = Util.greatCircleDestination(phi,theta,radius,angle);
				circleLinearRing.addComponent(new org.openscales.geometry.Point(Util.radtoDeg(coords[1]),Util.radtoDeg(coords[0]),_usedProjection));
			}
			
			if(super.geometry)super.geometry.destroy();
			super.geometry = new Polygon(new <Geometry>[circleLinearRing]);
		}
		
		private function setAttributes():void{
			attributes.center = _center.x+" "+_center.y; 
			attributes.radius = _radius;
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
		
		
		private static var _discretization:Number = 32;
		
		/**
		 * The discretization number for drawing the circle (ie the number of Point instances). 
		 * 
		 * <p>The greater, the nicest will look the circle. Default is 32.</p>
		 * 
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
			setAttributes();
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
			setAttributes();
			_recalculateGeometry = true;
		}
		
	}
}