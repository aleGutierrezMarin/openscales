package org.openscales.core.style.marker
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.request.DataRequest;

	public class CustomMarker extends Marker
	{
		
		/**
		 * The X offset where the point will be positioned in the image in xUnit
		 * @default 0.5 in fraction
		 */
		private var _xOffset:Number = 0.5;
		
		/**
		 * The Y offset where the point will be positioned in the image in yUnit
		 * @default 0.5 in fraction
		 */
		private var _yOffset:Number = 0.5;
		
		/**
		 * Units in which the x value is specified. 
		 * A value of fraction indicates the x value is a fraction of the icon. 
		 * A value of pixels indicates the x value in pixels from the upperLeft corner. 
		 * @default 0.5 in fraction 
		 */
		private var _xUnit:String = "fraction"
		
		/**
		 * Units in which the y value is specified. 
		 * A value of fraction indicates the y value is a fraction of the icon. 
		 * A value of pixels indicates the y value in pixels from the upperLeft corner. 
		 * @default 0.5 in fraction
		 */
		private var _yUnit:String = "fraction"
		
		/**
		 * The data request that will be used to request the image
		 */
		private var _req:DataRequest=null;
		
		/**
		 * The displayObject that will be drawn as a marker
		 */
		private var _clip:Bitmap;
		
		/**
		 * The image URL
		 */
		private var _url:String;
		
		/**
		 * A vector that stores a reference to all the returned temporary display object
		 * to actualize them when the requested marker will be loaded 
		 */
		private var _givenTemporaryMarker:Vector.<DisplayObject>;
		
		/**
		 * Default image applied when waiting for the request response
		 */
		[Embed(source="/assets/images/marker-blue.png")]
		private var _defaultImage:Class;
		
		public function CustomMarker(url:String = null, opacity:Number=1, xOffset:Number=0.5, xUnit:String="fraction", yOffset:Number=0.5, yUnit:String="fraction")
		{
			super(6, opacity, 0);
			this._xOffset = xOffset;
			this._yOffset = yOffset;
			this._givenTemporaryMarker = new Vector.<DisplayObject>();
			this._url = url;
			if (url)
			{
				this.loadUrl(url);
			}
		}
		
		/**
		 * Load the image at the given URL
		 */
		public function loadUrl(url:String):void {
			this._req = new DataRequest(url,onSuccess, onFailure);
			this._req.send();
		}
		
		/**
		 * Returns an instance of the DisplayObject that contains the graphic.
		 */
		override public function getDisplayObject(feature:Feature):DisplayObject {
			var resultContainer:Sprite = new Sprite();
			var result:DisplayObject;
			if (this._clip)
			{
				result = new Bitmap(_clip.bitmapData);
				if (_xUnit == "fraction")
				{
					result.x += -result.width*_xOffset;
				}else if (_xUnit == "pixels")
				{
					result.x += -_xOffset
				}
				
				if (_yUnit == "fraction")
				{
					result.y += -result.height*_yOffset;
				}else if (_yUnit == "pixels")
				{
					result.y += -_yOffset
				}
				
			}else
			{
				this._givenTemporaryMarker.push(resultContainer);
				result = new _defaultImage();
				result.x += - result.width/2;
				result.y += - result.height;
			}
			result.alpha = this.opacity;
			result.rotation = this.rotation;	
			resultContainer.addChild(result);
			return resultContainer;
		}
		
		override public function clone():Marker
		{
			var cm:CustomMarker = new CustomMarker(this._url, this.opacity, this.xOffset, this.xUnit, this.yOffset, this.yUnit);
			return cm;
		}
		
		//Callback
		/**
		 * Callback on image request sucess
		 */
		private function onSuccess(e:Event):void {
			if (this._clip)
			{
				this._clip.removeEventListener(MouseEvent.CLICK, onMarkerClick);
			}
			this._clip = Bitmap(this._req.loader.content);
			this._clip.addEventListener(MouseEvent.CLICK, onMarkerClick);
			this._req.destroy();
			this._req = null;
			var markerLength:Number = this._givenTemporaryMarker.length;
			for (var i:int = 0; i < markerLength; ++i)
			{
				var sprite:Sprite = this._givenTemporaryMarker[i] as Sprite;
				sprite.removeChildAt(0);
				var result:DisplayObject;
				result = new Bitmap(_clip.bitmapData);
				result = new Bitmap(_clip.bitmapData);
				if (_xUnit == "fraction")
				{
					result.x += -result.width*_xOffset;
				}else if (_xUnit == "pixels")
				{
					result.x += -_xOffset
				}
				
				if (_yUnit == "fraction")
				{
					result.y += -result.height*_yOffset;
				}else if (_yUnit == "pixels")
				{
					result.y += -_yOffset
				}
				sprite.addChild(result);
			}
			this._givenTemporaryMarker = new Vector.<DisplayObject>();
		}
		
		/**
		 * Callback on image request failure
		 */
		private function onFailure(e:Event):void 
		{
			this._req.destroy();
			this._req = null;
		}
		
		/**
		 * Callback to transfere the click event from the sprite to the feature
		 */
		private function onMarkerClick(event:MouseEvent):void
		{
			if (this.clip.parent && this.clip.parent is Feature)
			{
				(this.clip.parent as Feature).onMouseClick(event);
			}
		}
		
		//Getter Setter
		
		/**
		 * The url of the requested image
		 */
		public function get url():String
		{
			return this._url;
		}
		
		/**
		 * @private
		 */
		public function set url(value:String):void
		{
			this._url = value;
		}
		
		/**
		 * The displayObject that will be drawn as a marker
		 */
		public function get clip():Bitmap
		{
			return this._clip;
		}
		
		/**
		 * @private
		 */
		public function set clip(value:Bitmap):void
		{
			this._clip = value;
		}
		
		/**
		 * The X offset that will be applied to the image
		 */
		public function get xOffset():Number 
		{
			return this._xOffset;
		}
		
		/**
		 * @private
		 */
		public function set xOffset(value:Number):void 
		{
			this._xOffset = value;
		}
		
		/**
		 * The Y offset that will be applied to the image
		 */
		public function get yOffset():Number 
		{
			return this._yOffset;
		}
		
		/**
		 * @private
		 */
		public function set yOffset(value:Number):void 
		{
			this._yOffset = value;
		}
		
		/**
		 * Units in which the x value is specified. 
		 * A value of fraction indicates the x value is a fraction of the icon. 
		 * A value of pixels indicates the x value in pixels from the upperLeft corner. 
		 * @default 0.5 in fraction 
		 */
		public function get xUnit():String
		{
			return this._xUnit;
		}
		
		/**
		 * @private
		 */
		public function set xUnit(value:String):void
		{
			this._xUnit = value;
		}
		
		/**
		 * Units in which the y value is specified. 
		 * A value of fraction indicates the y value is a fraction of the icon. 
		 * A value of pixels indicates the y value in pixels from the upperLeft corner. 
		 * @default 0.5 in fraction 
		 */
		public function get yUnit():String
		{
			return this._yUnit;
		}
		
		/**
		 * @private
		 */
		public function set yUnit(value:String):void
		{
			this._yUnit = value;
		}
	}
}