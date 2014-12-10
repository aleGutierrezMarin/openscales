package org.openscales.core.handler.mouse
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.Map;
	
	public class MouseHandlerTest
	{
		private var _instance:MouseHandler;
		private var _map:Map;
		
		public function MouseHandlerTest()
		{
		}
		
		[Test]
		public function shouldAddMap():void{
			_map = new Map();
			_instance = new MouseHandler(_map);
			assertEquals("Map should be set",_instance.map, _map);
			assertTrue("Map should contain control", _map.controls.indexOf(_instance)>=0);
		}
		
		[Test]
		public function shouldHaveZoomBoxDisableByDefault():void{
			_map = new Map();
			_instance = new MouseHandler(_map);
			assertTrue("", _instance.zoomBoxEnabled);
		}
	}
}