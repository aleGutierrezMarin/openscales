package org.openscales.core.layer.ogc
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
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
				var handler:Function = Async.asyncHandler(this,this.onTimer,800,steps);
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

			var handler:Function = Async.asyncHandler(this,this.onTimer,1200,[
				[this.assertInitialiseTheGirdWithCorrectTileOrigin]] );
			
			this._timer.addEventListener(TimerEvent.TIMER,handler);
		}
		
		private function assertInitialiseTheGirdWithCorrectTileOrigin():void
		{
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
			
			var tileOrigin:Location = _wms.tileOrigin;
			var resolution:Number = _wms.map.resolution;
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
					var left:Number = tileOrigin.lon + (tileWidth*resolution*x);
					var right:Number = tileOrigin.lon + (tileWidth*resolution*(x+1));
					var top:Number = tileOrigin.lat + (tileHeight*resolution*(y));
					var bottom:Number = tileOrigin.lat + (tileHeight*resolution*(y-1));
					
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
			
			_wms = new WMS(NAME, URL, LAYERS, "", FORMAT);
			_wms.maxExtent = MAXEXTENT;
			_wms.version = VERSION;
			_wms.tiled = true;
			
			_map.addLayer(_wms);
			
			// When the tileOrigin is set
			_wms.tileOrigin = new Location(4,56,_wms.map.baseLayer.projSrsCode);
			
			var handler:Function = Async.asyncHandler(this,this.onTimer,1200,[
				[this.assertChangeGridWithCorrectTileOriginOnTileOriginValueChange]] );
			
			this._timer.addEventListener(TimerEvent.TIMER,handler);
		}
		
		
		private function assertChangeGridWithCorrectTileOriginOnTileOriginValueChange():void
		{
			// Then the tiles bounds in the grid should be calculated according to the current tileOrigin
			var currentGrid:Vector.<Vector.<ImageTile>> = _wms.grid;
			
			var widthRatio:Number = currentGrid[0][0].bounds.right - currentGrid[0][0].bounds.left;
			var heightRatio:Number = currentGrid[0][0].bounds.top - currentGrid[0][0].bounds.bottom;
			
			var offsetcol:Number = (currentGrid[0][0].bounds.left - _wms.tileOrigin.lon) / widthRatio;
			var offsetrow:Number = (currentGrid[0][0].bounds.top - _wms.tileOrigin.lat) / heightRatio;
			
			var i:int = 0;
			var j:int = 0;
			var rows:int = currentGrid.length;
			var cols:int = 0;
			
			var tileOrigin:Location = _wms.tileOrigin;
			var resolution:Number = _wms.map.resolution;
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
					var left:Number = tileOrigin.lon + (tileWidth*resolution*x);
					var right:Number = tileOrigin.lon + (tileWidth*resolution*(x+1));
					var top:Number = tileOrigin.lat + (tileHeight*resolution*(y));
					var bottom:Number = tileOrigin.lat + (tileHeight*resolution*(y-1));
					
					Assert.assertEquals("Incorrect value for tile left bounds "+j+","+i, left, currentGrid[i][j].bounds.left);
					Assert.assertEquals("Incorrect value for tile right bounds "+j+","+i, right, currentGrid[i][j].bounds.right);
					Assert.assertEquals("Incorrect value for tile bottom bounds "+j+","+i, bottom, currentGrid[i][j].bounds.bottom);
					Assert.assertEquals("Incorrect value for tile top bounds "+j+","+i, top, currentGrid[i][j].bounds.top);
					
				}
			}
		}
	}
}