package org.openscales.core.feature
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import org.openscales.core.request.DataRequest;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Point;
	
	public class CustomMarker extends PointFeature
	{
		private var _clip:DisplayObject;
		private var _xOffset:Number;
		private var _yOffset:Number;
		private var _req:DataRequest=null;
		
		[Embed(source="/assets/images/marker-blue.png")]
		private var _defaultImage:Class;
		
		public function CustomMarker()
		{
			super(null,null,null);
		}
		
		public static function createDisplayObjectMarker(dispObj:DisplayObject,
														 point:Point,
														 data:Object=null,
														 xOffset:Number=0,
														 yOffset:Number=0):CustomMarker {
			var ret:CustomMarker = new CustomMarker();
			ret.geometry = point;
			ret.data = data;
			ret.xOffset = xOffset;
			ret.yOffset = yOffset;
			ret.loadDisplayObject(dispObj);
			return ret;
		}
		
		public static function createUrlBasedMarker(iconURL:String,
													point:Point,
													data:Object=null,
													xOffset:Number=0,
													yOffset:Number=0):CustomMarker {
			var ret:CustomMarker = new CustomMarker();
			ret.geometry = point;
			ret.data = data;
			ret.xOffset = xOffset;
			ret.yOffset = yOffset;
			ret.loadUrl(iconURL);
			return ret;
		}
		
		public function set xOffset(value:Number):void {
			this._xOffset = value;
			if(this.layer)
				this.draw();
		}
		
		public function get xOffset():Number {
			return this._xOffset;
		}
		
		public function set yOffset(value:Number):void {
			this._yOffset = value;
			if(this.layer)
				this.draw();
		}
		
		public function get yOffset():Number {
			return this._yOffset;
		}
		
		public function loadUrl(url:String):void {
			this._req = new DataRequest(url,onSuccess, onFailure);
			this._req.send();
		}
		
		public function loadDisplayObject(clip:DisplayObject):void {
			if(this._clip)
				this.removeChild(this._clip);
			this._clip = clip;
			this.addChild(this._clip);
			if(this.layer)
				this.draw();
		}
		
		override public function draw():void {
			if(!this._clip)
				return;
			// we compute the location of the marker
			var x:Number;
			var y:Number;
			var resolution:Number = this.layer.map.resolution;
			var dX:int = -int(this.layer.map.layerContainer.x) + this.left;
			var dY:int = -int(this.layer.map.layerContainer.y) + this.top;
			x = dX - (this._clip.width/2) + _xOffset + point.x / resolution;
			y = dY - (this._clip.height/2) + _yOffset - point.y / resolution;
			_clip.x = x;
			_clip.y = y;
		}
		
		private function onSuccess(e:Event):void {
			this.loadDisplayObject(Bitmap(this._req.loader.content));
			this._req.destroy();
			this._req = null;
		}
		
		private function onFailure(e:Event):void {
			this._req.destroy();
			this._req = null;
			this.loadDisplayObject(new _defaultImage());
			this._xOffset = 0;
			this._yOffset = 0;
		}
	}
}