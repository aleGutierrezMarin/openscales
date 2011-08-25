package org.openscales.core.control
{
	import com.adobe.protocols.dict.Database;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.originator.ConstraintOriginator;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	public class DataOriginatorsTest
	{
		
		private var originator1:DataOriginator = new DataOriginator("originator 1", "url_originator1", "url_picture_originator1");
		private var originator2:DataOriginator = new DataOriginator("originator 2", "url_originator2", "url_picture_originator2");
		private var originator3:DataOriginator = new DataOriginator("originator 3", "url_originator3", "url_picture_originator3");
		
		[Test]
		public function testAddOriginator():void 
		{
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			
			dataOriginatorsControl.addOriginator(originator1);
			
			// cehck if the list contains 1 element :
			Assert.assertEquals(1, dataOriginatorsControl.originators.length);
			
			// check if the layers count in the hasmap has been set to 1 :
			Assert.assertEquals(1, dataOriginatorsControl.originatorsLayersCount.getValue(originator1.key));
			
			// check if the originator is now on the list
			var containsOriginator:Boolean = false;
			
			var i:uint = 0;
			var j:uint = dataOriginatorsControl.originators.length;
			for (; i<j; ++i) 
			{
				if (dataOriginatorsControl.originators[i] == originator1) 
				{
					containsOriginator = true;
				}
			}
			Assert.assertTrue(containsOriginator);
			
			// add a second one (with the same originator, normally just increment the counter)
			dataOriginatorsControl.addOriginator(originator1);
			
			// cehck if the list still contains 1 element :
			Assert.assertEquals(1, dataOriginatorsControl.originators.length);
			
			// check if the layers count in the hasmap has been set to 2 :
			Assert.assertEquals(2, dataOriginatorsControl.originatorsLayersCount.getValue(originator1.key));
			
		}
		
		[Test]
		public function testFindOriginatorByKey():void
		{
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			dataOriginatorsControl.addOriginator(originator1);
			
			Assert.assertEquals(originator1,dataOriginatorsControl.findOriginatorByKey(originator1.key));
			Assert.assertNull(dataOriginatorsControl.findOriginatorByKey("test"));
		}
		
		[Test]
		public function testRemoveOriginator():void
		{
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			
			// Add originators
			dataOriginatorsControl.addOriginator(originator1);
			dataOriginatorsControl.addOriginator(originator1);
			dataOriginatorsControl.addOriginator(originator2);
			
			Assert.assertEquals("There should be 2 originators", 2, dataOriginatorsControl.originators.length);
			
			dataOriginatorsControl.removeOriginator(originator1);
			
			Assert.assertEquals("There still should be 2 originators ", 2, dataOriginatorsControl.originators.length);
			
			Assert.assertEquals("The originator layers count should be 1", 1, dataOriginatorsControl.originatorsLayersCount.getValue(originator1.key));
			
			// check if the originator is now on the list
			var containsOriginator1:Boolean = false;
			
			var i:uint = 0;
			var j:uint = dataOriginatorsControl.originators.length;
			for (; i<j; ++i) 
			{
				if (dataOriginatorsControl.originators[i] == originator1) 
				{
					containsOriginator1 = true;
				}
			}
			Assert.assertTrue(containsOriginator1);
			
			// delete the last "originator"
			dataOriginatorsControl.removeOriginator(originator1);
			
			// check if lenght has decrease
			Assert.assertEquals(1, dataOriginatorsControl.originators.length);
			
			// check if the hasMap has only one element
			Assert.assertEquals(1, dataOriginatorsControl.originatorsLayersCount.size());
			
			// delete the "originator2"
			dataOriginatorsControl.removeOriginator(originator2);
			
			// check if list is now empty
			Assert.assertEquals(0, dataOriginatorsControl.originators.length);
			
			// check if the two previous originator are no longer in the list
			var containsOriginator2:Boolean = false;
			containsOriginator1 = false;
			
			// check if the hasMap is empty
			Assert.assertEquals(0, dataOriginatorsControl.originatorsLayersCount.size());
			
			
			i = 0;
			j = dataOriginatorsControl.originators.length;
			for (; i<j; ++i) 
			{
				if (dataOriginatorsControl.originators[i] == originator1) 
				{
					containsOriginator1 = true;
				}
				if (dataOriginatorsControl.originators[i] == originator2) 
				{
					containsOriginator2 = true;
				}
			}
			Assert.assertFalse(containsOriginator1);
			Assert.assertFalse(containsOriginator2);
		}
		
		[Test]
		public function testRemoveAll():void
		{
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			
			dataOriginatorsControl.addOriginator(originator1);
			dataOriginatorsControl.addOriginator(originator2);
			dataOriginatorsControl.addOriginator(originator3);
			
			dataOriginatorsControl.removeAll();
			
			// No originator in the list
			Assert.assertEquals(0, dataOriginatorsControl.originators.length);
			// No value in the originator counter list
			Assert.assertEquals(0, dataOriginatorsControl.originatorsLayersCount.size());
		}
		
		[Test]
		public function testGenerateOriginators():void 
		{
			
			var layer1:Layer = new Layer("layer1");
			layer1.addOriginator(originator1);
			
			var layer2:Layer = new Layer("layer2");
			layer2.addOriginator(originator1); // same originator
			
			var layer3:Layer = new Layer("layer3");
			layer3.addOriginator(originator2);
			
			var _map:Map = new Map(200,200);
			_map.addLayer(layer1);
			_map.addLayer(layer2);
			_map.addLayer(layer3);
			
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			_map.addControl(dataOriginatorsControl);
			
			Assert.assertEquals("There should be 2 originator", 2, dataOriginatorsControl.originators.length);
			
			var containsOriginator1:Boolean = false;
			var containsOriginator2:Boolean = false;
			
			var i:uint = 0;
			var j:uint = dataOriginatorsControl.originators.length;
			for (; i<j; ++i) 
			{
				if (dataOriginatorsControl.originators[i] == originator1) 
				{
					containsOriginator1 = true;
				}
				if (dataOriginatorsControl.originators[i] == originator2) 
				{
					containsOriginator2 = true;
				}
			}
			
			Assert.assertTrue(containsOriginator1);
			Assert.assertTrue(containsOriginator1);
		}
		
		[Test]
		public function testLayerAddedEvent():void
		{
			// create map
			var map:Map = new Map(200, 200);
			
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			
			map.addControl(dataOriginatorsControl);
			
			// No originator in the list
			Assert.assertEquals(dataOriginatorsControl.originators.length, 0);
			
			
			// layer 1
			var layer1:Layer = new Layer("layer1");
			map.addLayer(layer1);
			
			Assert.assertEquals("There should be 0 originator",0,dataOriginatorsControl.originators.length);
			
			layer1.addOriginator(originator1);
			
			// One originator in the list
			Assert.assertEquals("There should be 1 originators",1,dataOriginatorsControl.originators.length);
			
			var layer2:Layer = new Layer("layer2");
			layer2.addOriginator(originator1);
			map.addLayer(layer2);
			
			// Still one originator
			Assert.assertEquals("There still should be 1 originator",1,dataOriginatorsControl.originators.length);
			
			var layer3:Layer = new Layer("layer2");
			layer3.addOriginator(originator2);
			map.addLayer(layer3);
			
			// 3 originators in the list
			Assert.assertEquals("There should be 2 originators",2,dataOriginatorsControl.originators.length);
		}
		
		[Test]
		public function testLayerRemovedEvent():void
		{
			// create map
			var map:Map = new Map(200, 200);
			
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			map.addControl(dataOriginatorsControl);
			
			// Layer 1
			var layer1:Layer = new Layer("layer1");
			layer1.addOriginator(originator1);
			
			// Layer 2
			var layer2:Layer = new Layer("layer2");
			layer2.addOriginator(originator1);
				
			// Layer 3
			var layer3:Layer = new Layer("layer3");
			layer3.addOriginator(originator2);
			
			map.addLayer(layer1);
			map.addLayer(layer2);
			map.addLayer(layer3);
			Assert.assertEquals("There should be 2 originators",2,dataOriginatorsControl.originators.length);
			
			map.removeLayer(layer2);
			Assert.assertEquals("There should be 2 originators",2,dataOriginatorsControl.originators.length);
			
			map.removeLayer(layer3);
			Assert.assertEquals("There should be 1 originator",1,dataOriginatorsControl.originators.length);
			
			// re-add
			map.addLayer(layer2);
			map.addLayer(layer3);
			map.removeAllLayers();
			Assert.assertEquals("There should be 0 originator",0,dataOriginatorsControl.originators.length);
		}
		
		[Test]
		public function testOnLayerChanged():void
		{
			// test add layer :
			// create map
			var map:Map = new Map(200, 200);
			
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			map.addControl(dataOriginatorsControl);
			
			// Layer 1
			var layer1:Layer = new Layer("layer1");
			layer1.addOriginator(originator1);
			map.addLayer(layer1);
			Assert.assertEquals("There should be 1 originator",1,dataOriginatorsControl.originators.length);
			
			// Layer 2
			var layer2:Layer = new Layer("layer2");
			layer2.addOriginator(originator1);
			map.addLayer(layer2);
			Assert.assertEquals("There still should be 1 originator",1,dataOriginatorsControl.originators.length);
			
			// Layer 3
			var layer3:Layer = new Layer("layer3");
			layer3.addOriginator(originator2);
			map.addLayer(layer3); 
			Assert.assertEquals("There should be 2 originator",2,dataOriginatorsControl.originators.length);

			// hide a layer with a specific originator
			layer3.visible = false;
			// only one originator in the list
			Assert.assertEquals("There should be 1 only originator",1,dataOriginatorsControl.originators.length);
			
			// change visibility :
			layer3.visible = true;
			Assert.assertEquals("There still should be 2 originator",2,dataOriginatorsControl.originators.length);
			
		}
		
		[Test]
		public function testOnMapChanged():void
		{
			// Layer 1
			var layer1:Layer = new Layer("layer1");
			// an originator for this layer
			var originator:DataOriginator = new DataOriginator("originator", "url_originator", "url_picture_originator");
			var minResolution:Resolution = new Resolution(0,Layer.DEFAULT_PROJECTION);
			var maxResolution:Resolution = new Resolution(1.5,Layer.DEFAULT_PROJECTION);
			var bounds:Bounds = new Bounds(-10,-10,0,0,Layer.DEFAULT_PROJECTION);		
			// limited constraint
			originator.addConstraint(new ConstraintOriginator(bounds, minResolution, maxResolution));
			
			layer1.addOriginator(originator);
			
			
			// Layer 2
			var layer2:Layer = new Layer("layer2");
			var originator2:DataOriginator = new DataOriginator("originator2", "url_originator2", "url_picture_originator2");
			layer2.addOriginator(originator2); // default constraint
			
			
			var map:Map = new Map(200, 200);
			map.addLayer(layer1);
			map.addLayer(layer2); 
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			map.addControl(dataOriginatorsControl);
			
			// no change : 2 originators 
			Assert.assertEquals("There should be 2 originators",2,dataOriginatorsControl.originators.length);
			
			// change map
			var notCoverBounds:Bounds = new Bounds(-20,-20,-10,-10,Layer.DEFAULT_PROJECTION);
			
			map.zoomToExtent(notCoverBounds);
			
			// 2 originator
			Assert.assertEquals("There should be 1 originator",1,dataOriginatorsControl.originators.length);
			
			// contains originator 2 ?
			var containsOriginator2:Boolean = false;
			
			var i:uint = 0;
			var j:uint = dataOriginatorsControl.originators.length;
			for (; i<j; ++i) 
			{
				if (dataOriginatorsControl.originators[i] == originator2) 
				{
					containsOriginator2 = true;
				}
			}
			Assert.assertTrue(containsOriginator2);
			
		}
		
		[Test]
		public function testOnOriginatorListChange():void
		{
			// when originator add
			var map:Map = new Map(200, 200);
			
			// Layer 1
			var layer1:Layer = new Layer("layer1");
			layer1.addOriginator(originator1);
			map.addLayer(layer1);
			
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			map.addControl(dataOriginatorsControl);
			
			Assert.assertEquals("There should be 1 originator",1,dataOriginatorsControl.originators.length);
			
			layer1.addOriginator(originator2);
			Assert.assertEquals("There should be 2 originators",2,dataOriginatorsControl.originators.length);
			
			var containsOriginator2:Boolean = false;
			
			var i:uint = 0;
			var j:uint = dataOriginatorsControl.originators.length;
			for (; i<j; ++i) 
			{
				if (dataOriginatorsControl.originators[i] == originator2) 
				{
					containsOriginator2 = true;
				}
			}
			Assert.assertTrue(containsOriginator2);
		}
	}
}