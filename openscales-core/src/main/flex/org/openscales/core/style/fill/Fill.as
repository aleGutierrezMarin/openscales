package org.openscales.core.style.fill {
	import flash.display.Graphics;
	
	import org.openscales.core.feature.Feature;

	/**
	 * Abstract class for defining how a fill is rendered
	 */
	public interface Fill {
		/**
		 * Configure the <em>graphics</em> properties of a display object
		 * so that the fill is rendered when drawing
		 */
		function configureGraphics(graphics:Graphics, feature:Feature):void;
		
		function clone():Fill;
	}
}