package org.openscales.fx.control.layer
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
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
		private var _zoom:LayerZoomToExtent = null;
		
		[Before]
		public function setUp():void
		{
			_map = new Map();
			_layer1 = new Layer("layer");
			_map.addLayer(_layer1);
			_zoom = new LayerZoomToExtent();
			_zoom.layer = _layer1;
		}
		
		
		[Test]
		public function clickZoomToExtentTest():void
		{
			var maxExtent:Bounds = _layer1.maxExtent;
			trace("_map.extent "+_map.extent);
			_zoom.setLayerExtent(new MouseEvent(MouseEvent.CLICK));
			trace("_map.extent 2 "+_map.extent);
			Assert.assertEquals(maxExtent, _map.extent);
		}
		
	}
}