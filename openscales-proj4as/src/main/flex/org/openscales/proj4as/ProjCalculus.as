package org.openscales.proj4as
{
	import flash.geom.Point;

	public class ProjCalculus
	{
		public function ProjCalculus()
		{
		}
		
		/**
		 * VincentyConstants
		 * Constants for Vincenty functions.
		 */
		public static var vincentyConstantA:Number = 6378137;
		public static var vincentyConstantB:Number = 6356752.3142;
		public static var vincentyConstantF:Number = 1/298.257223563;
		
		/**
		 * Given two objects representing points with geographic coordinates, this
		 *     calculates the distance between those points on the surface of an
		 *     ellipsoid.
		 *
		 * Returns:
		 * The distance (in km) between the two input points as measured on an
		 *     ellipsoid.  Note that the input point objects must be in geographic
		 *     coordinates (decimal degrees) and the return distance is in kilometers.
		 */
		public static function distVincenty(p1:Point, p2:Point):Number
		{
			var a:Number = vincentyConstantA;
			var b:Number = vincentyConstantB; 
			var f:Number = vincentyConstantF;
			
			var L:Number = degtoRad(p2.x - p1.x);
			var U1:Number = Math.atan((1-f) * Math.tan(degtoRad(p1.y)));
			var U2:Number = Math.atan((1-f) * Math.tan(degtoRad(p2.y)));
			var sinU1:Number = Math.sin(U1);
			var cosU1:Number = Math.cos(U1);
			var sinU2:Number = Math.sin(U2);
			var cosU2:Number = Math.cos(U2);
			var lambda:Number = L;
			var lambdaP:Number = 2*Math.PI;
			var iterLimit:Number = 20;
			while (Math.abs(lambda-lambdaP) > 1e-12 && --iterLimit>0) {
				var sinLambda:Number = Math.sin(lambda)
				var cosLambda:Number = Math.cos(lambda);
				var sinSigma:Number = Math.sqrt((cosU2*sinLambda) * (cosU2*sinLambda) +
					(cosU1*sinU2-sinU1*cosU2*cosLambda) * (cosU1*sinU2-sinU1*cosU2*cosLambda));
				if (sinSigma==0) {
					return 0;  // co-incident points
				}
				var cosSigma:Number = sinU1*sinU2 + cosU1*cosU2*cosLambda;
				var sigma:Number = Math.atan2(sinSigma, cosSigma);
				var alpha:Number = Math.asin(cosU1 * cosU2 * sinLambda / sinSigma);
				var cosSqAlpha:Number = Math.cos(alpha) * Math.cos(alpha);
				var cos2SigmaM:Number = cosSigma - 2*sinU1*sinU2/cosSqAlpha;
				var C:Number = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha));
				lambdaP = lambda;
				lambda = L + (1-C) * f * Math.sin(alpha) *
					(sigma + C*sinSigma*(cos2SigmaM+C*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)));
			}
			if (iterLimit==0) {
				return NaN;  // formula failed to converge
			}
			var uSq:Number = cosSqAlpha * (a*a - b*b) / (b*b);
			var A:Number = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
			var B:Number = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
			var deltaSigma:Number = B*sinSigma*(cos2SigmaM+B/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)-
				B/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)));
			var s:Number = b*A*(sigma-deltaSigma);
			var d:Number = Number(s.toFixed(3))/1000; // round to 1mm precision
			return d;
		}
		
		/**
		 * Convert degrees to radian
		 *
		 * @param val Value to convert 
		 */
		public static function degtoRad(val:Number):Number{
			return val*Math.PI/180;
		}
	}
}