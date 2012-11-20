package org.openscales.core.style.graphic
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.request.DataRequest;

	public class ExternalGraphic implements IGraphic
	{
		private namespace sldns="http://www.opengis.net/sld";
		
		private var _format:String;
		private var _onlineResource:String;
		
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
		 * A vector that stores a reference to all the returned temporary display object
		 * to actualize them when the requested marker will be loaded 
		 */
		private var _givenTemporaryMarker:Vector.<WaitingRendering>;
		
		private var _proxy:String = null;
		
		/**
		 * Default image applied when waiting for the request response
		 */
		[Embed(source="/assets/images/marker-blue.png")]
		private var _defaultImage:Class;
		
		public function ExternalGraphic(onlineResource:String=null,format:String="image/png")
		{
			this._onlineResource = onlineResource;
			this._format = format;
			if (this._onlineResource)
			{
				this.load();
			}
		}
		
		public function clone():IGraphic {
			//TODO clone ALL !!!
			return new ExternalGraphic(this._onlineResource,this._format);
		}
		
		public function getDisplayObject(feature:Feature,size:Number):DisplayObject {
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
				try {
					result.width = size;
					result.height = size;
				} catch(e:Error) {
					
				}
				resultContainer.addChild(result);
			}else
			{
				if(!this._givenTemporaryMarker)
					this._givenTemporaryMarker = new Vector.<WaitingRendering>();
				this._givenTemporaryMarker.push(new WaitingRendering(resultContainer,size));
			}
			return resultContainer;
		}
		
		/**
		 * Load the image at the given URL
		 */
		public function load():void {
			if(this._req || !this._onlineResource)
				return;
			this._req = new DataRequest(this._onlineResource,onSuccess, onFailure);
			this._req.proxy = this._proxy;
			this._req.send();
		}
		
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
				var sprite:Sprite = this._givenTemporaryMarker[i].sprite;
				var size:Number = this._givenTemporaryMarker[i].size;

				var result:DisplayObject;
				result = new Bitmap(_clip.bitmapData);
				
				result.width = size;
				result.height = size;
				
				if (_xUnit == "fraction")
				{
					result.x += -size*_xOffset;
				}else if (_xUnit == "pixels")
				{
					result.x += -_xOffset
				}
				
				if (_yUnit == "fraction")
				{
					result.y += -size*_yOffset;
				}else if (_yUnit == "pixels")
				{
					result.y += -_yOffset
				}
				sprite.addChild(result);
				result.addEventListener(MouseEvent.CLICK, onMarkerClick);
			}
			this._givenTemporaryMarker = new Vector.<WaitingRendering>();
		}
		
		/**
		 * Callback on image request failure
		 */
		private function onFailure(e:Event):void 
		{
			this._req.destroy();
			this._req = null;
			var markerLength:Number = this._givenTemporaryMarker.length;
			for (var i:int = 0; i < markerLength; ++i)
			{
				var sprite:Sprite = this._givenTemporaryMarker[i].sprite;
				var size:Number = this._givenTemporaryMarker[i].size;
				var result:DisplayObject = new _defaultImage();
				result.width = size;
				result.height = size;
				result.x += - size/2;
				result.y += - size;
				sprite.addChild(result);
				result.addEventListener(MouseEvent.CLICK, onMarkerClick);
			}
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
		
		public function get sld():String
		{
			if(!this._onlineResource)
				return null;
			var res:String = "<sld:ExternalGraphic>\n";
			res+= "<sld:OnlineResource xlink:type=\"simple\" xlink:href=\""+this._onlineResource+"\"/>";
			res+= "<sld:Format>"+this._format+"</sld:Format>";
			res+= "</sld:ExternalGraphic>\n";
			return res;
		}
		
		public function set sld(value:String):void
		{
			use namespace sldns;
			var dataXML:XML = new XML(value);
			
			if(this._req) {
				this._req.destroy();
				this._req = null;
			}
			if(this._clip)
				this._clip = null;
			this._format = "image/png";
			this._onlineResource = null;
			//TODO finish reset
			
			var childs:XMLList = dataXML.Format;
			if(childs[0]) {
				this.format = childs[0].toString();
			}
			childs = dataXML.OnlineResource;
			if(childs[0]) {
				this.onlineResource = childs[0].toString();
			}
		}

		public function get format():String
		{
			return _format;
		}

		public function set format(value:String):void
		{
			_format = value;
		}

		public function get onlineResource():String
		{
			return _onlineResource;
		}

		public function set onlineResource(value:String):void
		{
			_onlineResource = value;
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
		
		/**
		 * Proxy
		 */
		public function get proxy():String
		{
			return _proxy;
		}
		
		/**
		 * @private
		 */
		public function set proxy(value:String):void
		{
			_proxy = value;
		}
	}
}