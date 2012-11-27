package org.openscales.core.style.symbolizer {
	import flash.display.Graphics;
	import flash.events.EventDispatcher;
	
	import org.openscales.core.feature.Feature;

	/**
	 * Make an abstraction layer for feature rendering
	 */
	public class Symbolizer extends EventDispatcher {
		private namespace sldns="http://www.opengis.net/sld";
		private var _geometry:Geometry = null;

		public function Symbolizer() {
		}

		/**
		 * The name of the geometry attribute of the rule that will be rendered using the symbolizer
		 */
		public function get geometry():Geometry {

			return this._geometry;
		}

		public function set geometry(value:Geometry):void {

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
			symbolizer.geometry = this._geometry.clone();
			return symbolizer;
		}
		
		public function get sld():String {
			return "";
		}
		
		public function set sld(sldRule:String):void {
			use namespace sldns;
			if(this.geometry)
				this.geometry = null;
			var dataXML:XML = new XML(sldRule);
			var childs:XMLList = dataXML.Geometry;
			if(childs[0]) {
				this.geometry = new Geometry();
				this.geometry.sld = childs[0].toString();
			}
		}

	}
}