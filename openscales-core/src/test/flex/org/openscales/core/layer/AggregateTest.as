package org.openscales.core.layer
{
	import flexunit.framework.Test;
	
	import mx.effects.easing.Bounce;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.geometry.basetypes.Bounds;
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	/**
	 * Tests the Aggregate class
	 */ 
	public class AggregateTest
	{
		private var _instance:Aggregate;
		private var _l1:Layer;
		private var _l2:Layer;
		private var _map:Map;
		
		public function AggregateTest(){}
		
		[Before]
		public function setUp():void{
			_instance = new Aggregate("test");
			_l1 = new Layer("myLayer1");
			_l2 = new Layer("myLayer2");
			_instance.layers.push(_l1,_l2);
			_map = new Map();
		}
		
		[Test] 
		public function shouldTakeFirstLayerMaxExtentAsOwnMaxExtent():void{
			_instance = new Aggregate("test");
			_instance.projection = "EPSG:4326";
			_l1 = new Layer("myLayer1");
			_l1.maxExtent = new Bounds(-40, 0,40,50, "EPSG:4326");
			
			assertNull("At init, maxExtent should be null", _instance.maxExtent);
			_instance.addLayer(_l1);
			
			_map.addLayer(_instance);
			
			assertNotNull("After adding first layer, max extent should be not null",_instance.maxExtent);
			assertEquals("Aggregate max extent left value is not correct",-40,_instance.maxExtent.left);
			assertEquals("Aggregate max extent bottom value is not correct",0,_instance.maxExtent.bottom);
			assertEquals("Aggregate max extent right value is not correct",40,_instance.maxExtent.right);
			assertEquals("Aggregate max extent top value is not correct",50,_instance.maxExtent.top);
		}
		
		[Test] 
		public function shouldExtendMaxExtentWhenLayersAreAdded():void{
			_instance = new Aggregate("test");
			_instance.projection = "EPSG:4326";
			_l1 = new Layer("myLayer1");
			_l1.maxExtent = new Bounds(-40, 0,40,50, "EPSG:4326");
			_l2 = new Layer("myLayer2");
			_l2.maxExtent = new Bounds(-45,10,10,55, "EPSG:4326");
			
			
			assertNull("At init, maxExtent should be null", _instance.maxExtent);
			_instance.addLayer(_l1);
			_instance.addLayer(_l2);
			
			_map.addLayer(_instance);
			
			assertNotNull("After adding first layer, max extent should be not null",_instance.maxExtent);
			assertEquals("Aggregate max extent left value is not correct",-45,_instance.maxExtent.left);
			assertEquals("Aggregate max extent bottom value is not correct",0,_instance.maxExtent.bottom);
			assertEquals("Aggregate max extent right value is not correct",40,_instance.maxExtent.right);
			assertEquals("Aggregate max extent top value is not correct",55,_instance.maxExtent.top);
		}
		
		[Test]
		public function shouldReduceMaxExtentWhenLayersAreRemoved():void{
			_instance = new Aggregate("test");
			_instance.projection = "EPSG:4326";
			_l1 = new Layer("myLayer1");
			_l1.maxExtent = new Bounds(-40, 0,40,50, "EPSG:4326");
			_l2 = new Layer("myLayer2");
			_l2.maxExtent = new Bounds(-45,10,10,55, "EPSG:4326");
			var l3:Layer = new Layer("myLayer3");
			l3.maxExtent = new Bounds(-30,5,45,30, "ESPG:4326");
			
			assertNull("At init, maxExtent should be null", _instance.maxExtent);
			_instance.addLayer(_l1);
			_instance.addLayer(_l2);
			_instance.addLayer(l3);
			
			_map.addLayer(_instance);
			
			_instance.removeLayer(_l2);
			
			assertNotNull("After adding first layer, max extent should be not null",_instance.maxExtent);
			assertEquals("Aggregate max extent left value is not correct",-40,_instance.maxExtent.left);
			assertEquals("Aggregate max extent bottom value is not correct",0,_instance.maxExtent.bottom);
			assertEquals("Aggregate max extent right value is not correct",45,_instance.maxExtent.right);
			assertEquals("Aggregate max extent top value is not correct",50,_instance.maxExtent.top);
			
		}
		
		/**
		 * Checks if contained layers are effecitvely added to container
		 */ 
		[Test]
		public function shouldContainAddedLayers():void{
			assertTrue("Added layers are not retrievable", _instance.layers.indexOf(_l1)>=0 && _instance.layers.indexOf(_l2)>=0);
		}
		
		/**
		 * Checks that contained layers have reference to map when aggregate in added to map
		 */ 
		[Test]
		public function shouldAddMapToContainedLayers():void{
			_map.addLayer(_instance);
			assertTrue("Contained layers does not have reference to map", _l1.map==_map && _l2.map==_map);
		}
		
		/**
		 * Checks that map has reference only to aggregate and not to contained layers
		 */
		[Test]
		public function shouldBeReferencedInMapAlongWithContainedLayers():void{
			_map.addLayer(_instance);
			assertTrue("Map does not reference aggregate", _map.layers.indexOf(_instance)>=0);
			assertTrue("Map does not references contained layers", _map.layers.indexOf(_l1)>=0 && _map.layers.indexOf(_l2)>=0);
		}
		
		/**
		 * Checks that contained layers have displayInLayerManager attribute set to true
		 */
		[Test]
		public function shouldHaveContainedLayersNotDisplayedInLayerManager():void{
			_map.addLayer(_instance);
			var layer:Layer ;
			for each (layer in _instance.layers){
				assertTrue("Contained layer is visible in layerSwitcher", !layer.displayInLayerManager);
			}
		}
		
		/**
		 * Checks that aggregate projection is not passed along to contained layers
		 */ 
		[Test]
		public function shouldNotInterfereWithContainedLayersProjection():void{
			_l1.projection = "WGS84";
			_instance.projection = "EPSG:2154";
			
			assertTrue("Aggregate projection is passed on to contained layers", _l1.projection!=_instance.projection);
		}
		
		/**
		 * Checks that aggregate name is not passed along to contained layers
		 */ 
		[Test]
		public function shouldNotInterfereWithContainedLayersName():void{
			assertTrue("Aggregate name is passed on to contained layers", _l1.name!=_instance.name);
		}
		
		/**
		 * Checks that aggregate url is not passed along to contained layers
		 */  
		[Test]
		public function shouldNotInterfereWithContainedLayersURLs():void{
			_l1.url = "http://bla.org";
			_instance.url = "http://toto.org";
			assertTrue("Aggregate url is passed on to contained layers", _l1.url!=_instance.url);
		}
		
		/**
		 * Checks that when the aggergate is removed from map, contained layers are affected
		 */ 
		[Test]
		public function shouldPassMapRemovalToContainedLayers():void{
			_map.addLayer(_instance);
			assertTrue("Contained layers does not reference map", _l1.map==_map && _l2.map==_map);
			assertTrue("Map does not reference aggregate", _map.layers.indexOf(_instance)>=0);
			_map.removeLayer(_instance);
			assertFalse("Map still references aggregate after removal", _map.layers.indexOf(_instance)>=0);
			assertFalse("Map still references contained layers after aggregate removal", _map.layers.indexOf(_l1)>=0 || _map.layers.indexOf(_l2)>=0);
			assertTrue("Contained layers still reference map after removal", _l1.map == null && _l2.map == null);
		}
		
		/**
		 * Checks that opacity is passed along to contained layers
		 */ 
		[Test]
		public function shouldPassOpacityToContainedLayers():void{
			_l1.alpha=0.35;
			_instance.alpha=0.75;
			assertTrue("Opacity is not passed on to contained layers", _l1.alpha==_instance.alpha);
		}
		
		/**
		 * Checks that visibility (when set) is passed along to contained layers
		 */ 
		[Test]
		public function shouldPassVisibilityToContainedLayers():void{
			_l1.visible=false;
			_instance.visible=true;
			assertTrue("Visibility is not passed on to contained layers", _l1.visible ==_instance.visible)
		}
		
		/**
		 * Checks that visibility (when read) is calculated as logical disjonction of contaied layers visibility
		 */ 
		[Test]
		public function shouldOverrideContainedLayerVisibility():void{
			_l1.visible = false;
			_l2.visible = false;
			_instance.visible=true;
			assertTrue("Aggregate don't override visibility of contained layers ", _l1.visible && _l2.visible);
			_l2.visible = false;
			assertTrue("Contained layers visibilty can't be set independantly", !_l2.visible);
			
		}
		
		/**
		 * 
		 */ 
		[Test]
		public function shouldPassDestroyToContainedLayers():void{
			_map.addLayer(_instance);
			_instance.destroy();	
		}
	}
}