package org.openscales.core.layer
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.request.DataRequest;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	/** 
	 * @eventType org.openscales.core.events.LayerEvent.LOAD_END
	 */ 
	[Event(name="openscales.layerloadend", type="org.openscales.core.events.LayerEvent")]

	public class ImageLayer extends Layer
	{
    
		private var _request:DataRequest = null;
		private var _size:Size = null;
		private var _image:DisplayObject = null;
		
	    public function ImageLayer(name:String,
	    						  url:String,
	    						  bounds:Bounds
								  ) {
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
			if(this._image && this.numChildren>0)
				this.removeChild(this._image);			
		}
		
		override protected function draw():void  {
			if(this._image && this.available) {
				if(this.numChildren==0)
					this.addChild(this._image);
				_image.width = this.maxExtent.reprojectTo(this.map.projection).width/this.map.resolution.value;
				_image.height = this.maxExtent.reprojectTo(this.map.projection).height/this.map.resolution.value;
				var ul:Location = new Location(this.maxExtent.left, this.maxExtent.top);
				var ulPx:Pixel = this.map.getMapPxFromLocation(ul);
				_image.x = ulPx.x;
				_image.y = ulPx.y;
			} else {
				this.clear();
			}
		}
		
		public function onTileLoadEnd(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			var loader:Loader = loaderInfo.loader as Loader;
			// Store image size
			this._size = new Size(loader.width, loader.height);
			this._image = loader;
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