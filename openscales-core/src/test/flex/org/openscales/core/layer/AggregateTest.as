package org.openscales.core.layer
{
	import flexunit.framework.Test;
	
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.flexunit.internals.RealSystem;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.geometry.basetypes.Bounds;
	
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
		public function shouldOnlyBeReferencedInMapAndNotContainedLayers():void{
			_map.addLayer(_instance);
			assertTrue("Map does not reference aggregate", _map.layers.indexOf(_instance)>=0);
			assertTrue("Map references contained layers", _map.layers.indexOf(_l1)<0 && _map.layers.indexOf(_l2)<=0);
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
		public function shouldPassRemovalFromMapToContainedLayers():void{
			_map.addLayer(_instance);
			assertTrue("Contained layers does not reference map", _l1.map==_map && _l2.map==_map);
			assertTrue("Map does not referenc aggregate", _map.layers.indexOf(_instance)>=0);
			_map.removeLayer(_instance);
			assertFalse("Map still contains aggregate after removal", _map.layers.indexOf(_instance)>=0);
			assertFalse("Contained layers still reference map after removal", _l1.map == _map || _l2.map == _map);
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
		public function shouldReturnVisibilityAsDisjonctionOfContainedLayersVisibilty():void{
			_l1.visible = false;
			_l2.visible = false;
			assertFalse("Aggregate visibility is not a disjonction of contained layers", _instance.visible);
			_l2.visible = true;
			assertTrue("Aggregate visibility is not a disjonction of contained layers", _instance.visible);
			
		}
		
		/**
		 * Checks that minimum resolution is passed along to contained layers 
		 */ 
		[Test]
		public function shouldPassMinResolutionToContainedLayers():void{
			_l1.minResolution = new Resolution(5.0);
			_l2.minResolution = new Resolution(4.0);	
			_instance.minResolution = new Resolution(6.0);
			assertTrue("Aggregate min resolution is not passed on contained layers", _l1.minResolution.value == _instance.minResolution.value == _l2.minResolution.value == 6.0);
		}
		
		/**
		 * Checks that maximum resolution is passed along to contained layers
		 */
		[Test]
		public function shouldPassMaxResolutionToContainedLayers():void{		
			_l1.maxResolution = new Resolution(7.0);
			_l2.maxResolution = new Resolution(8.0);
			_instance.maxResolution = new Resolution(6.0);
			assertTrue("Aggregate max resolution is not passed on contained layers", _l1.maxResolution.value == _instance.maxResolution.value == _l2.maxResolution.value == 6.0);
		}
		
		/**
		 * Checks that maxExtent is passed along to contained layers.  
		 */ 
		[Test]
		public function shouldPassMaxExtentToContainedLayers():void{
			var l1MaxExtent:Bounds = new Bounds(-5,-30,10,40,_l1.projection);
			var l2MaxExtent:Bounds = new Bounds(-7,-35,12,45,_l1.projection);
			var insMaxExtent:Bounds = new Bounds(-4,25,15,53, _l1.projection)
			
			_l1.maxExtent = l1MaxExtent;
			_l2.maxExtent = l2MaxExtent;
			_instance.maxExtent = insMaxExtent;
			
			assertTrue("Max extent is not passed along to contained layers");
		}
		
		/**
		 * Checks that originators are passed along to contained layers
		 */ 
		[Test]
		public function shouldPassOriginatorsToContainedLayers():void{
			fail("Not yet implemented");
		}
		
		
	}
}