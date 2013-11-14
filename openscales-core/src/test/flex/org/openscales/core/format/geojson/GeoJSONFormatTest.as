package org.openscales.core.format.geojson
{
	import org.flexunit.Assert;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.Point;

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
			
			var pointFeature:PointFeature = new PointFeature(new Point(1,2));
			var lineFeature:LineStringFeature = new LineStringFeature(new LineString([[1,2],[3,4]]));
			
		}
	}
}