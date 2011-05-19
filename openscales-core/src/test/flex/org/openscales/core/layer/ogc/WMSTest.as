package org.openscales.core.layer.ogc{
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.flexunit.async.AsyncHandler;
	import org.openscales.core.Map;
	import org.openscales.core.events.TileEvent;
	import org.openscales.core.tile.Tile;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;
	
	public class WMSTest{
		
		public function WMSTest(){
			
			
		}
		
		// Timer for async tests timeout
		private var _timer:Timer;
		
		// List of loaded tiles, in the order they are requested
		private var _tiles:Vector.<Tile>;
		
		[Before]
		public function startTimer():void{
			this._timer = new Timer(100, 1);
			this._tiles = new Vector.<Tile>();
		}
		
		[After]
		public function stopTimer():void{
			
			if(this._timer){
				
				this._timer.stop();
			}
			this._timer = null;
			this._tiles = null;
		}
		
		[Test(async)]
		public function testShouldRequestOnlyOneTileWhenDrawn():void{
			
			// Given a 600X600 map, centered on (4,58) at zoom level 5
			this._timer.delay = 100;
			var map:Map = new Map();
			map.center = new Location(4,58);
			map.zoom = 15;
			
			map.size = new Size(800,600);
			
			// When a wms layer (untiled) is added
			var wms:WMS = new WMS('Tested layer','http://some.domain.com/wms','theLayer','theStyle');
			wms.tiled = false;
			
			var handler:Function = Async.asyncHandler(this,this.assertOnlyOneTileWasRequested,150, null,this.timeoutHandler);
			wms.addEventListener(TileEvent.TILE_LOAD_START, this.onTileLoadStart);	
			map.addLayer(wms);
			wms.redraw(true);
			
			trace(map.resolution);
			
			this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,handler);
			this._timer.start();
		}
				
		private function onTileLoadStart(event:TileEvent):void{
			
			trace('Tile loaded');
			this._tiles.push(event.tile);
		}
		
		private function assertOnlyOneTileWasRequested(event:TimerEvent, passThroughData:Object):void{
			
			Assert.assertEquals("Layer should have loaded one tile",1,this._tiles.length);
						
			var tile:Tile = this._tiles.pop();
			var url:String = tile.url;
			trace(tile.url);
						
			Assert.assertTrue("Tile does not request the appropriate layers : \n"+url, url.match('LAYERS=theLayer'));
			Assert.assertTrue("Tile does not request appropriate bounding box : \n"+url, url.match('BBOX=-48.625,5.375,56.625,108.625'));
			Assert.assertTrue("Tile does not request appropriate service :\n"+url, url.match('SERVICE=WMS'));
			Assert.assertTrue("Tile does not request appropriate version :\n"+url, url.match('VERSION=1.3.0'));
		}
		
		private function timeoutHandler(event:TimerEvent):void{
			
			Assert.fail("Shouldn't happen");
		}
	}
}