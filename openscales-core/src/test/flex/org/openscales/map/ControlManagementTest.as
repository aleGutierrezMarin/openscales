package org.openscales.map{
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.ui.KeyLocation;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import org.flexunit.asserts.*;
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.control.Control;
	import org.openscales.core.control.IControl;
	import org.openscales.core.handler.keyboard.KeyboardHandler;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	public class ControlManagementTest{
		
		private var _keyboardNavigation:KeyboardHandler;
		private var _timer:Timer;
		private var _map:Map;
		private const THINK_TIME:uint = 500;
		private var _handler:Function = null;
		private var _startResolution:Number = 0.01;
		
		public function ControlManagementTest() {}
		
		[Test]
		public function shouldContainControlAfterItIsAdded():void{
			
			// Given a map
			var map:Map = new Map();
			
			// When a control is added to the map
			var control:Control = new Control();
			map.addControl(control);
			
			// Then the map contains the control
			this.assertControlIsOnTheMap(map,control);
			
			// And the control is properly linked to the map
			assertEquals("Control is not linked to the map", map, control.map);
		}
		
		[Test]
		public function shouldContainControlButNotAsAChildAfterItIsAdded():void{
			
			// Given a map
			var map:Map = new Map();
			
			// When a control is added but not attached to the map
			var control:Control = new Control();
			map.addControl(control, false);
			
			// Then the map contains the control
			this.assertControlIsOnTheMap(map,control);
			
			// And the control is properly linked to the map
			assertEquals("Control is not linked to the map", map, control.map);
			
			// But the control is not displayed on the map
			assertNull("Control parent is not null",control.parent);
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
			assertTrue("Map still contains the control", map.controls.indexOf(control) == -1);
		}
		
		[Test]
		public function shouldCorrectlyRemoveAControlNotDisplayedInTheMap():void{
			
			// Given a map
			var map:Map = new Map();
			
			// And a control added to the map, without displaying it
			var control:Control = new Control();
			map.addControl(control, false);
			
			// When the control is removed
			map.removeControl(control);
			
			// Then the map no longer contains the control
			assertTrue("Map still contains the control", map.controls.indexOf(control) == -1);
			
			// And no exception was thrown ...
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
		
		// --- Utility methods --- //
		private function assertControlIsOnTheMap(map:Map,control:IControl):void{
			
			assertTrue("Map does not contain the control",map.controls.indexOf(control) != -1);
		}
		
		[Test]
		public function souldContainControlsAfterTheyAreAdded():void{
			
			// Given a map
			this._map = new Map();
			
			// And some controls not yet added to the map
			var control1:Control = new Control();
			var control2:Control = new Control();
			
			// When the controls are added to the map
			this._map.addControl(control1);
			this._map.addControl(control2);
			
			this.assertMapContainsControl(this._map,control1);
			this.assertMapContainsControl(this._map,control2);
		}
		
		[Test]
		public function shouldNotContainControlAfterItIsRemoved():void{
			
			// Given a map
			this._map = new Map();
			
			// And a control added to this map
			var control:Control = new Control();
			this._map.addControl(control);
			
			// When a control is added to the map
			this._map.removeControl(control);
			
			// Then the map no longer contains the control
			assertTrue("Map still contains the control",this._map.controls.indexOf(control) == -1);
		}
		
		// --- Utility methods --- //
		private function assertMapContainsControl(map:Map,control:IControl):void{
			
			assertTrue("Map does not contain the control : "+control,map.controls.indexOf(control) != -1);
		}
		
		
		
		// KeyboardNavigation added to the map
		[Test(async)]
		public function shouldContainKeyboardNavigationAfterItIsAdded():void{
			
			this._timer = new Timer(THINK_TIME);
			
			// Given a map without KeyboardNavigation
			this._map = new Map();
			this._map.size = new Size(300,300);
			this._map.center = new Location(0,0);
			this._map.projection = "EPSG:4326";
			this._map.center = new Location(0,0,"EPSG:4326");
			this._map.resolution = new Resolution(this._startResolution,"EPSG:4326");
			
			var mapnik:Mapnik = new Mapnik('mapnik');
			this._map.addLayer(mapnik);
			
			// Add a KeyboardNavigation to this map
			this._keyboardNavigation = new KeyboardHandler();
			this._map.addControl(this._keyboardNavigation);
			
			this._handler = Async.asyncHandler(this,this.onTimer,2000,[
				// When user presses the numeric keypad 'plus' key
				[this.keyDown,Keyboard.NUMPAD_ADD],
				
				// Then the map is zoomed in accordingly
				this.assertMapZoomedIn]);
			
			this._timer.addEventListener(TimerEvent.TIMER,this._handler);
			this._timer.start();
		}
		
		// KeyboardNavigation removed from the map
		[Test(async)]
		public function shouldNotContainKeyboardNavigationAfterItIsRemoved():void{
			
			this._timer = new Timer(THINK_TIME);
			
			// Given a map with a KeyboardNavigation
			this._map = new Map();
			this._map.size = new Size(300,300);
			this._map.projection = "EPSG:4326";
			this._map.center = new Location(0,0,"EPSG:4326");
			this._map.resolution = new Resolution(this._startResolution,"EPSG:4326");
			
			var mapnik:Mapnik = new Mapnik('mapnik');
			this._map.addLayer(mapnik);
			//_map.zoom = 11;
			this._keyboardNavigation = new KeyboardHandler();
			this._map.addControl(this._keyboardNavigation);
			
			// Remove the KeyboardNavigation from this map
			this._map.removeControl(this._keyboardNavigation);
			
			var handler:Function = Async.asyncHandler(this,this.onTimer,2000,[
				// When user presses the numeric keypad 'plus' key
				[this.keyDown,Keyboard.NUMPAD_ADD],
				
				// Then the map isn't zoomed in
				this.assertMapNotZoomedIn]);
			
			this._timer.addEventListener(TimerEvent.TIMER,handler);
			this._timer.start();
		}
		
		// When user presses the numeric keypad 'plus' key
		private function keyDown(keyCode:uint):void{
			
			var event:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,false,0,keyCode,KeyLocation.NUM_PAD);
			this._map.dispatchEvent(event);
		}
		
		// Then the map is zoomed in accordingly
		private function assertMapZoomedIn():void{
			assertEquals('Map zoom level is not correct',this._startResolution*org.openscales.core.Map.DEFAULT_ZOOM_IN_FACTOR,this._map.resolution.value);
		}
		
		// Then the map isn't zoomed in
		private function assertMapNotZoomedIn():void{
			
			assertEquals('Map zoom level is not correct',this._startResolution,this._map.resolution.value);
		}
		
		// Utility function
		private function onTimer(event:TimerEvent,passThroughData:Object):void{
			
			var steps:Array = passThroughData as Array;
			
			if(steps.length){
				var step:Object = steps.shift();
				var f:Function = null;
				var args:Array = [];
				
				if(step is Function){
					f = step as Function;
				}
				else{
					f = step.shift() as Function;
					args = step as Array;
				}
				
				f.apply(this,args);
				var handler:Function = Async.asyncHandler(this,this.onTimer,2000,steps);
				this._timer.addEventListener(TimerEvent.TIMER,handler);
			}
			else{
				this._timer.stop();
			}
		}
	}
}