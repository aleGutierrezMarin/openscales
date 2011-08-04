package
{
	import mx.core.FlexGlobals;
	
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.control.IControl;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.FxMap;
	
	import spark.components.Application;
	import spark.components.Group;

	/**
	 * Root class of testings in Geoportal.
	 * All the testing classes should extends this class
	 * In this class you can implements all the methods that you will use in differents test classes.
	 * This class contain an atribute named container where you can add your flex components. It's initialized in the setUp method and destroyed in the tearDown method. So it's refreshed for each test.
	 */
	public class OpenScalesTest
	{
		
		/**
		 * This atribute will contain the flex components that will be tested.
		 * You need to use _container.addElement(yourComponent) in order to initialize your component and being able to test it
		 */ 
		protected var _container:Group;
		
		public function OpenScalesTest() {
			this._container = new Group();
		}
		
		/**
		 * This function will be executed before each test.
		 */
		 [Before]
		 public function setUp():void{
			 (FlexGlobals.topLevelApplication as Application).addElement(this._container);
		 }
		 
		 /**
		  * This function will be executed after each test.
		  */
		 [After]
		 public function tearDown():void{
			 (FlexGlobals.topLevelApplication as Application).removeElement(this._container);
		 }
		
		 /**
		 * This method make the test fail if the map does not contain the passed control.
		 * 
		 * @param map The FxMap where you want to find the handler
		 * @param handler The Handler type you want to find in the map
		 */
		public function assertMapHasControl(map:FxMap, control:Class):void{
			
			assertTrue("Map does not contain control of this type : "+control , this.mapHasControl(map, control));
		}
		
		/**
		 * @private
		 * Return true if the passed control exist at least once in the passed map
		 */
		private function mapHasControl(map:FxMap, control:Class):Boolean{
			
			return map.map.controls.some(function(item:IControl, index:uint, vector:Vector.<IControl>):Boolean{
				return (item is control);
			});
		}
		
		/**
		 * This method make the test fail if the map does not contain the passed handler.
		 * 
		 * @param map The FxMap where you want to find the handler
		 * @param handler The Handler type you want to find in the map
		 */
		public function assertMapHasHandler(map:FxMap, handler:Class):void{
			
			assertTrue("Map does not contain handler of this type : "+handler , this.mapHasHandler(map, handler));
		}
		
		/**
		 * @private
		 * Return true if the passed handler exist at least once in the passed map
		 */
		private function mapHasHandler(map:FxMap, handler:Class):Boolean{
			
			return map.map.controls.some(function(item:IHandler, index:uint, vector:Vector.<IHandler>):Boolean{
				return (item is handler);
			});
		}
		
		/**
		 * This method make the test fail if the map does not contain the passed layer.
		 * 
		 * @param map The FxMap where you want to find the layer
		 * @param layer The Layer type you want to find in the map
		 */
		public function assertMapHasLayer(map:FxMap, layer:Class):void{
			
			assertTrue("Map does not contain layer of this type : " + layer, this.mapHasLayer(map, layer));
		}
		
		/**
		 * @private
		 * Return true if the passed layer exist at least once in the passed map
		 */
		private function mapHasLayer(map:FxMap, layer:Class):Boolean{
			
			return map.map.layers.some(function(item:Layer, index:uint, vector:Vector.<Layer>):Boolean{
				return (item is layer);
			});
		}
	}
}