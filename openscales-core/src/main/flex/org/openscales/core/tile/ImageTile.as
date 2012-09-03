package org.openscales.core.tile
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.display.ShaderPrecision;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ShaderEvent;
	import flash.filters.ShaderFilter;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import org.openscales.core.layer.Grid;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.request.DataRequest;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;

	/**
	 * Image tile are used for example in WMS-C layers to display an image
	 * part of the Grid layer.
	 */
	public class ImageTile extends Tile
	{
		private var _attempt:Number = 0;

		private var _queued:Boolean = false;

		private var _request:DataRequest = null;
		
		private var _method:String = null;
		
		private var _toneMappingFilter:Shader;
		private var _toneMappingActive:Boolean;
		
		private var _toneMappingBuffer:Array;
		private var _shaderJob:ShaderJob;
		private var _backBuffer:BitmapData;
		
		/**
		 * No Data tile
		 */
		[Embed(source="/assets/images/noData.png")]
		private var _noData:Class;
		
		/**
		 * No Data transparent tile
		 */
		[Embed(source="/assets/images/noDataTransp.png")]
		private var _noDataTransp:Class;

		public function ImageTile(layer:Layer, position:Pixel, bounds:Bounds, url:String, size:Size) {
			super(layer, position, bounds, url, size);
			if (size)
				this._backBuffer = new BitmapData(size.w, size.h);
			if (this.layer && this.layer is Grid && (this.layer as Grid).shaderFilter)
				this._toneMappingFilter = (this.layer as Grid).shaderFilter;
			// otherwise you'll get seams between tiles :(
			//this.cacheAsBitmap = true;

		}

		override public function destroy():void {
			this.clear();
			
			if(this.layer)
				if(this.layer.contains(this))
					this.layer.removeChild(this);
			if(_request)
				_request.destroy();	

			super.destroy();
		}

		/**
		 * Check that a tile should be drawn, and draw it.
		 *
		 * @return Always returns true.
		 */
		override public function draw():Boolean {
			if(!super.draw()) {
				return false;    
			}
			if (this.url == null) {
				this.url = this.layer.getURL(this.bounds);
				if(this.layer.security)
					this.url = this.layer.security.getFinalUrl(this.url);
			}
			if(this.url==null) {
				if (_request) {
					_request.destroy();
					_request = null;
				}
				return false;
			}
			if (_request) {
				_request.destroy();
			}
			this.loading = true;		     
			_request = new DataRequest(this.url, onTileLoadEnd, onTileLoadError,method);
			if(_request.method == URLRequestMethod.POST){
				_request.postContent = new URLVariables(this.url);
			}
			
			_request.security = this.layer.security;
			_request.proxy = this.layer.proxy;
			if(this.layer.security==null) {
				_request.send();
			} else {
				this.layer.security.addWaitingRequest(_request);
			}
			return true;
		}

		public function onTileLoadEnd(event:Event):void {
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			var loader:Loader = loaderInfo.loader as Loader;
			var bitmap:Bitmap = new Bitmap(Bitmap(loader.content).bitmapData,PixelSnapping.NEVER,true);
			
			// Filter the tile if the shaderActivated switch is on
			if (this.layer is Grid && (this.layer as Grid).shaderActivated && (this.layer as Grid).shaderFilter)
				this.filterTile(Bitmap(loader.content).bitmapData);
			else
				drawLoader(loader.name, bitmap);
		}
		
		
		/**
		 * Filter the given bitmapData with the <b>shaderFilter</b> of the <b>Grid</b> with will display the 
		 * tile and replace the BitmapData of the tile by the filtered version of the given BitmapData
		 */
		public function filterTile(bmpData:BitmapData):void{
			if (bmpData && this._backBuffer)
			{
				this._toneMappingFilter.data.src.input = bmpData;
				this._toneMappingFilter.precisionHint = ShaderPrecision.FAST;
				_shaderJob = new ShaderJob(this._toneMappingFilter, this._backBuffer, this.width, this.height);
				_shaderJob.start(true);
				var bitmap:Bitmap = new Bitmap(this._backBuffer,PixelSnapping.NEVER,true);
				drawLoader("null", bitmap);
			}
		}

		/**
		 * Method to draw the loader (recently loaded or cached)
		 *
		 * @param url The tile url
		 * @param bitmap The bitmap to draw
		 * @param cached Cached loader or not
		 */
		private function drawLoader(url:String, bitmap:Bitmap):void {
			if (this.layer) {		
				if (_drawPosition != null) {
					this.position = _drawPosition;					
					_drawPosition = null;
				}
				if(this.size==null)
					return;
				bitmap.width = this.size.w;
				bitmap.height = this.size.h;

				this.addChildAt(bitmap,0);
				var i:int = this.numChildren-1;
				for(i;i>0;i--)
					this.removeChildAt(i);
				
				if (! this.layer.contains(this)) {
					this.layer.addChild(this);
				}
				
				this.drawn = true;
				this.loading = false;
			}
		}
		
		public function onTileLoadError(event:IOErrorEvent):void {
			if (this.layer && this.layer.map && ++this._attempt <= this.layer.map.IMAGE_RELOAD_ATTEMPTS) {
				// Retry loading
				//Trace.log("ImageTile - onTileLoadError: Error while loading tile " + this.url+" ; retry #" + this._attempt);
				this.draw();
			} else {
				// Maximum number of tries reached
				//Trace.error("ImageTile - onTileLoadError: Error while loading tile " + this.url);
				this.loading = false;
				
				// Display the no data Tile
				var bmdata:BitmapData = new BitmapData(256,256);
				if (this.url.match("TRANSPARENT=TRUE"))
				{
					this.drawLoader("", new _noDataTransp());
					bmdata.draw(new _noDataTransp());
				}else{
					this.drawLoader("", new _noData());
					bmdata.draw(new _noData());
				}
				
			}
		}

		/**
		 *  Clear the tile of any bounds/position-related data
		 */
		override public function clear():void {
			super.clear();

			if(this._request) {
				_request.destroy();
			}
			
			if (this._shaderJob)
			{
				this._shaderJob.cancel();
			}
			
			var i:int = this.numChildren;
			for(i;i>0;--i) {
				removeChildAt(0);
			}
		}

		//Getters and Setters
		public function get queued():Boolean {
			return this._queued;
		}

		public function set queued(value:Boolean):void {
			this._queued = value;
		}

		
		public function get method():String {
			return this._method;
		}
		
		public function set method(value:String):void {
			this._method = value;
			
		}
		
		override public function set size(value:Size):void
		{
			super.size = value;
			if (value)
				this._backBuffer = new BitmapData(value.w, value.h);
		}
	}
}

