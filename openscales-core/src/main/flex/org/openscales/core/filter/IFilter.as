package org.openscales.core.filter {
	import org.openscales.core.feature.Feature;

	/**
	 * An interface for feature filters
	 */
	public interface IFilter {

		function matches(feature:Feature):Boolean;
		
		function clone():IFilter;
		
		function get sld():String;
		function set sld(sld:String):void;
	}
}