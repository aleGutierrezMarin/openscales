package org.openscales.core.format.geojson
{
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.json.GENERICJSON;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.utils.StringUtils;
	
	import spark.primitives.Line;
	import org.openscales.core.format.Format;

	public class GeoJSONFormat extends Format
	{
		public function GeoJSONFormat()
		{
			// Nothing to do
		}
		
		override public function write(features:Object):Object
		{
			// Convert the features object
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
			
			
			return geojson;
		}
		
		/**
		 * Construct the JSON objet wich represent the given feature in the GeoJSON format.
		 * 
		 * @param feature The feature to transform as a GeoJSON object.
		 * @return An object wich represent the given feature in GeoJSON format.
		 */
		private function getGeometryFromFeature(feature:Feature):Object
		{
			var featureJson:Object = new Object();
			
			if (feature is PointFeature)
			{
				var point:Point = (feature as PointFeature).point;
				var coord:Array = new Array();
				coord.push(point.x);
				coord.push(point.y);
				
				featureJson.type = "Point";
				featureJson.coordinates = coord;
			}
			else if (feature is LineStringFeature)
			{
				var line:LineString = (feature as LineStringFeature).lineString;
				
				featureJson.type = "LineString";
				
				var coords:Array = this.buildCoordsAsArray(line.getcomponentsClone());
				if(coords.length != 0)
				{
					featureJson.coordinates = coords;
				}
				
			}
			else if (feature is PolygonFeature)
			{
				var poly:Polygon = (feature as PolygonFeature).polygon;
				
				featureJson.type = "Polygon";
				
				var geomList:Vector.<Geometry> = poly.getcomponentsClone();
				var coordPoly:Array = new Array();
				
				for (var i:int = 0; i < geomList.length; i++)
				{
					coordPoly.push(this.buildCoordsAsArray((geomList[i] as LinearRing).getcomponentsClone(), true));
				}
				
				if(coordPoly.length != 0)
				{
					featureJson.coordinates = coordPoly;
				}
			}
			
			return featureJson;
		}
		
		/**
		 * Get the feature's properties as a JSON format.
		 * 
		 * @param feature The feature from wich the properties comes from.
		 * @return An object wich contain the feature's properties as a JSON formatted object.
		 */
		private function getPropertiesFromFeature(feature:Feature):Object
		{
			var properties:Object = new Object();
			
			if (feature.attributes != null)
			{
				properties = feature.attributes;
			}
			
			properties["_style"] = feature.style.name;
			
			return properties;
		}
		
		/**
		 * @param the vector of coordinates of the gemetry
		 * @return the coordinates as an array
		 * The geometries must be in 2D.
		 * This function return an Array wich is dedicated to be used with JSON objects.
		 * 
		 * @param coords A vector of Number. Numbers will be read two by two (first is lon, second is lat)
		 * @param repeatFirstOne true if you want the first coord to be repeated at the end
		 */
		public function buildCoordsAsArray(coords:Vector.<Number>, repeatFirstOne:Boolean=false):Array
		{
			var i:uint;
			var coordArray:Array = new Array();
			var numberOfPoints:uint = coords.length;
			for(i = 0; i < numberOfPoints-1; i += 2){
				
				var featureCoord:Array = new Array();
				featureCoord.push(coords[i]);
				featureCoord.push(coords[i+1]);
				
				coordArray.push(featureCoord);
			}

			if(repeatFirstOne || coordArray.length == 1) 
			{
				var featureCoordFirst:Array = new Array();
				featureCoordFirst.push(coords[0]);
				featureCoordFirst.push(coords[1]);
				
				coordArray.push(featureCoordFirst);
			}
			
			return coordArray;
		}
	}
}