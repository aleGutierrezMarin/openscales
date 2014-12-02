package org.openscales.core.filter{
	import org.flexunit.asserts.*;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.Point;
	
	public class GeometryTypeFilterTest {
		
		public function GeometryTypeFilterTest(){
		}
		
		[Test]
		public function shouldMatchFeaturesWithGeometryOfGivenType():void{
			
			// Given a GeometryType filter
			var filter:GeometryTypeFilter = new GeometryTypeFilter(new <Class>[LineString, MultiLineString]);
			
			// And a feature with a LineString geometry
			var feature:Feature = new Feature(new LineString(null));
			
			// Then the filter matches the feature
			assertTrue("Filter does not match the feature", filter.matches(feature));
		}
		
		[Test]
		public function shouldNotMatchFeaturesWithGeometryNotOfGivenType():void{
			
			// Given a GeometryType filter
			var filter:GeometryTypeFilter = new GeometryTypeFilter(new <Class>[LineString, MultiLineString]);
			
			// And a feature with a Point geometry
			var feature:Feature = new Feature(new Point());
			
			// Then the filter does not match the feature
			assertFalse("Filter matches the features", filter.matches(feature));
		}
		
	}
}