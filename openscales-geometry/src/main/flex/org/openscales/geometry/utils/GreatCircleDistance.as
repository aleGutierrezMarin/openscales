package org.openscales.geometry.utils
{
	import flash.geom.Point;
	
	import org.openscales.geometry.Point;
	
	public class GreatCircleDistance implements IDistanceCalculator
	{
		
		public static var vincentyConstantA:Number = 6378137;
		public static var vincentyConstantB:Number = 6356752.3142;
		public static var vincentyConstantF:Number = 1/298.257223563;
		
		public function GreatCircleDistance()
		{
			
		}
		
		public function calculateDistanceBetweenTwoPoints(p1:org.openscales.geometry.Point, p2:org.openscales.geometry.Point):Number
		{
			var radius:Number = vincentyConstantA;
			var long1:Number=degtoRad(p1.x);
			var long2:Number=degtoRad(p2.x);
			var lat1:Number=degtoRad(p1.y);
			var lat2:Number=degtoRad(p2.y);
			
			var arg:Number = Math.cos(lat1) * Math.cos(lat2) * Math.cos(long1-long2) + Math.sin(lat1) * Math.sin(lat2) ;
			var distance:Number = radius* Math.acos(arg);	
			return 		distance; 		
		}
		
		public  function degtoRad(val:Number):Number{
			return val*Math.PI/180;
		}
		
	}
}