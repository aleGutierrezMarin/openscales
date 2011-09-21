package org.openscales.core.measure
{
	import org.openscales.core.Map;

	public interface IMeasure
	{
		/**
		 * Set the map linked to the measure tool  
		 * 
		 */
		function get map():Map;
		/**
		 * @private
		 */
		function set map(value:Map):void;
		
		function getMeasure():String;
		
		function getUnits():String;
	}
}