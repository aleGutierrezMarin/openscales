package org.openscales.core.tile
{
	import com.gskinner.motion.GTween;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.linkedlist.LinkedListBitmapNode;
	import org.openscales.core.layer.Grid;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.request.DataRequest;
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

		public function ImageTile(layer:Layer, position:Pixel, bounds:Bounds, url:String, size:Size) {
			super(layer, position, bounds, url, size);
			// otherwise you'll get seams between tiles :(
			this.cacheAsBitmap = false;

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
			Trace.debug("map resolution: "+this.layer.map.resolution.value);
			Trace.debug("tile resolution before: "+(bounds.right-bounds.left)/256);
			//TODO check if still OK
			//if (this.layer != this.layer.map.baseLayer) {
				if(_drawPosition != null) {
					this.bounds = this.getBoundsFromMap(_drawPosition);
				} else {
					//var px:Pixel = new Pixel(this.x/this.layer.transform.matrix.a,
					//						this.y/this.layer.transform.matrix.d);
					this.bounds = this.getBoundsFromMap(position);
				}
			//}
				Trace.debug("tile resolution after: "+(bounds.right-bounds.left)/256);
			if(! withinMapBounds()) {
				return false;    
			}
			if (this.url == null) {
				this.url = this.layer.getURL(this.bounds);
			}
			if(this.url==null) {
				if (_request) {
					_request.destroy();
					_request = null;
				}
				return false;
			}

			var cachedBitmap:Bitmap;
			if ((this.layer is Grid) && ((cachedBitmap=(this.layer as Grid).getTileCache(this.url)) != null)) {
				this.loading = true;
				drawLoader(this.url,cachedBitmap,true);
			}else {
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
			}
			return true;
		}

		public function onTileLoadEnd(event:Event):void {
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			var loader:Loader = loaderInfo.loader as Loader;
			var bitmap:Bitmap = Bitmap(loader.content);
			drawLoader(loader.name, bitmap, false);
		}

		/**
		 * Method to draw the loader (recently loaded or cached)
		 *
		 * @param url The tile url
		 * @param bitmap The bitmap to draw
		 * @param cached Cached loader or not
		 */
		private function drawLoader(url:String, bitmap:Bitmap, cached:Boolean):void {
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
				if(this.layer.tweenOnLoad)
					var tw:GTween = new GTween(this, 0.3, {alpha:1});

				this.drawn = true;
				this.loading = false;
				
				// We put the loader into the cache if it's a recently loaded
				if ((this.layer is Grid) && (! cached)) {
					var node:LinkedListBitmapNode = new LinkedListBitmapNode(bitmap,url);
					(this.layer as Grid).addTileCache(node);
				}
			}
		}
		
		public function onTileLoadError(event:IOErrorEvent):void {
			if ((! this.layer) || (! this.layer.map) || (++this._attempt <= this.layer.map.IMAGE_RELOAD_ATTEMPTS)) {
				// Retry loading
				Trace.log("ImageTile - onTileLoadError: Error while loading tile " + this.url+" ; retry #" + this._attempt);
				this.draw();
			} else {
				// Maximum number of tries reached
				Trace.error("ImageTile - onTileLoadError: Error while loading tile " + this.url);
				this.loading = false;
				
			}
		}

		/**
		 *  Clear the tile of any bounds/position-related data
		 */
		override public function clear():void {
			super.clear();
			
			if(this.layer)
				if(this.layer.tweenOnLoad)
					this.alpha = 0;

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

		
	}
}

