package org.openscales.fx.control.layer{
	
	import org.flexunit.asserts.*;
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.layer.Layer;
	
	public class AddLayerButtonTest	{
		
		public function AddLayerButtonTest(){}

		private var _button:AddLayerButton;
		
		[Before(ui)]
		public function background():void{
			
			// Given an AddLayerButton configured with a map and a layer
			this._button = new AddLayerButton();			
			this._button.layer = new Layer('someLayer');
			this._button.map = new Map();
		}
		
		/**
		 * Validates that the button properly adds the Layer to the Map
		 */
		[Test]
		public function shouldAddLayerToMapAndDisableButton():void{
					
			// When adding layer to the map
			this._button.addLayerToMap();
			
			// Then layer is in the map
			assertTrue('Layer not on the map', this._button.map.layers.indexOf(this._button.layer) != -1);
			assertFalse('Button still enabled', this._button.enabled);
		}
		
		/**
		 * Validates that when layer is removed from the map
		 * button is enabled again
		 */
		[Test]
		public function shouldBeEnabledWhenRemovingLayerFromTheMap():void{
			
			// Given the button is disabled
			this._button.enabled = true;
			
			// And layer is on the map
			this._button.map.addLayer(this._button.layer);
			
			// When the layer is removed from the map
			this._button.map.removeLayer(this._button.layer);
			
			// Then button is enabled again
			assertTrue('Button still disabled', this._button.enabled);
		}
		
		/**
		 * Validates that the button is disabled when setting a layer
		 * that is allready on the map
		 */
		[Test]
		public function shouldBeDisabledWhenSettingLayerThatHasMap():void{
			
			// When setting a layer that is already on the map
			var layer:Layer = new Layer('2');
			this._button.map.addLayer(layer);
			this._button.layer = layer;
			
			// Then button is disabled
			assertFalse('Button is enabled', this._button.enabled);
		}
		
		/**
		 * Validates that the button is enabled when setting a layer
		 * that is not on the map when button is disabled
		 */
		[Test]
		public function shouldBeEnabledWhenSettingLayerNotOnTheMap():void{
			
			// Given button is disabled
			this._button.enabled = false;
			
			// When setting a layer that is not on the map
			this._button.layer = new Layer('2');
			
			// The button is enabled again
			assertTrue('Button is disabled',this._button.enabled);
		}
	}
}