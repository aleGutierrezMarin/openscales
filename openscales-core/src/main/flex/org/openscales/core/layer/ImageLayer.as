package org.openscales.core.layer
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.request.DataRequest;
	

	public class ImageLayer extends Layer
	{
    
		private var _request:DataRequest = null;
		private var _size:Size = null;
		
	    public function ImageLayer(name:String,
	    						  url:String,
	    						  bounds:Bounds) {
	        this.url = url;
	        this.maxExtent = bounds;
						
	        super(name);
			
	    }
	
	     override public function destroy():void {
	        if (this._request) {
	            this._request.destroy();
	            this._request = null;
	        }
	        super.destroy();
	    } 
	   
	    override public function set map(value:Map):void {
	         if(value !=null)
	         {
	         	super.map = value;
	         }
	    } 
	
	    override public function redraw(fullRedraw:Boolean = true):void {
			
			if (!displayed) {
				this.clear();
				return;
			}
			
	        if (! this._request) {
				this._request = new DataRequest(this.url, onTileLoadEnd, onTileLoadError);
				this._request.proxy = this.proxy;
				this._request.security = this.security;
				this.loading = true;
				this._request.send();
			} else {
				this.clear();
				this.draw();
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_LOAD_END, this));
			}
			
		}
		
		override public function clear():void  {
			//this.graphics.clear();			
		}
		
		override protected function draw():void  {
			if(numChildren != 0) {
				var image:DisplayObject = this.getChildAt(0);
				image.width = this.maxExtent.width/this.map.resolution;
				image.height = this.maxExtent.height/this.map.resolution;
				var ul:Location = new Location(this.maxExtent.left, this.maxExtent.top);
				var ulPx:Pixel = this.map.getLayerPxFromLocation(ul);
				image.x = ulPx.x;
				image.y = ulPx.y;
			}
		}
		
		public function onTileLoadEnd(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			var loader:Loader = loaderInfo.loader as Loader;
			// Store image size
			this._size = new Size(loader.width, loader.height);
			this.addChild(loader);
			this.draw();
			this.loading = false;
		} 
		
		public function onTileLoadError(event:IOErrorEvent):void
		{
			Trace.error("Error when loading image layer " + this.url);
		}
		
		override public function getURL(bounds:Bounds):String {
			return this.url;
		}
	}
}