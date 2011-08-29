package org.openscales.fx.control.layer
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.events.SliderEvent;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.control.layer.LayerManager;
	import org.openscales.fx.control.layer.LayerZoomToExtent;
	import org.openscales.geometry.basetypes.Bounds;
	
	public class LayerZoomToExtentTest
	{		
		/**
		 * Basic controls for testing
		 */
		private var _map:Map = null;
		private var _layer1:Layer = null;
		private var _layer2:Layer = null;
		private var _zoom:LayerZoomToExtent = null;
		private const RESOLUTION:Number = 0.3515625;
		private const PRECISION:Number = 1e-6;
		
		public function LayerZoomToExtentTest() {}
		
		[Before]
		public function setUp():void
		{
			_map = new Map(200,200);
			_layer1 = new Layer("layer1");
			_map.addLayer(_layer1);
			_layer2 = new Layer("layer2");
			_layer2.maxExtent = new Bounds(-10,-10,10,10);
			_map.addLayer(_layer2);
			_zoom = new LayerZoomToExtent();
			_zoom.layer = _layer2;
		}
		
		[Test]
		public function shouldZoomToExtentOnClick():void
		{
			_zoom.setLayerExtent(new MouseEvent(MouseEvent.CLICK));
			Assert.assertTrue("map extent should be equal to layer maxextent",_layer2.maxExtent.equals(_map.extent));
		}
	}
}