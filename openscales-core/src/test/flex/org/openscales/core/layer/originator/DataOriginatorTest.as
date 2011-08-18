package org.openscales.core.layer.originator
{
	import org.flexunit.Assert;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.layer.Layer;
	import org.openscales.geometry.basetypes.Bounds;
	
	public class DataOriginatorTest
	{		
		[Test]
		public function testDataOriginatorInitialization():void 
		{
			var name:String = "originator";
			var url:String = "url_originator";
			var pictureUrl:String = "url_picture_originator";
			var dataOriginator:DataOriginator = new DataOriginator(name, url, pictureUrl);
			
			Assert.assertEquals(name, dataOriginator.name);
			Assert.assertEquals(url, dataOriginator.url);
			Assert.assertEquals(pictureUrl, dataOriginator.pictureUrl);
		}
		
		[Test]
		public function testAddConstraint():void
		{
			// new DataOriginator
			var name:String = "originator";
			var url:String = "url_originator";
			var pictureUrl:String = "url_picture_originator";
			var dataOriginator:DataOriginator = new DataOriginator(name, url, pictureUrl);
			
			// contraint params
			var bounds:Bounds = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,"");		
			var maxResolution:Number = Layer.DEFAULT_NOMINAL_RESOLUTION;
			var minResolution:Number = maxResolution/Layer.DEFAULT_NUM_ZOOM_LEVELS;
			var constraint:ConstraintOriginator = new ConstraintOriginator(bounds, minResolution, maxResolution);

			// add constraint
			dataOriginator.addConstraint(constraint);
			
			Assert.assertEquals(bounds, dataOriginator.constraints[0].extent);
			Assert.assertEquals(minResolution, dataOriginator.constraints[0].minResolution);
			Assert.assertEquals(maxResolution, dataOriginator.constraints[0].maxResolution);
		}
		
		[Test]
		public function testRemoveConstraint():void
		{
			// new DataOriginator
			var name:String = "originator";
			var url:String = "url_originator";
			var pictureUrl:String = "url_picture_originator";
			var dataOriginator:DataOriginator = new DataOriginator(name, url, pictureUrl);
			
			// contraint params
			var bounds:Bounds = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,"");		
			var maxResolution:Number = Layer.DEFAULT_NOMINAL_RESOLUTION;
			var minResolution:Number = maxResolution/Layer.DEFAULT_NUM_ZOOM_LEVELS;
			var constraint:ConstraintOriginator = new ConstraintOriginator(bounds, minResolution, maxResolution);
			
			// add constraint
			dataOriginator.addConstraint(constraint);
			dataOriginator.removeConstraint(constraint);
			
			Assert.assertEquals(0, dataOriginator.constraints.length);
		}
		
		[Test]
		public function testIsCoveredAreaResolution():void
		{
			// new DataOriginator
			var name:String = "originator";
			var url:String = "url_originator";
			var pictureUrl:String = "url_picture_originator";
			var dataOriginator:DataOriginator = new DataOriginator(name, url, pictureUrl);
			
			// contraint params
			var bounds:Bounds = new Bounds(-2,-2,2,2,"");		
			
			// contraint 1
			var minResolution1:Number = 0;
			var maxResolution1:Number = 2;
			
			// contraint 2
			var minResolution2:Number = 4;
			var maxResolution2:Number = 5;
			
			// add constraint
			dataOriginator.addConstraint(new ConstraintOriginator(bounds, minResolution1, maxResolution1));
			dataOriginator.addConstraint(new ConstraintOriginator(bounds, minResolution2, maxResolution2));
			
			// test resolutions covered :
			
			// test 1 : too low / FALSE
			var resolutionTest1:Resolution = new Resolution(-1, "EPSG:4326");
			
			Assert.assertFalse(dataOriginator.isCoveredArea(bounds, resolutionTest1));
			
			// test 2 : too hight / FALSE
			var resolutionTest2:Resolution = new Resolution(6, "EPSG:4326");
			
			Assert.assertFalse(dataOriginator.isCoveredArea(bounds, resolutionTest2));
			
			// test 3 : between one resolution constraint / TRUE
			var resolutionTest3:Resolution = new Resolution(1, "EPSG:4326");
			
			Assert.assertTrue(dataOriginator.isCoveredArea(bounds, resolutionTest3));
			
			// test 4 : equal to one resolution limit / TRUE
			var resolutionTest4:Resolution = new Resolution(4, "EPSG:4326");;
			
			Assert.assertTrue(dataOriginator.isCoveredArea(bounds, resolutionTest4));
		}
		
		[Test]
		public function testIsCoveredAreaExtent():void
		{
			// new DataOriginator
			var name:String = "originator";
			var url:String = "url_originator";
			var pictureUrl:String = "url_picture_originator";
			var dataOriginator:DataOriginator = new DataOriginator(name, url, pictureUrl);
			
			// default resolution :
			var maxResolution:Number = Layer.DEFAULT_NOMINAL_RESOLUTION;
			var minResolution:Number = maxResolution/Layer.DEFAULT_NUM_ZOOM_LEVELS
			
			// resolution valid for coverage
			var moyResolution:Resolution = new Resolution((minResolution+maxResolution)/2.0, "EPSG:4326");
			
			// contraint originator 1 :
			var bounds1:Bounds = new Bounds(-2,-2,2,2,"");		
			dataOriginator.addConstraint(new ConstraintOriginator(bounds1, minResolution, maxResolution));
			
			// contraint originator 2 :
			var bounds2:Bounds = new Bounds(5,5,7,7,"");		
			dataOriginator.addConstraint(new ConstraintOriginator(bounds2, minResolution, maxResolution));
			
			// bounds to check :
			
			// Test 1 : interset left with constraint 1 / TRUE
			var boundsTest1:Bounds = new Bounds(-3,-3,-1,-1,"");
			
			Assert.assertTrue(dataOriginator.isCoveredArea(boundsTest1, moyResolution));
			
			// Test 2 : cover the two constraints / TRUE
			var boundsTest2:Bounds = new Bounds(-2,-2,7,7,"");
			
			Assert.assertTrue(dataOriginator.isCoveredArea(boundsTest2, moyResolution));
			
			// Test 3 : not covered area / FALSE
			var boundsTest3:Bounds = new Bounds(3,3,4,4,"");
			
			Assert.assertFalse(dataOriginator.isCoveredArea(boundsTest3, moyResolution));
			
			// Test 4 : exact bounds values than constraint 2 / TRUE
			var boundsTest4:Bounds = new Bounds(5,5,7,7,"");
			
			Assert.assertTrue(dataOriginator.isCoveredArea(boundsTest4, moyResolution));
		}
	}
}