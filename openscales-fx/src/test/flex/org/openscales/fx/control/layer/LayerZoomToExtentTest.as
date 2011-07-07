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
	
	public class LayerZoomToExtentTest extends OpenScalesTest
	{		
		/**
		 * Basic controls for testing
		 */
		private var _map:Map = null;
		private var _layer1:Layer = null;
		private var _zoom:LayerZoomToExtent = null;
		
		private var _timer:Timer;
		private const THICK_TIME:uint = 1200;
		
		[Before]
		override public function setUp():void
		{
			super.setUp()
				
			_map = new Map();
			_layer1 = new Layer("layer");
			_map.addLayer(_layer1);
			_zoom = new LayerZoomToExtent();
			_zoom.layer = _layer1;
			
			this._container.addElement(_zoom);
			
			this._timer = new Timer(THICK_TIME);
		}
		
		[After]
		override public function tearDown():void
		{
			super.tearDown();
			_timer.stop();
			//_timer = null
		}
		
		
		
		[Test]
		public function shouldClickZoomToExtentTest():void
		{
			
			_zoom.setLayerExtent(new MouseEvent(MouseEvent.CLICK));
			
			this._timer.addEventListener(TimerEvent.TIMER,assertClickZoomToExtentTest);
			
		}
		
		private function assertClickZoomToExtentTest():void{
			var maxExtent:Bounds = _layer1.maxExtent;
			
			Assert.assertEquals(maxExtent, _map.extent);
		}
	}
}