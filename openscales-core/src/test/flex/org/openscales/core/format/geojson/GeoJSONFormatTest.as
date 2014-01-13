package org.openscales.core.format.geojson
{
	import org.flexunit.Assert;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;

	public class GeoJSONFormatTest
	{
		[Test]
		public function testBuildCoordsAsArray():void
		{
			var geoJsonFormat:GeoJSONFormat = new GeoJSONFormat();
			
			// Prepare vectors numbers wich contain coordinates
			var pointCoords:Vector.<Number> = new Vector.<Number>();
			pointCoords.push(1);
			pointCoords.push(2);
			var lineCoords:Vector.<Number> = new Vector.<Number>();
			lineCoords.push(1);
			lineCoords.push(2);
			lineCoords.push(3);
			lineCoords.push(4);
			var polygonCoords:Vector.<Number> = new Vector.<Number>();
			polygonCoords.push(1);
			polygonCoords.push(2);
			polygonCoords.push(3);
			polygonCoords.push(4);
			polygonCoords.push(5);
			polygonCoords.push(6);
			polygonCoords.push(7);
			polygonCoords.push(8);
			
			var pointRes:Array = geoJsonFormat.buildCoordsAsArray(pointCoords);
			var lineRes:Array = geoJsonFormat.buildCoordsAsArray(lineCoords);
			var polygonRes:Array = geoJsonFormat.buildCoordsAsArray(polygonCoords, true);
			
			Assert.assertEquals("There should be two coordinates in the point array", 2, pointRes.length);
			Assert.assertEquals("There should be two couples of coordinates in the line array", 2, lineRes.length);
			Assert.assertEquals("There should be two couples of coordinates in the line array", 2, (lineRes[0] as Array).length);
			Assert.assertEquals("There should be five couples of coordinates in the line array", 5, polygonRes.length);
			Assert.assertEquals("There should be five couples of coordinates in the line array", 2, (polygonRes[0] as Array).length);
			Assert.assertTrue("The first and last cordinates must match for polygon", 2, (polygonRes[0] as Array)[0] == (polygonRes[4] as Array)[0] && 
				(polygonRes[0] as Array)[1] == (polygonRes[4] as Array)[1]);
			
			
		}
		
		[Test]
		public function testGetPropertiesFromFeature():void
		{
			var geoJsonFormat:GeoJSONFormat = new GeoJSONFormat();
			
			var feature:Feature = new Feature();
			feature.attributes.test = "testAttribute";
			
			var result:Object = geoJsonFormat.getPropertiesFromFeature(feature);
			
			Assert.assertNotNull("Feature's properties should not be null", result);
			Assert.assertEquals("There should be the sames properties that used as attributes for the feature", "testAttribute", result.test);
			Assert.assertNotNull("There should be a style property added", result["_style"]);
			
		}
		
		[Test]
		public function testGetGeometryFromFeature():void
		{
			var geoJsonFormat:GeoJSONFormat = new GeoJSONFormat();
			
			var lineCoords:Vector.<Number> = new Vector.<Number>();
			lineCoords.push(1);
			lineCoords.push(2);
			lineCoords.push(3);
			lineCoords.push(4);
			
			
			var pointFeature:PointFeature = new PointFeature(new Point(1,2));
			var lineString:LineString = new LineString(lineCoords);
			var linearRing:LinearRing = new LinearRing(lineCoords);
			var lineFeature:LineStringFeature = new LineStringFeature(lineString);
			var polyCoords:Vector.<Geometry> = new Vector.<Geometry>();
			polyCoords.push(linearRing);
			var pol:Polygon = new Polygon(polyCoords);
			var polygonFeature:PolygonFeature = new PolygonFeature(pol);
			var multiVector:Vector.<Geometry> = new Vector.<Geometry>();
			multiVector.push(pol);
			var multiPolygonFeature:MultiPolygonFeature = new MultiPolygonFeature(new MultiPolygon(multiVector));
			var emptyFeature:Feature = new Feature();
			
			var result:Object = geoJsonFormat.getGeometryFromFeature(pointFeature);
			
			Assert.assertNotNull("Feature's object should not be null", result);
			Assert.assertEquals("There should be the sames properties that used as attributes for the feature", "Point", result.type);
			Assert.assertNotNull("There should be a coordinates property added", result["coordinates"]);
			
			result = geoJsonFormat.getGeometryFromFeature(lineFeature);
			
			Assert.assertNotNull("Feature's object should not be null", result);
			Assert.assertEquals("There should be the sames properties that used as attributes for the feature", "LineString", result.type);
			Assert.assertNotNull("There should be a coordinates property added", result["coordinates"]);
			
			result = geoJsonFormat.getGeometryFromFeature(polygonFeature);
			
			Assert.assertNotNull("Feature's object should not be null", result);
			Assert.assertEquals("There should be the sames properties that used as attributes for the feature", "Polygon", result.type);
			Assert.assertNotNull("There should be a coordinates property added", result["coordinates"]);
			
			result = geoJsonFormat.getGeometryFromFeature(multiPolygonFeature);
			
			Assert.assertNotNull("Feature's object should not be null", result);
			Assert.assertEquals("There should be the sames properties that used as attributes for the feature", "MultiPolygon", result.type);
			Assert.assertNotNull("There should be a coordinates property added", result["coordinates"]);
			
			result = geoJsonFormat.getGeometryFromFeature(emptyFeature);
			
			Assert.assertNotNull("Feature's object should not be null", result);
			Assert.assertNull("There should not be a coordinates property added", result["coordinates"]);
		}
	}
}