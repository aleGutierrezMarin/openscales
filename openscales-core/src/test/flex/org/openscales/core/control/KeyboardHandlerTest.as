package org.openscales.core.control
{
	import org.flexunit.asserts.assertEquals;
	import org.openscales.core.Map;
	import org.openscales.core.handler.keyboard.KeyboardHandler;

	public class KeyboardHandlerTest
	{
		private var _instance:KeyboardHandler;
		
		[Before]
		public function setUp():void{
			_instance = new KeyboardHandler(new Map());
		}
		
		[Test]
		public function shouldSetPanNorthKeyCode():void{
			_instance.panNorthKeyCode = 5;
			assertEquals("Pan up key code is incorrect", 5, _instance.panNorthKeyCode);
		}
		
		[Test]
		public function shouldSetPanWestKeyCode():void{
			_instance.panWestKeyCode = 4;
			assertEquals("Pan left key code is incorrect", 4, _instance.panWestKeyCode);
		}
		
		[Test]
		public function shouldSetPanSouthKeyCode():void{
			_instance.panSouthKeyCode = 3;
			assertEquals("Pan down key code is incorrect", 3, _instance.panSouthKeyCode);
		}
		
		[Test]
		public function shouldSetPanEastKeyCode():void{
			_instance.panEastKeyCode = 2;
			assertEquals("Pan right key code is incorrect", 2, _instance.panEastKeyCode);
		}
		
		[Test]
		public function shouldSetZoomInKeyCode():void{
			_instance.zoomInKeyCode = 1;
			assertEquals("zoom in key code is incorrect", 1, _instance.zoomInKeyCode);
		}
		
		[Test]
		public function shouldSetZoomOutKeyCode():void{
			_instance.zoomOutKeyCode = 6;
			assertEquals("zoom out key code is incorrect", 6, _instance.zoomOutKeyCode);
		}
		
		[Test]
		public function shouldSetPanStep():void{
			_instance.panStep = 20;
			assertEquals("pan step is incorrect", 20, _instance.panStep);
		}
		
		[Test]
		public function shouldSetPanStepShitKey():void{
			_instance.panStepShiftkey = 30;
			assertEquals("pan step with shift key is incorrect", 30, _instance.panStepShiftkey);
		}
	}
}