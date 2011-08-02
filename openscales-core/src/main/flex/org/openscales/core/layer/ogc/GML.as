package org.openscales.core.layer.ogc
{
	import flash.display.DisplayObject;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.GML32Format;
	import org.openscales.core.format.GMLFormat;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.Point;
	
	public class GML extends FeatureLayer
	{
		
		private var _gmlFormat:GML32Format = null;
		private var _xmlFile:XML = null;
		private var _style:Style = null;
		private var _featureVector:Vector.<Feature> = null;
		
		public function GML(name:String, 
							version:String,
							xmlFile:XML,
							projection:String,
							style:Style)
		{
			super(name);
			this.projSrsCode = projection;
			this._gmlFormat = new GML32Format(null,null);
			this._xmlFile = xmlFile;
			this._style = style;
			this._style.rules.push(new Rule());
		
		}
		
		override protected function draw():void{
			if(this._featureVector == null && this._xmlFile) {
				featureVector = this._gmlFormat.parseGmlFile(this._xmlFile);
				var i:uint;
				var vectorLength:uint = this.featureVector.length;
				for (i = 0; i < vectorLength; i++){
					_featureVector[i].style = this._style;
					this.addFeature(_featureVector[i]);
				}
			} else {
				super.draw();
			}
		}

		public function get featureVector():Vector.<Feature>
		{
			return _featureVector;
		}

		public function set featureVector(value:Vector.<Feature>):void
		{
			_featureVector = value;
		}
		
		
		
	}
}