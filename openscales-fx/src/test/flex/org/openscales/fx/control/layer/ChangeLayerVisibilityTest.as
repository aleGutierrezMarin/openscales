package org.openscales.fx.control.layer
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.SliderEvent;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.control.layer.ChangeLayerVisibility;
	import org.openscales.fx.control.layer.LayerManager;
	
	import spark.components.Application;
	import spark.components.Group;
	
	public class ChangeLayerVisibilityTest
	{		
		/**
		 * Basic controls for testing
		 */
		private var _map:Map;
		private var _layer1:Layer;
		private var _visibility:ChangeLayerVisibility;
		private var _container:Group;
		
		public function ChangeLayerVisibilityTest() {}
		
		[Before]
		public function setUp():void
		{
			this._container = new Group();
			
			(FlexGlobals.topLevelApplication as Application).addElement(this._container);
			
			this._map = new Map();
			this._layer1 = new Layer("layer");
		
			this._map.addLayer(this._layer1);
			
			this._visibility = new ChangeLayerVisibility();
			this._visibility.layer = this._layer1;
			
			this._container.addElement(this._visibility);
		}
		
		/*[After]
		public function tearDown():void
		{
			if(this._visibility) {
				this._visibility.layer = null;
				this._container.removeElement(this._visibility);
				this._visibility = null;
			}
			
			if(this._map) {
				this._map.removeAllLayers();
			}
			
			if(this._layer1) {
				this._layer1.destroy();
				this._layer1 = null;
			}
			
			if(this._map) {
				this._map = null;
			}
			
			if(FlexGlobals && FlexGlobals.topLevelApplication && (FlexGlobals.topLevelApplication is Application))
				(FlexGlobals.topLevelApplication as Application).removeElement(this._container);
		}*/
		
		/**
		 * Test if the layer visibility is set to false when the checkbox is unchecked
		 */
		[Test]
		public function hideLayerTest():void
		{
			this._layer1.visible = true;
			this._visibility.layerVisible(new MouseEvent(MouseEvent.CLICK));
			
			Assert.assertFalse(this._layer1.visible);
		}
		
		/**
		 * Test if the layer visibility is set to true when the checkbox is checked
		 */
		[Test]
		public function showLayerTest():void
		{
			this._layer1.visible = false;
			this._visibility.layerVisible(new MouseEvent(MouseEvent.CLICK));
			
			Assert.assertTrue(this._layer1.visible);
		}
		
		/**
		 * Test if the checkbox is unchecked when a layer is not visible
		 */
		[Test]
		public function hiddenLayerEvent():void
		{
			this._layer1.visible = false;
			
			Assert.assertFalse(this._visibility.layerSwitcherCheckBox.selected);
		}
		
		/**
		 * Test if the checkbox is checked when a layer is visible
		 */
		[Test]
		public function showLayerEvent():void
		{
			this._layer1.visible = true;
			
			Assert.assertTrue(this._visibility.layerSwitcherCheckBox.selected);
		}
	}
}