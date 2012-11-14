package org.openscales.core.style.symbolizer {
	import flash.display.Graphics;
	import flash.events.EventDispatcher;
	
	import org.openscales.core.feature.Feature;

	/**
	 * Make an abstraction layer for feature rendering
	 */
	public class Symbolizer extends EventDispatcher {
		
		private var _geometry:String;

		public function Symbolizer() {
		}

		/**
		 * The name of the geometry attribute of the rule that will be rendered using the symbolizer
		 */
		public function get geometry():String {

			return this._geometry;
		}

		public function set geometry(value:String):void {

			this._geometry = value;
		}

		/**
		 * Configure the <em>graphics</em> properties of a display object
		 * accordind to the symbolizer's definition
		 */
		public function configureGraphics(graphics:Graphics, feature:Feature):void {
		}
		
		public function clone():Symbolizer{
			var symbolizer:Symbolizer = new Symbolizer();
			symbolizer.geometry = this._geometry;
			return symbolizer;
		}
		
		public function get sld():String {
			return null;
		}
		
		public function set sld(sldRule:String):void {
		}

	}
}