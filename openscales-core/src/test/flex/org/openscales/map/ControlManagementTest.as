package org.openscales.map{
	import org.flexunit.asserts.*;
	import org.openscales.core.Map;
	import org.openscales.core.control.Control;
	import org.openscales.core.control.IControl;
	
	public class ControlManagementTest{
		
		[Test]
		public function shouldContainControlAfterItIsAdded():void{
			
			// Given a map
			var map:Map = new Map();
			var initialControlCount:uint = map.controls.length;
			
			// When a control is added to the map
			var control:Control = new Control();
			map.addControl(control);
			
			// Then the map contains the control
			assertTrue("Map does not contain the control",map.controls.some(function(item:Control,index:uint,controls:Vector.<IControl>):Boolean{
				return item === control;
			}));
			
			// And the control is properly linked to the map
			assertEquals("Control is not linked to the map", map, control.map);
		}
		
		[Test]
		public function shouldNotContainControlAfterControlIsRemoved():void{
			
			// Given a map
			var map:Map = new Map();
			
			// And that map has a control
			var control:Control = new Control();
			map.addControl(control);
			var initialControlCount:uint = map.controls.length;
			
			// When the control is removed
			map.removeControl(control);
			
			// Then the map no longer contains the control
			assertFalse("Map still contains the control",map.controls.some(function(item:Control,index:uint,controls:Vector.<IControl>):Boolean{
				return item === control;
			}));
		}
		
		[Test]
		public function shouldReturnTrueWhenControlIsInTheMap():void{
			
			//Given a map
			var map:Map = new Map();
			
			// And a control on this map
			var control:Control = new Control();
			map.addControl(control);
						
			// Then map announces the control is present
			assertTrue("Control not detected in the map", map.hasControl(control));
		}
		
		[Test]
		public function shouldReturnFalseWhenControlInNotInTheMap():void{
			
			// Given a map
			var map:Map = new Map();
			
			// And a control that is not on this map
			var control:Control = new Control();
			
			// Then map announces the control is not present
			assertFalse("Control detected in the map", map.hasControl(control));
		}
		
	}
}