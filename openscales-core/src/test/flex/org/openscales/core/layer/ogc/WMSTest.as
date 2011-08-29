package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.TileEvent;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Size;

	public class WMSTest
	{		
		
		private const NAME:String = "WMS Layer";
		private const URL:String = "http://some.domain.com/wms";
		private const PROJECTION:String = "EPSG:4326";
		private const LAYERS:String = "bluemarble";
		private const FORMAT:String = "image/jpeg";
		private const MAXEXTENT:Bounds = new Bounds(-180, -90, 180, 90);
		private const VERSION:String = "1.1.1";
		
		private var _map:Map = null;
		private var _wms:WMS = null;
		
		private var _timer:Timer = null;
		private const THICK_TIME:uint = 800;
		
		public function WMSTest() {}
		
		[Before]
		public function setUp():void
		{
			this._timer = new Timer(THICK_TIME);
			this._timer.start();
		}
		
		[After]
		public function tearDown():void
		{
			this._timer.stop();
			_map.removeAllLayers();
			_wms.destroy();
			_wms = null;
			_map = null;
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		/**
		 * @private
		 * On timer function to launch method asynchronous on timer event
		 * @param event The event received
		 * @param passThroughData An object given as parameter for the function to call
		 */
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
		
		/**
		 * Test the correct initialisation of the grid
		 * 
		 * <ul>
		 * <li>Given a Map and a WMS layer with tiled=true and a default tileOrigin</li>
		 * <li>When the WMS layer is added to the map</li>
		 * <li>Then the tiles bounds in the grid should be calculated according to the default tileOrigin</li>
		 * </ul>
		 * 
		 */
		[Test(async)] 
		public function shouldInitialiseTheGirdWithCorrectTileOrigin():void
		{
			// Given a Map and a WMS layer with tiled=true and a default tileOrigin
			_map = new Map();
			_map.size = new Size(200,200);
			_map.center = new Location(0,0);
	
			_wms = new WMS(NAME, URL, LAYERS, "", FORMAT);
			_wms.maxExtent = MAXEXTENT;
			_wms.version = VERSION;
			_wms.tiled = true;
			
			// When the WMS layer is added to the map
			_map.addLayer(_wms);
			
			// Then the tiles bounds in the grid should be calculated according to the default tileOrigin
			var currentGrid:Vector.<Vector.<ImageTile>> = _wms.grid;
			
			var widthRatio:Number = currentGrid[0][0].bounds.right - currentGrid[0][0].bounds.left;
			var heightRatio:Number = currentGrid[0][0].bounds.top - currentGrid[0][0].bounds.bottom;
			
			var offsetcol:Number = (currentGrid[0][0].bounds.left - _wms.tileOrigin.lon) / widthRatio;
			var offsetrow:Number = (currentGrid[0][0].bounds.top - _wms.tileOrigin.lat) / heightRatio;
			
			var i:int = 0;
			var j:int = 0;
			var rows:int = currentGrid.length;
			var cols:int = 0;
			
			_wms.map.resolution = new Resolution(1.40625,"EPSG:4326");
			var tileOrigin:Location = _wms.tileOrigin;
			var resolution:Resolution = _wms.map.resolution;
			var tileHeight:Number = _wms.tileHeight;
			var tileWidth:Number = _wms.tileWidth;
			
			for(; i<rows; ++i)
			{
				cols = currentGrid[i].length;
				for(j=0; j<cols; ++j)
				{
					// The request grid coordonates
					var x:int = j + offsetcol;
					var y:int = offsetrow - i;
					
					// The bounds values for the curent tile checked
					var left:Number = tileOrigin.lon + (tileWidth*resolution.value*x);
					var right:Number = tileOrigin.lon + (tileWidth*resolution.value*(x+1));
					var top:Number = tileOrigin.lat + (tileHeight*resolution.value*(y));
					var bottom:Number = tileOrigin.lat + (tileHeight*resolution.value*(y-1));
					
					Assert.assertEquals("Incorrect value for tile left bounds "+j+","+i, left, currentGrid[i][j].bounds.left);
					Assert.assertEquals("Incorrect value for tile right bounds "+j+","+i, right, currentGrid[i][j].bounds.right);
					Assert.assertEquals("Incorrect value for tile bottom bounds "+j+","+i, bottom, currentGrid[i][j].bounds.bottom);
					Assert.assertEquals("Incorrect value for tile top bounds "+j+","+i, top, currentGrid[i][j].bounds.top);
					
				}
			}
		}
		
		/**
		 * Test the correct update of the WMS grid when the tileOrigin is changed
		 * 
		 * <ul>
		 * <li>Given a Map with a WMS layer with tiled=true</li>
		 * <li>When the tileOrigin is set</li>
		 * <li>Then the tiles bounds in the grid should be calculated according to the current tileOrigin</li>
		 * </ul>
		 * 
		 */
		[Test(async)]
		public function shouldChangeGridWithCorrectTileOriginOnTileOriginValueChange():void
		{
			// Given a Map with a WMS layer with tiled=true
			_map = new Map();
			_map.size = new Size(200,200);
			_map.center = new Location(0,0);
			_map.resolution = new Resolution(1.40625,"EPSG:4326");
			
			_wms = new WMS(NAME, URL, LAYERS, "", FORMAT);
			_wms.maxExtent = MAXEXTENT;
			_wms.version = VERSION;
			_wms.tiled = true;
			
			_map.addLayer(_wms);
			
			// When the tileOrigin is set
			_wms.tileOrigin = new Location(4,56,_wms.map.projection);
			
			var handler:Function = Async.asyncHandler(this,this.onTimer,2000,[
				[this.assertChangeGridWithCorrectTileOriginOnTileOriginValueChange]] );
			
			this._timer.addEventListener(TimerEvent.TIMER,handler);
		}
		
		
		private function assertChangeGridWithCorrectTileOriginOnTileOriginValueChange():void
		{
			// Then the tiles bounds in the grid should be calculated according to the current tileOrigin
			var currentGrid:Vector.<Vector.<ImageTile>> = _wms.grid;
			
			var widthRatio:Number = currentGrid[0][0].bounds.right - currentGrid[0][0].bounds.left;
			var heightRatio:Number = currentGrid[0][0].bounds.top - currentGrid[0][0].bounds.bottom;
			
			var tileOrigin:Location = _wms.tileOrigin;
			
			var offsetcol:Number = (currentGrid[0][0].bounds.left - tileOrigin.lon) / widthRatio;
			var offsetrow:Number = (currentGrid[0][0].bounds.top - tileOrigin.lat) / heightRatio;
			
			var i:int = 0;
			var j:int = 0;
			var rows:int = currentGrid.length;
			var cols:int = 0;
			
			
			var resolution:Resolution = _wms.getSupportedResolution(_wms.map.resolution);
			var tileHeight:Number = _wms.tileHeight;
			var tileWidth:Number = _wms.tileWidth;
			
			for(; i<rows; ++i)
			{
				cols = currentGrid[i].length;
				for(j=0; j<cols; ++j)
				{
					// The request grid coordonates
					var x:int = j + offsetcol;
					var y:int = offsetrow - i;
					
					// The bounds values for the curent tile checked
					var left:Number = tileOrigin.lon + (tileWidth*resolution.value*x);
					var right:Number = tileOrigin.lon + (tileWidth*resolution.value*(x+1));
					var top:Number = tileOrigin.lat + (tileHeight*resolution.value*(y));
					var bottom:Number = tileOrigin.lat + (tileHeight*resolution.value*(y-1));
					
					Assert.assertEquals("Incorrect value for tile left bounds "+j+","+i, left, currentGrid[i][j].bounds.left);
					Assert.assertEquals("Incorrect value for tile right bounds "+j+","+i, right, currentGrid[i][j].bounds.right);
					Assert.assertEquals("Incorrect value for tile bottom bounds "+j+","+i, bottom, currentGrid[i][j].bounds.bottom);
					Assert.assertEquals("Incorrect value for tile top bounds "+j+","+i, top, currentGrid[i][j].bounds.top);
					
				}
			}
		}
		
		/**
		 * Validate that if the map extent is greater than the layer maxExtent and the map maxExtent,
		 * then, the extent requested is limited by the layer maxExtent and the map maxExtent in not
		 * tiled mode
		 */
		[Test(async)]
		public function shouldRequestAnExtentSmallerIfExtentIsGreaterThanMapAndLayerMaxExtentInNotTiledMode():void
		{
			// Given a map with a layer in untiled mode and a map maxExtend and a Layer maxExtent
			_map = new Map();
			_map.size = new Size(200,200);
			_map.center = new Location(5, 2);
			_map.maxExtent = new Bounds(-180, -90, 10, 10, "EPSG:4326");
			_wms = new WMS(NAME, URL, LAYERS, "", FORMAT);
			_wms.maxExtent = new Bounds(-10, -10, 180, 90, "EPSG:4326");
			_wms.version = VERSION;
			_wms.tiled = false;

			_map.zoomToExtent(new Bounds(-180, -90, 180, 90, "EPSG:4326"));
			
			// When the tile is requested, the map extent is greater and contains the map maxExtent and the layer maxExtent
			_wms.addEventListener(TileEvent.TILE_LOAD_START,Async.asyncHandler(this,function(event:TileEvent,obj:Object):void{
				
				var url:String = event.tile.url;
				var intersectionExtent:Bounds = new Bounds(-10, -10, 10, 10, "EPSG:4326");
				
				// Then the extent requested is smaller and limited by the layer and the map maxExtent
				assertTrue("BBox is not the proper intersection of extends", url.match('BBOX='+intersectionExtent.toString()));
			},2000,null,function(event:Event):void{
				
				Assert.fail("No request sent");
			}));
			
			_map.addLayer(_wms);
		}
		
		/**
		 * Validate that if the map extent is smaller than the layer maxExtent and the map maxExtent,
		 * then the extent requested is the map extent in not tiled mode.
		 */
		[Test(async)]
		public function shouldResquestionTheMapExtentIfItsSmallerThanMapAndAlyerMaxExtentInNotTiledMode():void
		{
			// Given a map with a layer in untiled mode and a map maxExtent and a Layer maxExtent
			_map = new Map();
			_map.size = new Size(200,200);
			_map.center = new Location(5, 2);
			
			// this is a dummy BaseLayer added to force the map to have her how maxExtent. 
			// while refactoring openscales to remove the base layer just set the maxExtent of the map
			// instead of setting a baseLayer : _map.maxExtent = new Bounds(-180, -90, 180, 90, "EPSG:4326");
			var _dummyMaxExtent:WMS = new WMS(NAME, URL, LAYERS, "", FORMAT);
			_dummyMaxExtent.maxExtent = new Bounds(-180, -90, 180, 90, "EPSG:4326");
			_map.addLayer(_dummyMaxExtent);
			
			_wms = new WMS(NAME, URL, LAYERS, "", FORMAT);
			_wms.maxExtent = new Bounds(-180, -90, 180, 90, "EPSG:4326");
			_wms.version = VERSION;
			_wms.tiled = false;
			
			
			_map.zoomToExtent(new Bounds(-40, -50, 40, 50, "EPSG:4326"));
			
			
			// When the tile is requested, the map extent is smaller and is contained by the map maxExtent and the layer maxExtent
			_wms.addEventListener(TileEvent.TILE_LOAD_START,Async.asyncHandler(this,function(event:TileEvent,obj:Object):void{
				
				var url:String = event.tile.url;
				var intersectionExtent:Bounds = new Bounds(-70.3125,-70.3125,70.3125,70.3125, "EPSG:4326");
				
				// Then the extent resquested is the extent of the map
				assertTrue("BBox is not the proper extends", url.match('BBOX='+intersectionExtent.toString()));
			},2000,null,function(event:Event):void{
				
				Assert.fail("No request sent");
			}));
			_map.addLayer(_wms);
		}
	}
}