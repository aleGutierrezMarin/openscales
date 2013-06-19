package org.openscales.core.format.geojson.mapfish
{
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LabelFeature;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.geojson.GeoJSONFormat;
	import org.openscales.core.json.GENERICJSON;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.style.symbolizer.TextSymbolizer;

	/**
	 * Class used to convert a VectorLayer to a GeoJSON Vector Object.
	 * Used with MapFish Print module wich use GeoJSON format to print vector layers.
	 * 
	 * @author David LACHICHE
	 */
	public class MapFishGeoJSONFormat extends Format
	{
		/**
		 * Vector layer opacity, set by default to 1.
		 */
		private var layerOpacity:Number = 1;
		
		/**
		 * Vector layer name, set by default to 'vector'.
		 */
		private var layerName:String = "vector";
		
		private const VECTOR_LAYER_TYPENAME:String = "vector";
		
		public function MapFishGeoJSONFormat(vectorLayer:VectorLayer)
		{
			if (vectorLayer != null)
			{
				layerOpacity = vectorLayer.alpha;
			}
		}
		
		override public function write(features:Object):Object
		{
			// Convert the feature object
			var listOfFeatures:Vector.<Feature> = features as Vector.<Feature>;
			var numberOfFeatures:int = listOfFeatures.length;
			
			var geojsonObject:Object = new Object();
			geojsonObject.type = this.VECTOR_LAYER_TYPENAME;
			
			geojsonObject.opacity = layerOpacity;
			geojsonObject.name = layerName;
			
			var format:GeoJSONFormat = new GeoJSONFormat();
			geojsonObject.geoJson = format.write(features);
			
			// Construct the style for each feature
			var styles:Object = new Object();
			for (var i:int = 0; i < numberOfFeatures; i++)
			{
				var f:Feature = features[i] as Feature;
				styles["" + f.style.name] = getStyleFromFeature(f);
			}
			
			geojsonObject.styles = styles;
			geojsonObject.styleProperty = "_style";
			
			return GENERICJSON.encode(geojsonObject);
		}
		
		private function getStyleFromFeature(feature:Feature):Object
		{
			var objectStyle:Object = new Object();
			
			var featureStyle:Style = feature.style;
			var rules:Vector.<Rule> = featureStyle.rules;
			
			var symbolizers:Vector.<Symbolizer> = null;
			
			if (rules.length > 0)
			{
				symbolizers = rules[0].symbolizers;
			}
			
			if (!symbolizers)
			{
				return null;
			}
			
			var symbLength:int = symbolizers.length;
			
			for (var i:int = 0; i < symbLength; i++)
			{
				var symb:Symbolizer = symbolizers[i];
				if (symb is TextSymbolizer)
				{
					var ts:TextSymbolizer = symb as TextSymbolizer;
					objectStyle.label = (feature as LabelFeature).text;
					objectStyle.labelAlign = "cm";
					if (ts.font)
					{
						objectStyle.fontColor = ts.font.color;
						objectStyle.fontOpacity = ts.font.opacity;
						objectStyle.fontFamily = ts.font.family;
						objectStyle.fontSize = ts.font.size;
						objectStyle.fontStyle = ts.font.style;
						objectStyle.fontWeight = ts.font.weight;
					}
					if (ts.halo)
					{
						objectStyle.labelOutlineColor = ts.halo.color;
						objectStyle.labelOutlineWidth = ts.halo.radius;
						objectStyle.labelOutlineOpacity = ts.halo.opacity;
					}
					
				}
				else if (symb is LineSymbolizer)
				{
					var ls:LineSymbolizer = symb as LineSymbolizer;
					objectStyle.strokeColor = ls.stroke.color;
					objectStyle.strokeOpacity = ls.stroke.opacity;
					objectStyle.strokeWidth = ls.stroke.width;
					objectStyle.strokeLinecap = "round";
					objectStyle.strokeDashstyle = "solid";
					objectStyle.fill = "false";
				}
				else if (symb is PolygonSymbolizer)
				{
					var ps:PolygonSymbolizer = symb as PolygonSymbolizer;
					objectStyle.fill = "true";
					if (ps.fill is SolidFill)
					{
						objectStyle.fillColor = (ps.fill as SolidFill).color;
						objectStyle.fillOpacity = (ps.fill as SolidFill).opacity;
					}
					objectStyle.strokeColor = ps.stroke.color;
					objectStyle.strokeOpacity = ps.stroke.opacity;
					objectStyle.strokeWidth = ps.stroke.width;
					objectStyle.strokeLinecap = "round";
					objectStyle.strokeDashstyle = "solid";
					
				}
			}
			
			return objectStyle;
		}
	}
}