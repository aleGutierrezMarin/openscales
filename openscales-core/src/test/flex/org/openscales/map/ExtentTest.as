package org.openscales.map
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.ns.os_internal;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	
	use namespace os_internal;
	
	public class ExtentTest
	{	
		private var _map:Map = null;
		private var _bounds:Bounds = null;
		private var _timer:Timer;
		private const THINK_TIME:uint = 500;
		private var _handler:Function = null;
		
		
		private static const EPSILON:Number = 0.0000001;
		
		private static const DX:Number = 200;
		private static const DY:Number = 200;
		
		private static const CENTER:Location = new Location(2.81,45.52,"EPSG:4326");
		private static const RESOLUTION:Resolution = new Resolution(0.01,"EPSG:4326");
		
		public function ExtentTest(){}
		
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
		 * Validates that the maxExtent is set to the restrictedExtent if the restrictedExtent is smaller than the given maxExtent
		 */
		[Test]
		public function shouldReturnRestrictedExtentWithSmallerRestrictedExtent():void
		{
			// Given a Map
			this._map = new Map();
			var max:Bounds = this._map.maxExtent.clone();
			
			var restricted:Bounds = new Bounds(
				max.left +1,
				max.bottom +1,
				max.right -1,
				max.top -1,
				this._map.projection
			);
			
			// When the restricted extent is set
			this._map.restrictedExtent = restricted;
			
			// Then the maxExtent return the restrictedExtent
			Assert.assertTrue("Incorrect left value", Math.abs(restricted.left-this._map.maxExtent.left)<EPSILON);
			Assert.assertTrue("Incorrect right value",Math.abs(restricted.right-this._map.maxExtent.right)<EPSILON);
			Assert.assertTrue("Incorrect top value", Math.abs(restricted.top-this._map.maxExtent.top)<EPSILON);
			Assert.assertTrue("Incorrect bottom value", Math.abs(restricted.bottom-this._map.maxExtent.bottom)<EPSILON);
			Assert.assertEquals("Incorrect projection value", restricted.projection, this._map.maxExtent.projection);
		}
		
		/**
		 * Validates that define a restricted extent bigger than the maxExtent don't change the maxExtent value
		 */
		[Test]
		public function shouldReturnMaxExtentWithBiggerRestrictedExtent():void
		{
			// Given a Map 
			this._map = new Map();
			var max:Bounds = this._map.maxExtent.clone();
			
			var restricted:Bounds = new Bounds(
					max.left - 10,
					max.bottom -10,
					max.right +10,
					max.top + 10,
					this._map.projection
			);
			
			// When the restricted extent is set
			this._map.restrictedExtent = restricted;
			
			// Then the maxExtent return the maxExtent value
			Assert.assertTrue("Incorrect left value", Math.abs(max.left-this._map.maxExtent.left)<EPSILON);
			Assert.assertTrue("Incorrect right value",Math.abs(max.right-this._map.maxExtent.right)<EPSILON);
			Assert.assertTrue("Incorrect top value", Math.abs(max.top-this._map.maxExtent.top)<EPSILON);
			Assert.assertTrue("Incorrect bottom value", Math.abs(max.bottom-this._map.maxExtent.bottom)<EPSILON);
			Assert.assertEquals("Incorrect projection value", max.projection, this._map.maxExtent.projection);
			
		}
		
		
		/**
		 * Validates that the function zoomToRestrictedExtent set the current map extent to the maximum extent available
		 */
		[Test]
		public function shouldChangeExtentToMaximumAvailableDataOnZoomToRestrictedExtent():void
		{
			// Given a Map with the restrictedExtent set to the current map extent
			this._map = new Map();
			this._map.center = CENTER;
			this._map.resolution = RESOLUTION;
			
			var bounds:Bounds = this._map.extent.clone();
			this._map.restrictedExtent = this._map.extent.clone();
			
			// When the map is zoomIn several times and then the zoomToRestrictedExtent is called
			for(var i:int=0; i<10; ++i)
			{
				this._map.zoomIn();
			}
			
			this._map.zoomToRestrictedExtent();
			
			// Then the extent is at the limited extent (based on lat or lon)
			Assert.assertTrue("Incorrect left value", Math.abs(bounds.left-this._map.restrictedExtent.left)<EPSILON);
			Assert.assertTrue("Incorrect right value",Math.abs(bounds.right-this._map.restrictedExtent.right)<EPSILON);
			Assert.assertTrue("Incorrect top value", Math.abs(bounds.top-this._map.restrictedExtent.top)<EPSILON);
			Assert.assertTrue("Incorrect bottom value", Math.abs(bounds.bottom-this._map.restrictedExtent.bottom)<EPSILON);
			Assert.assertEquals("Incorrect projection value", bounds.projection, this._map.restrictedExtent.projection);
			
		}
		
		/**
		 * Validates that the function isValidExtentWithRestrictedExtent return true when no restrictedExtent is defined
		 */
		[Test]
		public function shouldIsValidExtentWithRestrictedExtentReturnTrueWithUndefinedRestrictedExtent():void
		{
			// Given a Map
			this._map = new Map();
			this._map.center = CENTER;
			this._map.resolution = RESOLUTION;
			
			// When the isValidExtentWithRestrictedExtent function is called with a center and a resolution
			var result:Boolean = this._map.isValidExtentWithRestrictedExtent(new Location(15,35,this._map.projection), new Resolution(0.025, this._map.projection));
			
			// Then the function return true
			Assert.assertTrue("Incorrect shloud be true", result);
		}
		
		/**
		 * Validates that the function isValidExtentWithRestrictedExtent return true when a center and resolution are contained by the given restrictedExtent
		 */
		[Test]
		public function shouldIsValidExtentWithRestrictedExtentReturnTrueWithParamIn():void
		{
			// Given a Map and a restrictedExtent
			this._map = new Map();
			this._map.center = CENTER;
			this._map.resolution = RESOLUTION;
			
			this._map.restrictedExtent = this._map.extent.clone();
			var bounds:Bounds = new Bounds(this._map.restrictedExtent.left + 1,
				this._map.restrictedExtent.bottom + 1,
				this._map.restrictedExtent.right - 1,
				this._map.restrictedExtent.top - 1,
				this._map.restrictedExtent.projection);
			
			var center:Location = new Location(bounds.left+((bounds.right-bounds.left)/2), bounds.bottom+((bounds.top-bounds.bottom)/2), this._map.projection);
			var value:Number = (bounds.right-bounds.left) / this._map.width;
			var resolution:Resolution = new Resolution(value, this._map.projection);
			
			// When the isValidExtentWithRestrictedExtent function is called with a the center and resolution contained by the restrictedExtent
			var result:Boolean = this._map.isValidExtentWithRestrictedExtent(center,resolution);
			
			// Then the function return true
			Assert.assertTrue("Incorrect shloud be true", result);
		}
		
		/**
		 * Validates that the function isValidExtentWithRestrictedExtent return false when a center and resolution are NOT contained by the given restrictedExtent
		 */
		[Test]
		public function shouldIsValidExtentWithRestrictedExtentReturnFalseWithParamOut():void
		{
			// Given a Map and a restrictedExtent
			this._map = new Map();
			this._map.center = CENTER;
			this._map.resolution = RESOLUTION;
			
			this._map.restrictedExtent = this._map.extent.clone();
			var bounds:Bounds = new Bounds(this._map.restrictedExtent.left - 10,
				this._map.restrictedExtent.bottom - 10,
				this._map.restrictedExtent.right + 10,
				this._map.restrictedExtent.top + 10,
				this._map.restrictedExtent.projection);
			
			var center:Location = new Location((bounds.right-bounds.left)/2, (bounds.top-bounds.bottom)/2, this._map.restrictedExtent.projection);
			var resolution:Resolution = new Resolution((bounds.right-bounds.left) / this._map.width, this._map.projection);
			
			// When the isValidExtentWithRestrictedExtent function is called with a the center and resolution NOT contained by the restrictedExtent
			var result:Boolean = this._map.isValidExtentWithRestrictedExtent(center,resolution);
			
			// Then the function return false
			Assert.assertFalse("Incorrect shloud be false", result);
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