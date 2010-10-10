package org.openscales.proj4as.proj {

	import org.openscales.proj4as.ProjPoint;

	public interface IProjection {
		function init():void

		function forward(p:ProjPoint):ProjPoint

		function inverse(p:ProjPoint):ProjPoint

	}
}