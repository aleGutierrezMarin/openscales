package org.openscales.map
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	
	public class MapExtentTest
	{
		private var _map:Map = null;
		private var _bounds:Bounds = null;
		private var _timer:Timer;
		private const THINK_TIME:uint = 500;
		private var _handler:Function = null;
		
		private static const EPSILON:Number = 0.0000001;
		
		private static const DX:Number = 1000;
		private static const DY:Number = 1000;
		
		private static const CENTER:Location = new Location(2.81,45.52,"EPSG:4326");
		private static const RESOLUTION:Resolution = new Resolution(0.001,"EPSG:4326");
		
		public function MapExtentTest(){}
		
		[Before]
		public function setUp():void
		{
			this._timer = new Timer(THINK_TIME);
		}
		
		[After]
		public function tearDown():void
		{
			if(this._handler!=null)
				this._timer.removeEventListener(TimerEvent.TIMER,this._handler);
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
		 * Validates that the param restrictedExtent is correctly set
		 */
		[Test]
		public function shouldSetRestrictedExtent():void
		{
			// Given a Map and a bounds at the map projection
			this._map = new Map();
			this._map.center = CENTER;
			this._map.resolution = RESOLUTION;
			this._bounds = new Bounds(2,45,3,48,"EPSG:4326");
			
			// When the restrictedExtent is set
			this._map.restrictedExtent = this._bounds;
			
			// Then the map restrictedExtent value
			Assert.assertTrue("Incorrect left value", Math.abs(this._bounds.left-this._map.restrictedExtent.left)<EPSILON);
			Assert.assertTrue("Incorrect right value",Math.abs(this._bounds.right-this._map.restrictedExtent.right)<EPSILON);
			Assert.assertTrue("Incorrect top value", Math.abs(this._bounds.top-this._map.restrictedExtent.top)<EPSILON);
			Assert.assertTrue("Incorrect bottom value", Math.abs(this._bounds.bottom-this._map.restrictedExtent.bottom)<EPSILON);
			Assert.assertEquals("Incorrect projection value", this._bounds.projection, this._map.restrictedExtent.projection);
		}
		
		/**
		 * Validates that the pan can't move the current Map out of the restrictedExtent
		 */
		[Test(async)]
		public function shouldNotMoveMapOutOfrestrictedExtentOnPan():void
		{
			// Given a Map with the restrictedExtent set to the current map extent
			this._map = new Map();
			this._map.center = CENTER;
			this._map.resolution = RESOLUTION;
			this._bounds = this._map.extent.clone();
			
			this._map.restrictedExtent = this._bounds;
			
			this._handler = Async.asyncHandler(this,this.onTimer,2000,[
				// When the map is pan
				[this.pan],
				
				// Then the map didn't move
				this.assertNotMoveMapOutOfrestrictedExtentOnPan]);
			
			this._timer.addEventListener(TimerEvent.TIMER,this._handler);
			this._timer.start();
		}
		
		private function assertNotMoveMapOutOfrestrictedExtentOnPan():void
		{
			// Then the map extent is set to the restricted extent 
			Assert.assertTrue("Incorrect left value", Math.abs(this._bounds.left-this._map.extent.left)<EPSILON);
			Assert.assertTrue("Incorrect right value",Math.abs(this._bounds.right-this._map.extent.right)<EPSILON);
			Assert.assertTrue("Incorrect top value", Math.abs(this._bounds.top-this._map.extent.top)<EPSILON);
			Assert.assertTrue("Incorrect bottom value", Math.abs(this._bounds.bottom-this._map.extent.bottom)<EPSILON);
			Assert.assertEquals("Incorrect projection value",this._bounds.projection, this._map.extent.projection);
			
		}
		
		/**
		 * Validates that the pan can move the map on the restrictedExtent
		 */
		[Test(async)]
		public function shouldMoveMapOnRestrictedExtentOnPan():void
		{
			// Given a Map with the restrictedExtent set to the current map extent
			this._map = new Map();
			this._map.center = CENTER;
			this._map.resolution = RESOLUTION;
			var current:Bounds = this._map.extent.clone();
			
			this._bounds = new Bounds(	current.left-2*DX*this._map.resolution.value,
				current.bottom-2*DY*this._map.resolution.value,	
				current.right+2*DX*this._map.resolution.value,
				current.top+2*DY*this._map.resolution.value,
				this._map.projection	);
			
			this._map.restrictedExtent = this._bounds.clone();
			
			
			// keep information of the extent before pan			
			this._bounds = this._map.extent.clone();
			
			this._handler = Async.asyncHandler(this,this.onTimer,2000,[
				// When the map is pan
				[this.pan],
				
				// Then the map didn't move
				this.assertMoveMapOnRestrictedExtentOnPan]);
			
			this._timer.addEventListener(TimerEvent.TIMER,this._handler);
			this._timer.start();
		}
		
		private function assertMoveMapOnRestrictedExtentOnPan():void
		{
			// Then the map extent is set to the restricted extent 
			Assert.assertTrue("Incorrect, different left expected", this._map.extent.left!=this._bounds.left);
			Assert.assertTrue("Incorrect, different right expected", this._map.extent.right!=this._bounds.right);
			Assert.assertTrue("Incorrect, different top expected", this._map.extent.top!=this._bounds.top);
			Assert.assertTrue("Incorrect, different bottom expected", this._map.extent.bottom!=this._bounds.bottom);
			
		}
		
		/**
		 * Validates that the map can't have a resolution that display more datas than  the restricted extent
		 */
		[Test]
		public function shouldNotMoveMapOutOfRestrictedExtentOnZoomOut():void
		{
			// Given a Map with the restrictedExtent set to the current map extent
			this._map = new Map();
			this._map.center = CENTER;
			this._map.resolution = RESOLUTION;
			this._bounds = this._map.extent.clone();
			
			this._map.restrictedExtent = this._bounds;
			
			// When the map is set to a bigger resolution
			var res:Resolution = this._map.resolution;
			this._map.resolution = new Resolution(res.value*2, res.projection);
			
			// Then the map extent is set to the restricted extent 
			Assert.assertTrue("Incorrect left value", Math.abs(this._bounds.left-this._map.extent.left)<EPSILON);
			Assert.assertTrue("Incorrect right value",Math.abs(this._bounds.right-this._map.extent.right)<EPSILON);
			Assert.assertTrue("Incorrect top value", Math.abs(this._bounds.top-this._map.extent.top)<EPSILON);
			Assert.assertTrue("Incorrect bottom value", Math.abs(this._bounds.bottom-this._map.extent.bottom)<EPSILON);
			Assert.assertEquals("Incorrect projection value",this._bounds.projection, this._map.extent.projection);
		}
		
		/**
		 * Validates that the map can be zoom when the new zoomExtent is on the restricted Extent
		 */
		[Test(async)]
		public function shouldZoomMapOnRestrictedExtentOnZoomOut():void
		{
			// Given a Map with the restrictedExtent set to a higher extent than the current
			this._map = new Map();
			this._map.center = CENTER;
			this._map.resolution = RESOLUTION;
			var current:Bounds = this._map.extent.clone();
			
			this._bounds = new Bounds(	current.left-2*DX*this._map.resolution.value,
				current.bottom-2*DY*this._map.resolution.value,	
				current.right+2*DX*this._map.resolution.value,
				current.top+2*DY*this._map.resolution.value,
				this._map.projection	);
			
			this._map.restrictedExtent = this._bounds.clone();
			
			
			// keep information of the extent before zoom			
			this._bounds = this._map.extent.clone();
			
			this._handler = Async.asyncHandler(this,this.onTimer,2000,[
				// When the map is zoom
				[this._map.zoomOut],
				
				// Then the map is zoomed out (the new extent is bigger than the previous one)
				this.assertZoomMapOnRestrictedExtentOnZoomOut]);
			
			this._timer.addEventListener(TimerEvent.TIMER,this._handler);
			this._timer.start();
		}
		
		
		private function assertZoomMapOnRestrictedExtentOnZoomOut():void
		{
			// Then the map extent is bigger than the previous one (zoom)
			Assert.assertTrue("Incorrect, different left expected", this._map.extent.left<this._bounds.left);
			Assert.assertTrue("Incorrect, different right expected", this._map.extent.right>this._bounds.right);
			Assert.assertTrue("Incorrect, different top expected", this._map.extent.top>this._bounds.top);
			Assert.assertTrue("Incorrect, different bottom expected", this._map.extent.bottom<this._bounds.bottom);
		}
		
		
		// Pan the map to the given direction
		private function pan():void
		{
			// pan on two direction
			this._map.pan(-DX, DY);
		}
		
		// Utility function
		private function onTimer(event:TimerEvent,passThroughData:Object):void
		{
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