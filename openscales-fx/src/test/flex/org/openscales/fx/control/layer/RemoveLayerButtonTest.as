package org.openscales.fx.control.layer{
	
	import org.flexunit.asserts.*;

	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	
	public class RemoveLayerButtonTest{
		
		private var _button:RemoveLayerButton;
		
		public function RemoveLayerButtonTest() {}
		
		[Before]
		public function background():void{
			
			// Given an AddLayerButton configured with a map and a layer
			_button = new RemoveLayerButton();			
			_button.layer = new Layer('someLayer');
			_button.map = new Map();
			
			// And the layer is on the map
			_button.map.addLayer(_button.layer);
		}
		
		/**
		 * Validates that the button removes the layer from the map
		 */
		[Test]
		public function shouldRemoveLayerFromTheMap():void{
						
			// When removing the layer from the map
			_button.removeLayerFromMap();
			
			// Then the layer is no longer in the map
			assertNull('Layer still on the map',_button.layer.map);
			
			// And the button is disabled as there is no need to 
			assertFalse('Button still enabled', _button.enabled);
		}
		
		/**
		 * Validates that the button goes enabled when its layer
		 * is added to the map
		 */
		[Test]
		public function shouldBeEnabledWhenLayerIsAddedToTheMap():void{
			
			// Given the layer is not on the map
			_button.map.removeAllLayers();
			
			// And button is disabled
			_button.enabled = false;
			
			// When the layer is added to the map
			_button.map.addLayer(_button.layer);
			
			// Then button is enabled
			assertTrue('Button still disabled', _button.enabled); 
		}
		
		
		

	}
}