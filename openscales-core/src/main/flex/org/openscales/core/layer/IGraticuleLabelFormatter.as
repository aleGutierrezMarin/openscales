package org.openscales.core.layer
{
	/**
	 * An interface for formatting Graticule's label
	 */ 
	public interface IGraticuleLabelFormatter
	{
		/**
		 * Format the given coordinate.
		 * 
		 * @param coordinate The coordinates to format
		 * @param interval The interval between two coordinates
		 * @param axis X or Y
		 * @return A formatted String
		 */ 
		function format(coordinate:Number,interval:Number,axis:String):String;
	}
}