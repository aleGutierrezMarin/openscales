package org.openscales.core.layer
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;

	public class Bing extends TMS
	{
		public static const resolutions:Array = new Array(156543.03390625,
			78271.516953125,
			39135.7584765625,
			19567.87923828125,
			9783.939619140625,
			4891.9698095703125,
			2445.9849047851562,
			1222.9924523925781,
			611.4962261962891,
			305.74811309814453,
			152.87405654907226,
			76.43702827453613,
			38.218514137268066,
			19.109257068634033,
			9.554628534317017,
			4.777314267158508,
			2.388657133579254,
			1.194328566789627,
			0.5971642833948135,
			0.29858214169740677,
			0.14929107084870338,
			0.07464553542435169);
		
		/**
		 * @private
		 * The layer identifier.  Any non-birdseye imageryType
		 * from http://msdn.microsoft.com/en-us/library/ff701716.aspx can be
		 * used.
		 * Default is "Road".
		 */
		private var _imagerySet:String = "Road";
		
		/**
		 * @private
		 * Metadata for this layer, as returned by the callback script
		 */
		private var _metadata:Object = null;
		
		/**
		 * @private
		 * bing api key
		 */
		private var _key:String = null;
		
		/**
		 * @private
		 * the xmlrequest used in the layer. It prevents simultaneous requests.
		 */ 
		protected var _request:XMLRequest = null;
		
		/**
		 * @private
		 * Optional url parameters for the Get Imagery Metadata request
		 * as described here: http://msdn.microsoft.com/en-us/library/ff701716.aspx
		 */
		private var _metadataParams:String = null
		
		public function Bing(key:String, imagerySet:String=null)
		{
			this.altUrls = [];
			
			super("", null, "");
			
			this._key = key;
			
			if(imagerySet)
				this._imagerySet = imagerySet;
			
			this.projection = "EPSG:900913";
			this.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,this.projection);
			
		}
		
		override public function redraw(fullRedraw:Boolean = false):void {
			if(!_metadata) {
				if(this._request)
					return;
				this.loadMetadata();
			}
			else
				super.redraw(fullRedraw);
		}
		
		override public function getURL(bounds:Bounds):String {
			var res:Resolution = this.getSupportedResolution(this.map.resolution.reprojectTo(this.projection));
			var x:Number = Math.round((bounds.left - this.maxExtent.left) / (res.value * this.tileWidth));
			var y:Number = Math.round((this.maxExtent.top - bounds.top) / (res.value * this.tileHeight));
			
			var z:Number = this.getZoomForResolution(res.reprojectTo(this.projection).value);
			
			var limit:Number = Math.pow(2, z);
			if (y < 0 || y >= limit ||x < 0 || x >= limit) {
				return null;
			}
			
			var quadDigits:Array = [];
			for (var i:Number = z; i > 0; --i) {
				var digit:Number = 0;
				var mask:Number = 1 << (i - 1);
				if ((x & mask) != 0) {
					digit++;
				}
				if ((y & mask) != 0) {
					digit++;
					digit++;
				}
				quadDigits.push(digit);
			}
			var quadKey:String = quadDigits.join("");
			if(quadKey=="")
				return null;
			var path:String = ""+ x + y + z;
			var url:String = this.selectUrl(path, this.getUrls());

			return url.replace("\{quadkey\}",quadKey);
		}
		
		private function loadMetadata():void {
			
			var url:String = "http://dev.virtualearth.net/REST/v1/Imagery/Metadata/"
							+this._imagerySet
							+"?key="+this._key;
			if(_metadataParams)
				url+="?"+_metadataParams;
			//request metadata
			_request = new XMLRequest(url, onSuccess, onFailure);
			_request.proxy = this.proxy;
			_request.security = this.security;
			_request.send();
		}
		
		private function onSuccess(event:Event):void {
			var loader:URLLoader = event.target as URLLoader;
			try {
				_metadata = JSON.decode(loader.data as String) as Object;
				this._request.destroy();
				this._request = null;
				var res:Object = _metadata["resourceSets"][0]["resources"][0];
				var url:String = res["imageUrl"] as String;
				var subDomains:Array = res["imageUrlSubdomains"] as Array;
				var first:Boolean = true;
				this.altUrls = new Array();
				var i:int;
				for (i=subDomains.length-1; i>=0; --i) {
					if(first)
						this.url = url.replace("{subdomain}", subDomains[i]);
					this.altUrls.push(url.replace("{subdomain}", subDomains[i]));
				}
				
				var zoomMin:Number = res["zoomMin"] as Number;
				var zoomMax:Number = res["zoomMax"] as Number;
				var minRes:Number = Bing.resolutions[zoomMin-1];
				
				this.generateResolutions((zoomMax+1-zoomMin),minRes);

				this.originators.push(new DataOriginator("Bing",
					"http://www.bing.com/maps/",
					_metadata["brandLogoUri"] as String));
				
				this.redraw();
			} catch (e:Error) {
				Trace.debug("invalid json");
			}
		}
		
		private function onFailure(event:Event):void {
			this._request.destroy();
			this._request = null;
			Trace.error("Error when loading bing metadata");			
		}
		
		/**
		 * The layer Name (appears in LayerManager for example)
		 */
		override public function get displayedName():String {
			return "Bing "+this._imagerySet;
		}

		/**
		 * Bing api key
		 */
		public function get key():String
		{
			return _key;
		}
		
		/**
		 * The layer identifier.  Any non-birdseye imageryType
		 * from http://msdn.microsoft.com/en-us/library/ff701716.aspx can be
		 * used.
		 * @default Road.
		 */
		public function get imagerySet():String
		{
			return _imagerySet;
		}

		/**
		 * Optional url parameters for the Get Imagery Metadata request
		 * as described here: http://msdn.microsoft.com/en-us/library/ff701716.aspx
		 */
		public function get metadataParams():String
		{
			return _metadataParams;
		}
		/**
		 * @private
		 */
		public function set metadataParams(value:String):void
		{
			_metadataParams = value;
		}
		
		/**
		 * Metadata for this layer, as returned by the callback script
		 */
		public function get metadata():Object
		{
			return _metadata;
		}
		
	}
}