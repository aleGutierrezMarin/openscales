package org.openscales.core.handler.keyboard
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.Label;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMS;

	/**
	 * This class tests the KeyboardHandler class
	 * 
	 */ 
	//TODO Zooming function need to be tested with Automation	
	public class KeyboardHandlerTest
	{
		
		private var _map:Map;
		private var _layer:Layer;
		private var _oldX:Number;
		private var _oldY:Number; 
		private var _event:KeyboardEvent;
		private var _oldZoom:Number;
		
		public function KeyboardHandlerTest() {}
		
		[Before]
		public function prepareResource():void
		{
			_map= new Map(600,400);
			_map.addControl(new KeyboardHandler(_map,true));
			_layer = new Layer("sampleLayer");
			_layer.projection="EPSG:900913";
			_map.addLayer(_layer, true);
			_oldX = _map.center.x;
			_oldY = _map.center.y;
		}
		
		/**
		 * this method test paning west functionnality by firing a KeyboardEvent
		 */
		[Test] 
		public function testPanWestWithDefaults():void
		{
			_event = new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,false,0,Keyboard.LEFT,0,false,false,false);		
			_map.dispatchEvent(_event);
			// Y should be unchanged
			assertEquals(_map.center.y,_oldY);	
			// When paning west, X value should decrease
			assertTrue(_oldX > _map.center.x);
			
		}
		
		/**
		 * this method test paning nort functionnality by firing a KeyboardEvent
		 */
		[Test]
		public function testPanNorthWithDefaults():void
		{
			_event = new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,false,0,Keyboard.UP,0,false,false,false);		
			_map.dispatchEvent(_event);
			// X should be unchanged
			assertEquals(_map.center.x,_oldX);	
			// When paning west, Y value should increase
			assertTrue(_oldY < _map.center.y);
		}
		
		/**
		 * this method test paning east functionnality by firing a KeyboardEvent
		 */
		[Test]
		public function testPanEastWithDefaults():void
		{
			_event = new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,false,0,Keyboard.RIGHT,0,false,false,false);		
			_map.dispatchEvent(_event);
			// Y should be unchanged
			assertEquals(_map.center.y,_oldY);	
			// When paning west, X value should increase
			assertTrue(_oldX < _map.center.x);
		}
		
		/**
		 * this method test paning south functionnality by firing a KeyboardEvent
		 */
		[Test]
		public function testPanSouthWithDefaults():void
		{
			_event = new KeyboardEvent(KeyboardEvent.KEY_DOWN,true,false,0,Keyboard.DOWN,0,false,false,false);		
			_map.dispatchEvent(_event);
			// X should be unchanged
			assertEquals(_map.center.x,_oldX);	
			// When paning west, Y value should decrease
			assertTrue(_oldY > _map.center.y);
		}
	}
}