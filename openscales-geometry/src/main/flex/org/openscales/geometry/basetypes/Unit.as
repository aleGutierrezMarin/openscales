package org.openscales.geometry.basetypes
{
	import flash.system.Capabilities;
	
	import org.openscales.geometry.utils.UtilGeometry;
	
	/**
	 * The map unit
	 *
	 * @author Bouiaw
	 */
	public class Unit
	{
		public static var SEXAGESIMAL:String = "dms";
		public static var DEGREE:String = "degrees";
		public static var METER:String = "m";
		public static var KILOMETER:String = "km";
		public static var CENTIMETER:String = "cm";
		public static var FOOT:String = "ft";
		public static var MILE:String = "mi";
		public static var INCH:String = "inch";
		
		public static var PIXEL_SIZE:Number = 0.00028;
		
		public static var DOTS_PER_INCH:Number = Capabilities.screenDPI;
		
		/**
		 * Returns the number of inches per unit
		 * 
		 * @param the unit
		 * @return the number of inches
		 */
		public static function getInchesPerUnit(unit:String):Number {
			switch(unit) {
				case Unit.INCH:
					return 1.0;
					break;
				case Unit.FOOT:
					return 12.0;
					break;
				case Unit.MILE:
					return 63360.0;
					break;
				case Unit.METER:
					return 39.3700787;
					break;
				case Unit.KILOMETER:
					return 39370.0787;
					break;
				case Unit.DEGREE:
					return 4374754;
					break;
				default:
					return 0;
			}
		}
		
		/**
		 * Returns the number of meters per unit
		 * 
		 * @param the unit
		 * @return the number of meters
		 */
		public static function getMetersPerUnit(unit:String):Number {
			switch(unit){
				case Unit.DEGREE:
					return 111195.0;
				case Unit.METER:
					return 1;
				case Unit.FOOT:
					return 0.3048;
				default:
					return 0;
			}
		} 
		
		/**
		 * Returns the resolution from a scale
		 * 
		 * @param the scale
		 * @param the unit, if not specified Unit.DEGREE is used
		 * @return the resolution
		 */
		public static function getResolutionFromScale(scale:Number, units:String = null):Number {
			
			if (units == null) {
				units = Unit.DEGREE;
			}
			
			var normScale:Number = UtilGeometry.normalizeScale(scale);
			
			var resolution:Number = 1 / (normScale * Unit.getInchesPerUnit(units)
				* Unit.DOTS_PER_INCH);
			return resolution;
		}
		
		/**
		 * Returns the scale from a resolution
		 * 
		 * @param the resolution
		 * @param the unit, if not specified Unit.DEGREE is used
		 * @return the scale
		 */
		public static function getScaleFromResolution(resolution:Number, units:String, dpi:Number):Number {
			if (units == null) {
				units = Unit.DEGREE;
			}
			
			var scale:Number = resolution * Unit.getInchesPerUnit(units) * dpi;

			return scale;
		}
		
		/**
		 * Returns the resolution from a scale denominator
		 * 
		 * @param the scale denominator
		 * @param the unit, if not specified Unit.DEGREE is used
		 * @return the resolution
		 */
		public static function getResolutionFromScaleDenominator(scaleDenominator:Number, units:String = null):Number {
			if (units == null) {
				units = Unit.DEGREE;
			}
			return (scaleDenominator * Unit.PIXEL_SIZE / Unit.getMetersPerUnit(units));
		}
		
		/**
		 * Returns the scale denominator from a resolution
		 * 
		 * @param the resolution
		 * @param the unit, if not specified Unit.DEGREE is used
		 * @return the scale
		 */
		public static function getScaleDenominatorFromResolution(resolution:Number, units:String = null):Number {
			if (units == null) {
				units = Unit.DEGREE;
			}
			return (resolution * Unit.getMetersPerUnit(units) / Unit.PIXEL_SIZE);
		}
		
	}
}

