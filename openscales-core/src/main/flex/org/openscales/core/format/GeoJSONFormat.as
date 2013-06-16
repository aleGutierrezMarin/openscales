package org.openscales.core.format
{
	import org.hamcrest.object.nullValue;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.json.GENERICJSON;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.utils.StringUtils;
	
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
				feature.geometry = getGeometryFromFeature(features[i]);
				feature.properties = getPropertiesFromFeature(features[i]);
				
				featureArray.push(feature);
			}
			
			geojson.type = "FeatureCollection";
			geojson.features = featureArray;
			
			
			return GENERICJSON.encode(geojson);
		}
		
		private function getGeometryFromFeature(feature:Feature):Object
		{
			var featureJson:Object = new Object();
			
			if (feature is PointFeature)
			{
				var point:Point = (feature as PointFeature).point;
				
				featureJson.type = "Point";
				featureJson.coordinates = "[" + point.x + "," + point.y + "]";
			}
			else if (feature is LineStringFeature)
			{
				var line:LineString = (feature as LineStringFeature).lineString;
				
				featureJson.type = "LineString";
				
				var coords:String = this.buildCoordsAsString(line.getcomponentsClone());
				if(coords.length != 0)
				{
					featureJson.coordinates = coords;
				}
				
			}
			else if (feature is PolygonFeature)
			{
				var poly:Polygon = (feature as PolygonFeature).polygon;
				
				featureJson.type = "LinearRing";
				
				//var coords:String = this.buildCoordsAsString(poly.getcomponentsClone());
				//if(coords.length != 0)
				//{
				//	featureJson.coordinates = coords;
				//}
			}
			
			return featureJson;
		}
		
		private function getPropertiesFromFeature(feature:Feature):Object
		{
			var properties:Object = new Object();
			
			if (feature.attributes != null)
			{
				properties.name = feature.attributes;
				return properties
			}
			
			return null;
		}
		
		/**
		 * @param the vector of coordinates of the geometry
		 * @return the coordinates as a string
		 * the geometries must be in 2D; the altitude is not supported    
		 * 
		 * @param coords A vector of Number. Numbers will be read two by two (first is lon, second is lat)
		 * @param repeatFirstOne true if you want the first coord to be repeated at the end	
		 */
		public function buildCoordsAsString(coords:Vector.<Number>, repeatFirstOne:Boolean=false):String
		{
			var i:uint;
			var stringCoords:String = "";
			var numberOfPoints:uint = coords.length;
			for(i = 0; i < numberOfPoints-1; i += 2){
				if (stringCoords == "")
				{
					stringCoords += "[";
				}
				else
				{
					stringCoords += ",[";
				}
				stringCoords += String(coords[i])+",";
				stringCoords += String(coords[i+1]);
				stringCoords += "]";
			}
			stringCoords = StringUtils.trim(stringCoords);
			if(repeatFirstOne) stringCoords += ",["+coords[0]+","+coords[1]+"]";
			
			stringCoords = "[" + stringCoords + "]";
			
			return stringCoords;
		}
	}
}