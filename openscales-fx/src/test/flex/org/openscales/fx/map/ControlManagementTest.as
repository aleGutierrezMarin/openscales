package org.openscales.fx.map{
	import org.flexunit.asserts.*;
	import org.openscales.core.control.Control;
	import org.openscales.core.control.IControl;
	import org.openscales.fx.FxMap;
	
	public class ControlManagementTest{		

		[Test]
		public function shouldContainControlAfterItIsAdded():void{
			
			// Given a map
			var map:FxMap = new FxMap();
			var initialControlCount:uint = map.controls.length;
			
			// When a control is added to the map
			var control:Control = new Control();
			map.addControlToFxMapControlsList(control);
			
			// Then the map contains the control
			assertTrue("Map does not contain the control",map.controls.some(function(item:Control,index:uint,controls:Vector.<IControl>):Boolean{
				return item === control;
			}));
		}
		
	}
}