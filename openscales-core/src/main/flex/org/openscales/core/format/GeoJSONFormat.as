package org.openscales.core.format
{
	import org.hamcrest.object.nullValue;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	
	import spark.primitives.Line;

	public class GeoJSONFormat extends Format
	{
		public function GeoJSONFormat()
		{
			// Nothing to do
		}
		
		override public function write(features:Object):Object
		{
			// Convert the features objet
			var listOfFeatures:Vector.<Feature> = features as Vector.<Feature>;
			var numberOfFeatures:uint = listOfFeatures.length;
			
			var geojson:Object = new Object();
			var featureArray:Array = new Array();
			
			for (var i:uint = 0; i < numberOfFeatures; i++)
			{
				var feature:Object = new Object();
				feature.type = "Feature";
				feature.properties = null;
				feature.geometry = getGeometryFromFeature(features[i]);
			}
			
			geojson.type = "FeatureCollection";
			
			
			
			return geojson;
		}
		
		private function getGeometryFromFeature(feature:Feature):Object
		{
			var featureJson:Object = new Object();
			
			if (feature is PointFeature)
			{
				var point:Point = (feature as PointFeature).point;
				
				featureJson.type = "Point";
				featureJson.coordinates = [point.x, point.y];
			}
			else if (feature is LineStringFeature)
			{
				var line:LineString = (feature as LineStringFeature).lineString;
				var coords:String = this.buildCoordsAsString(line.getcomponentsClone());
				if(coords.length != 0)
					lineNode.appendChild(new XML("<coordinates>" + coords + "</coordinates>"));
				featureJson.type = "LineString";
			}
			else if (feature is PolygonFeature)
			{
				featureJson.type = "LinearRing";
			}
			
			return featureJson;
		}
	}
}