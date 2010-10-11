package org.openscales.proj4as.proj {

	import org.openscales.proj4as.ProjPoint;

	/**
	 * Basic projection interface implemented by all projections
	 */
	public interface IProjection {
		function init():void

		function forward(p:ProjPoint):ProjPoint

		function inverse(p:ProjPoint):ProjPoint

	}
}