package org.openscales.core.feature {
	import flash.display.Bitmap;
	
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.graphic.ExternalGraphic;
	import org.openscales.core.style.marker.DisplayObjectMarker;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.Point;

	/**
	 * A Marker is an graphical element localized by a LonLat
	 *
	 * As Marker extends Feature, markers are generally added to FeatureLayer
	 */
	public class Marker extends PointFeature {

		private var _graphic:Bitmap;

		/**
		 * Boolean used to know if that marker has been draw. This is used to draw markers only
		 *  when all the map and layer stuff are ready
		 */
		private var _drawn:Boolean = false;

		/**
		 * The image that will be drawn at the feature localization
		 */
		[Embed(source="/assets/images/marker-blue.png")]
		private var _image:Class;

		/**
		 * Marker constructor
		 */
		public function Marker(geom:Point=null, data:Object=null, style:Style=null) {
			super(geom, data, style);
			this._graphic = new this._image();
			
		}
		
		private function setStyle():void {
			var rule:Rule = new Rule();
			var symbolizer:PointSymbolizer = new PointSymbolizer();
			var extGraphic:ExternalGraphic = new ExternalGraphic();
			extGraphic.clip = this._graphic;
			extGraphic.xOffset = -11;
			extGraphic.yOffset = -25;
			symbolizer.graphic.size = 16;
			symbolizer.graphic.graphics.push(extGraphic);
			rule.symbolizers.push(symbolizer);
			this.style = new Style();
			this.style.rules.push(rule);
		}
		
		public function get image():Class {
			return this._image;
		}

		public function set image(value:Class):void {
			this._image = value;
			this._graphic = null;
			if(this._image) {
				this._graphic = new this._image();
			}
			this.setStyle();
			this._drawn = false;
		}

		/**
		 * To obtain feature clone
		 * */
		override public function clone():Feature {
			var geometryClone:Geometry = this.geometry.clone();
			var MarkerClone:Marker = new Marker(geometryClone as Point, null, this.style);
			MarkerClone._originGeometry = this._originGeometry;
			// FixMe: data and image are not managed
			MarkerClone.layer = this.layer;
			return MarkerClone;
		}
	}
}

