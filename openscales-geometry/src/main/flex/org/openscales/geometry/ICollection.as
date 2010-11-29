package org.openscales.geometry
{
	/**
	 * A Collection is exactly what it sounds like: A collection of different Geometries.
	 * These are stored in the local parameter components (which can be passed as a parameter
	 * to the constructor).
	 *
	 * The getArea and getLength functions here merely iterate through the components,
	 * summing their respective areas and lengths.
	 */
	public interface ICollection
	{
		function addPoints(components:Vector.<Number>):void;
		function addComponents(components:Vector.<Geometry>):void;
		function addComponent(component:Geometry, index:Number = NaN):Boolean;
		function get componentsLength():int;
		function componentByIndex(i:int):Geometry;
		function replaceComponent(index:int, component:Geometry):Boolean;
		function removeComponents(components:Array):Boolean;
		function removeComponent(component:Geometry):Boolean;
	}
}