package org.openscales.core.tile
{
	import com.gskinner.motion.GTweeny;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import org.openscales.core.Layer;
	import org.openscales.core.Tile;
	import org.openscales.core.basetypes.Bounds;
	import org.openscales.core.basetypes.Pixel;
	import org.openscales.core.basetypes.Size;
	import org.openscales.core.event.OpenScalesEvent;
	
	public class Image extends Tile
	{
		public var queued:Boolean = false;
		
		private var _tileLoader:Loader = null;
		
		public function Image(layer:Layer, position:Pixel, bounds:Bounds, url:String, size:Size):void {
			super(layer, position, bounds, url, size);
			
			// otherwise you'll get seams between tiles :(
			this.cacheAsBitmap = true;
			
			_tileLoader = new Loader();
		}
		
		override public function destroy():void {
			this.clear();
			
			while (numChildren > 0) {
	    		var child:DisplayObject = removeChildAt(0);
	    		if (child is Loader) {
	    			try {
	    				Loader(child).unload();
	    			}
	    			catch (error:Error) {
	    				trace("Error when unloading tile " + this.url);
	    			}
	    		}
	    	}

	        super.destroy();
		}
		
		override public function draw():Boolean {
			
			this.clear();
			
		    if (this.layer != this.layer.map.baseLayer) {
	            this.bounds = this.getBoundsFromBaseLayer(this.position);
	        }
	        if (!super.draw()) {
	            return false;    
	        }
	        if(this.url == null)
	        	this.url = this.layer.getURL(this.bounds);
	        	
	        _tileLoader.load(new URLRequest(this.url));
	        _tileLoader.name=this.url;
	        _tileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onTileLoadEnd, false, 0, true);
			_tileLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onTileLoadError, false, 0, true);
			
	        return true;
		}
		
		public function onTileLoadEnd(event:Event):void
		{
			if(this.layer) {
				var loaderInfo:LoaderInfo = event.target as LoaderInfo;
				var loader:Loader = loaderInfo.loader as Loader;
				this.addChild(loader);
				// Tween tile effect 
				new GTweeny(this, 0.3, {alpha:1}); 
	
				this.layer.addChild(this);
				this.drawn = true;
			}
		}
		
		private function onTileLoadError(event:IOErrorEvent):void
		{
			trace("Error when loading tile " + this.url);

		}
		
		override public function clear():void {
			super.clear();
	        this.alpha = 0;
	        OpenScalesEvent.stopObservingElement(Event.COMPLETE, this);
	        OpenScalesEvent.stopObservingElement(IOErrorEvent.IO_ERROR, this);
	        graphics.clear();
        }
		
		
	}
}