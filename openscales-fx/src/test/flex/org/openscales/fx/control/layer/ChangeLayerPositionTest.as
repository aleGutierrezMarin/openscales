package org.openscales.fx.control.layer
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.control.layer.ChangeLayerPosition;
	import org.openscales.fx.control.layer.LayerManager;
	
	public class ChangeLayerPositionTest extends OpenScalesTest
	{		
		/**
		 * Basic controls for testing
		 */
		private var _map:Map;
		private var _layer1:Layer;
		private var _layer2:Layer;
		private var _layer3:Layer;
		private var _position:ChangeLayerPosition;
		
		public function ChangeLayerPositionTest() {}
		
		[Before(ui)]
		override public function setUp():void
		{
			super.setUp();
			
			this._map = new Map();
			
			this._layer1 = new Layer("layer 1");
			this._layer2 = new Layer("layer 2");
			this._layer3 = new Layer("layer 3");
			
			// add kayers to the current map
			this._map.addLayer(this._layer1);
			this._map.addLayer(this._layer2);
			this._map.addLayer(this._layer3);
			
			// change position control
			this._position = new ChangeLayerPosition();
			this._position.layer = this._layer2;
			
			this._container.addElement(this._position);
		}
		
		[After]
		override public function tearDown():void {
			super.tearDown();
			if(this._position) {
				this._container.removeElement(this._position);
				this._position.layer = null;
				this._position = null;
			}
			
			if(this._map) {
				this._map.removeAllLayers();
				this._map = null;
			}
			
			if(this._layer1) {
				this._layer1.destroy();
				this._layer1 = null;
			}
			
			if(this._layer2) {
				this._layer2.destroy();
				this._layer2 = null;
			}
			
			if(this._layer3) {
				this._layer3.destroy();
				this._layer3 = null;
			}
		}
		
		/**
		 * Test if the index of the layer in the containerChild of map change when the layer is moveUp
		 */
		[Test(ui)]
		public function moveLayerUp():void
		{
			var current:uint = this._map.layers.indexOf(this._layer2);
			this._position.upLayer(new MouseEvent(MouseEvent.MOUSE_DOWN));			
			Assert.assertEquals(current+1, this._map.layers.indexOf(this._layer2));
		}
		
		/**
		 * Test if the index of the layer in the containerChild of map change when the layer is moveDown
		 */
		[Test(ui)]
		public function moveLayerDown():void
		{
			var current:uint = this._map.layers.indexOf(this._layer2);		
			this._position.downLayer(new MouseEvent(MouseEvent.MOUSE_DOWN));	
			Assert.assertEquals(current-1, this._map.layers.indexOf(this._layer2));
		}
	}
}