package org.openscales.geometry.utils
{
	import org.openscales.geometry.Point;
	
	
	/**
	 * This parameter is used in order to choose if you want to calculate the distance between two points with vicenty technic or with the great circle distance, or with another way. 
	 */
	public interface IDistanceCalculator
	{
		function calculateDistanceBetweenTwoPoints(p1:Point, p2:Point):Number;
			
	}
}
