package org.openscales.core.layer
{
	/**
	 * The default coordinate formatter for Graticule labels
	 */ 
	public class DefaultGraticuleLabelFormatter implements IGraticuleLabelFormatter
	{
		public function DefaultGraticuleLabelFormatter()
		{
		}
		
		/**
		 * Format the coordinate by changing its precision based on given interval. 
		 * 
		 * <p>Precision is 4 by default and rises to 5 if the interval is lower than 0.01 degrees. Then the following is applied:</p>
		 * <ul>
		 * <li>If coordinates is lower than -10 and greater than 10 degrees then precison is unchanged</li>
		 * <li>Else if coordinates is lower than -1 and greater than 1 degrees then precison 3 (or 4)</li>
		 * <li>Else precison is 2 (or 3)</li>
		 * </ul>
		 */ 
		public function format(coordinate:Number, interval:Number,axis:String):String
		{
			var result:String = null;
			var precision:uint = 4;
			if (interval < 0.01) {
				precision = 5;
			}
			if (coordinate > 10 || coordinate < -10) {
				result = coordinate.toPrecision(precision) + " °";
			}
			else {
				if (coordinate >= 1 || coordinate <= -1) {
					result = coordinate.toPrecision(precision-1) + " °";
				}
				else {
					result = coordinate.toPrecision(precision-2) + " °";
				}
			}
			return result;
		}
	}
}