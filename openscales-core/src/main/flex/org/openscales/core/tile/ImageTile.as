package org.openscales.core.tile
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
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
		
		private var _useNoDataTile:Boolean = true;
		
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

		/**
		 * Totally transparent tile
		 */ 
		[Embed(source="/assets/images/fullTransparentImage.png")]
		private var _fullTransparentImage:Class;
		
		public function ImageTile(layer:Layer, position:Pixel, bounds:Bounds, url:String, size:Size) {
			super(layer, position, bounds, url, size);
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
				if(_request)_request.destroy();
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
			drawLoader(loader.name, bitmap);
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
				if(_useNoDataTile){
					if (this.url.match("TRANSPARENT=TRUE")){
						this.drawLoader("", new _noDataTransp());
						bmdata.draw(new _noDataTransp());
					}else{
						this.drawLoader("", new _noData());
						bmdata.draw(new _noData());
					}
				}else{
					this.drawLoader("",new _fullTransparentImage());
					bmdata.draw(new _fullTransparentImage());
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

		/**
		 * If true, when tile loading fails, a pictogram will replace the tile.
		 * 
		 * @default true
		 */
		public function get useNoDataTile():Boolean
		{
			return _useNoDataTile;
		}

		/**
		 * @private
		 */
		public function set useNoDataTile(value:Boolean):void
		{
			_useNoDataTile = value;
		}

	}
}

