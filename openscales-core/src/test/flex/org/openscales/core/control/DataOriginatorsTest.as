package org.openscales.core.control
{
	import com.adobe.protocols.dict.Database;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.layer.originator.ConstraintOriginator;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.core.layer.osm.CycleMap;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	public class DataOriginatorsTest
	{		
		[Test]
		public function testAddOriginator():void 
		{
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			
			// new originator for mapnik
			var name:String = "originator";
			var url:String = "url_originator";
			var urlPicture:String = "url_picture_originator";
			var originator:DataOriginator = new DataOriginator(name, url, urlPicture);
			
			dataOriginatorsControl.addOriginator(originator);
			
			// cehck if the list contains 1 element :
			Assert.assertEquals(1, dataOriginatorsControl.originators.length);
			
			// check if the layers count in the hasmap has been set to 1 :
			Assert.assertEquals(1, dataOriginatorsControl.originatorsLayersCount.getValue(originator.key));
			
			// check if the originator is now on the list
			var containsOriginator:Boolean = false;
			
			var i:uint = 0;
			var j:uint = dataOriginatorsControl.originators.length;
			for (; i<j; ++i) 
			{
				if (dataOriginatorsControl.originators[i] == originator) 
				{
					containsOriginator = true;
				}
			}
			Assert.assertTrue(containsOriginator);
			
			// add a second one (with the same originator, normally just increment the counter)
			dataOriginatorsControl.addOriginator(originator);
			
			// cehck if the list still contains 1 element :
			Assert.assertEquals(1, dataOriginatorsControl.originators.length);
			
			// check if the layers count in the hasmap has been set to 2 :
			Assert.assertEquals(2, dataOriginatorsControl.originatorsLayersCount.getValue(originator.key));
			
		}
		
		[Test]
		public function testRemoveOriginator():void
		{
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			
			// new originator for mapnik
			var name:String = "originator";
			var url:String = "url_originator";
			var urlPicture:String = "url_picture_originator";
			var originator:DataOriginator = new DataOriginator(name, url, urlPicture);
			var originator2:DataOriginator = new DataOriginator("originator2", url, urlPicture);
			
			// Add originators
			dataOriginatorsControl.addOriginator(originator);
			dataOriginatorsControl.addOriginator(originator);
			dataOriginatorsControl.addOriginator(originator2);
			
			Assert.assertEquals("There should be 2 originators", 2, dataOriginatorsControl.originators.length);
			
			// delete one of 2 "originator"
			dataOriginatorsControl.removeOriginator(originator);
			
			// check if "originator" still exist :
			Assert.assertEquals("There still should be 2 originators ", 2, dataOriginatorsControl.originators.length);
			
			// check if counter is set to 1 instead of 2 :
			Assert.assertEquals("The originator layers count should be 1", 1, dataOriginatorsControl.originatorsLayersCount.getValue(originator.key));
			
			// check if the originator is now on the list
			var containsOriginator:Boolean = false;
			
			var i:uint = 0;
			var j:uint = dataOriginatorsControl.originators.length;
			for (; i<j; ++i) 
			{
				if (dataOriginatorsControl.originators[i] == originator) 
				{
					containsOriginator = true;
				}
			}
			Assert.assertTrue(containsOriginator);
			
			// delete the last "originator"
			dataOriginatorsControl.removeOriginator(originator);
			
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
			containsOriginator = false;
			
			// check if the hasMap is empty
			Assert.assertEquals(0, dataOriginatorsControl.originatorsLayersCount.size());
			
			
			i = 0;
			j = dataOriginatorsControl.originators.length;
			for (; i<j; ++i) 
			{
				if (dataOriginatorsControl.originators[i] == originator) 
				{
					containsOriginator = true;
				}
				if (dataOriginatorsControl.originators[i] == originator2) 
				{
					containsOriginator2 = true;
				}
			}
			Assert.assertFalse(containsOriginator);
			Assert.assertFalse(containsOriginator2);
		}
		
		[Test]
		public function testGenerateOriginators():void 
		{
			// create map
			var _map:Map = new Map();
			_map.size = new Size(1200, 700);
			
			// add layers
			var mapnik:Mapnik = new Mapnik("Mapnik"); // a base layer
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			_map.addLayer(mapnik);
			
			// originator for the map
			var originators:Vector.<DataOriginators> = new Vector.<DataOriginators>();
			
			// new originator for mapnik
			var name:String = "originator";
			var url:String = "url_originator";
			var urlPicture:String = "url_picture_originator";
			var originator:DataOriginator = new DataOriginator(name, url, urlPicture);
			mapnik.addOriginator(originator);
			
			var cycle:CycleMap=new CycleMap("Cycle"); // a base layer
			cycle.proxy = "http://openscales.org/proxy.php?url=";
			_map.addLayer(cycle); 
			
			// same originator for cycleMap
			cycle.addOriginator(originator);
			
			var regions:WFS = new WFS("IGN - Geopla (Region)", "http://openscales.org/geoserver/wfs","pg:ign_geopla_region");
			regions.projSrsCode = "EPSG:2154";
			regions.style = Style.getDefaultSurfaceStyle();
			
			// new originator for WFS
			var nameIGN:String = "IGN";
			var urlIGN:String = "http://www.ign.fr/";
			var urlPictureIGN:String = "http://www.ign.fr/imgs/logo.gif";
			var originatorIGN:DataOriginator = new DataOriginator(nameIGN, urlIGN, urlPictureIGN);
			
			_map.addLayer(regions);
			
			regions.addOriginator(originatorIGN);
			
			// create DataOriginators controller
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			_map.addControl(dataOriginatorsControl);
			
			// check generateOriginators
			
			// if list count != 3 : fail
			Assert.assertEquals("There should be 3 originator", 3, dataOriginatorsControl.originators.length);
			
			
			var containsOriginator:Boolean = false;
			var containsIGN:Boolean = false;
			
			var i:uint = 0;
			var j:uint = dataOriginatorsControl.originators.length;
			for (; i<j; ++i) 
			{
				if (dataOriginatorsControl.originators[i] == originator) 
				{
					containsOriginator = true;
				}
				if (dataOriginatorsControl.originators[i] == originatorIGN) 
				{
					containsIGN = true;
				}
			}
			
			// if the originators list doesn't contain the originator "originator" : fail
			Assert.assertTrue(containsOriginator);
			// if the originators list doesn't contain the originator "IGN" : fail
			Assert.assertTrue(containsIGN);
		}
		
		[Test]
		public function testResetOriginatorsLayersCount():void
		{
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			
			// new originator for mapnik
			var name:String = "originator";
			var url:String = "url_originator";
			var urlPicture:String = "url_picture_originator";
			var originator:DataOriginator = new DataOriginator(name, url, urlPicture);
			
			dataOriginatorsControl.addOriginator(originator);
			dataOriginatorsControl.resetOriginatorsLayersCount();
			
			var values:Array = dataOriginatorsControl.originatorsLayersCount.getValues();
			for each (var value:Number in values) 
			{
				if( value != 0 )
				{
					Assert.fail("A value is different than 0");
				}
			}
		}
		
		
		[Test]
		public function testRemoveAll():void
		{
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			
			var url:String = "url_originator";
			var urlPicture:String = "url_picture_originator";
			var originator1:DataOriginator = new DataOriginator("originator", url, urlPicture);
			var originator2:DataOriginator = new DataOriginator("originator 2", url, urlPicture);
			var originator3:DataOriginator = new DataOriginator("originator 3", url, urlPicture);
			
			dataOriginatorsControl.addOriginator(originator1);
			dataOriginatorsControl.addOriginator(originator2);
			dataOriginatorsControl.addOriginator(originator3);
			
			dataOriginatorsControl.removeAll();
			
			// No originator in the list
			Assert.assertEquals(dataOriginatorsControl.originators.length, 0);
			// No value in the originator counter list
			Assert.assertEquals(dataOriginatorsControl.originatorsLayersCount.size(), 0);
		}
		
		[Test]
		public function testLayerAddedEvent():void
		{
			// create map
			var map:Map = new Map();
			map.size = new Size(1200, 700);
			
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			
			map.addControl(dataOriginatorsControl);
			
			// No originator in the list
			Assert.assertEquals(dataOriginatorsControl.originators.length, 0);
			
			// layer 1
			var mapnik:Mapnik = new Mapnik("Mapnik"); // a base layer
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);
			map.addLayer(mapnik);
			
			// One originator in the list
			Assert.assertEquals("There should be 1 originator",1,dataOriginatorsControl.originators.length);
			
			// an originator for this layer
			var name:String = "originator";
			var url:String = "url_originator";
			var urlPicture:String = "url_picture_originator";
			var originator:DataOriginator = new DataOriginator(name, url, urlPicture);
			mapnik.addOriginator(originator);
			
			// One originator in the list
			Assert.assertEquals("There should be 2 originators",2,dataOriginatorsControl.originators.length);
			
			// layer 2
			var mapnik2:Mapnik = new Mapnik("Mapnik2"); // a base layer
			mapnik2.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			mapnik2.addOriginator(originator);
			map.addLayer(mapnik2);
			
			// Still one originator
			Assert.assertEquals("There still should be 2 originator",2,dataOriginatorsControl.originators.length);
			
			// layer 3
			var cycle:CycleMap=new CycleMap("Cycle"); // a base layer
			var originator2:DataOriginator = new DataOriginator("originator2", url, urlPicture);
			cycle.addOriginator(originator2);
			map.addLayer(cycle); 
			
			// 3 originators in the list
			Assert.assertEquals("There should be 3 originators",3,dataOriginatorsControl.originators.length);
		}
		
		[Test]
		public function testLayerRemovedEvent():void
		{
			// create map
			var map:Map = new Map();
			map.size = new Size(1200, 700);
			
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			map.addControl(dataOriginatorsControl);
			
			// Layer 1
			var mapnik:Mapnik = new Mapnik("Mapnik"); // a base layer
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			
			// an originator for this layer
			var name:String = "originator";
			var url:String = "url_originator";
			var urlPicture:String = "url_picture_originator";
			var originator:DataOriginator = new DataOriginator(name, url, urlPicture);
			mapnik.addOriginator(originator);
			
			map.addLayer(mapnik);
			
			// Layer 2
			var mapnik2:Mapnik = new Mapnik("Mapnik2"); // a base layer
			mapnik2.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			mapnik2.addOriginator(originator);
			map.addLayer(mapnik2);
			
			var cycle:CycleMap=new CycleMap("Cycle"); // a base layer
			cycle.proxy = "http://openscales.org/proxy.php?url=";
			var originator2:DataOriginator = new DataOriginator("originator2343434", url, urlPicture);
			cycle.addOriginator(originator2);
			
			map.addLayer(cycle); 
			
			// remove one :
			map.removeLayer(mapnik2);
			
			// Still 3 originators in the list
			Assert.assertEquals("There should be 3 originators",3,dataOriginatorsControl.originators.length);
			
			// remove another one :
			map.removeLayer(cycle);
			
			// Still 2 originator in the list
			Assert.assertEquals("There should be 2 originator",2,dataOriginatorsControl.originators.length);
			
			// re-add
			map.addLayer(mapnik2);
			map.addLayer(cycle);
			
			map.removeAllLayers();
			// Still 1 originator in the list
			Assert.assertEquals("There should be 0 originator",0,dataOriginatorsControl.originators.length);
		}
		
		[Test]
		public function testOnLayerChanged():void
		{
			// test add layer :
			// create map
			var map:Map = new Map();
			map.size = new Size(1200, 700);
			
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			map.addControl(dataOriginatorsControl);
			
			// Layer 1
			var mapnik:Mapnik = new Mapnik("Mapnik"); // a base layer
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			
			// an originator for this layer
			var name:String = "originator";
			var url:String = "url_originator";
			var urlPicture:String = "url_picture_originator";
			var originator:DataOriginator = new DataOriginator(name, url, urlPicture);
			mapnik.addOriginator(originator);
			
			map.addLayer(mapnik);
			
			Assert.assertEquals("There should be 2 originator",2,dataOriginatorsControl.originators.length);
			
			// Layer 2
			var mapnik2:Mapnik = new Mapnik("Mapnik2"); // a base layer
			mapnik2.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			mapnik2.addOriginator(originator);
			map.addLayer(mapnik2);
			
			Assert.assertEquals("There still should be 2 originator",2,dataOriginatorsControl.originators.length);
			
			var cycle:CycleMap=new CycleMap("Cycle"); // a base layer
			var originator2:DataOriginator = new DataOriginator("originator2", url, urlPicture);
			cycle.addOriginator(originator2);
			map.addLayer(cycle); 
			
			Assert.assertEquals("There should be 3 originator",3,dataOriginatorsControl.originators.length);
			
			// change visibility :
			mapnik.visible = true;
			
			Assert.assertEquals("There still should be 3 originator",3,dataOriginatorsControl.originators.length);
			
			// hide a layer with a specific originator
			cycle.visible = false;
			
			// only one originator in the list
			Assert.assertEquals("There should be 2 only originator",2,dataOriginatorsControl.originators.length);
		}
		
		[Test]
		public function testOnMapChanged():void
		{
			var map:Map = new Map();
			map.size = new Size(1200, 700);
			
			// Layer 1
			var mapnik:Mapnik = new Mapnik("Mapnik"); // a base layer
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			
			// an originator for this layer
			var name:String = "originator";
			var url:String = "url_originator";
			var urlPicture:String = "url_picture_originator";
			var originator:DataOriginator = new DataOriginator(name, url, urlPicture);
			
			var minResolution:Number = 0;
			var maxResolution:Number = 156543;		
			var bounds:Bounds = new Bounds(-10,-10,10,10,mapnik.projSrsCode);		
			// limited constraint
			originator.addConstraint(new ConstraintOriginator(bounds, minResolution, maxResolution));
			
			mapnik.addOriginator(originator);
			map.addLayer(mapnik);
			
			// Layer 2
			var cycle:CycleMap=new CycleMap("Cycle"); // a base layer
			var originator2:DataOriginator = new DataOriginator("originator2", url, urlPicture);
			cycle.addOriginator(originator2); // default constraint
			map.addLayer(cycle); 
			
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			map.addControl(dataOriginatorsControl);
			
			// no change : 2 originators 
			Assert.assertEquals("There should be 3 originators",3,dataOriginatorsControl.originators.length);
			
			// change map
			var notCoverBounds:Bounds = new Bounds(1000,1000,2000,2000,mapnik.projSrsCode);
			
			map.zoomToExtent(notCoverBounds);
			
			// 2 originator
			Assert.assertEquals("There should be 2 originator",2,dataOriginatorsControl.originators.length);
			
			// only contains originator 2 ?
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
			var map:Map = new Map();
			map.size = new Size(1200, 700);
			
			// Layer 1
			var mapnik:Mapnik = new Mapnik("Mapnik"); // a base layer
			mapnik.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,mapnik.projSrsCode);		
			
			// an originator for this layer
			var name:String = "originator";
			var url:String = "url_originator";
			var urlPicture:String = "url_picture_originator";
			var originator:DataOriginator = new DataOriginator(name, url, urlPicture);
			
			mapnik.addOriginator(originator);
			map.addLayer(mapnik);
			
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			map.addControl(dataOriginatorsControl);
			
			// 1 originator
			Assert.assertEquals("There should be 2 originator",2,dataOriginatorsControl.originators.length);
			
			// second originator
			var originator2:DataOriginator = new DataOriginator("originator2", url, urlPicture);
			mapnik.addOriginator(originator2);
			
			// 2 originators
			Assert.assertEquals("There should be 3 originators",3,dataOriginatorsControl.originators.length);
			
			// only contains originator 2 ?
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
		public function testFindOriginatorByKey():void
		{
			// DataOriginators control
			var dataOriginatorsControl:DataOriginators = new DataOriginators();
			
			var name:String = "originator";
			var url:String = "url_originator";
			var urlPicture:String = "url_picture_originator";
			var originator:DataOriginator = new DataOriginator(name, url, urlPicture);
			dataOriginatorsControl.addOriginator(originator);
			
			Assert.assertEquals(originator,dataOriginatorsControl.findOriginatorByKey(originator.key));
			Assert.assertNull(dataOriginatorsControl.findOriginatorByKey("test"));
		}		
	}
}