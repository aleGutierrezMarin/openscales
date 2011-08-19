package org.openscales.core.layer.ogc.provider
{
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.grid.provider.HTTPTileProvider;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Pixel;
	
	use namespace os_internal;
	
	/**
	 * Default OGC service tile provider
	 */ 
	public class OGCTileProvider extends HTTPTileProvider
	{
		
		/**
		 * @protected 
		 * Service type
		 */ 
		protected var _service:String;
		
		/**
		 * @protected 
		 * Service version
		 */ 
		protected var _version:String;
		
		/**
		 * @protected 
		 * Request name
		 */ 
		protected var _request:String;
		
		
		/**
		 * 
		 */ 
		public function OGCTileProvider(url:String,service:String,version:String,request:String)
		{
			super(url,null);
			
			this._service = service;
			this._version = version;
			this._request = request;
		}
		
		/**
		 * @inheritDoc
		 */ 
		override public function getTile(bounds:Bounds, center:Pixel, layer:Layer):ImageTile
		{
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		os_internal function buildGETQuery(bounds:Bounds, params:Object):String
		{
			var requestString:String;
			if(!this._url)
				return null;
			if(this._url.indexOf("?")==-1) requestString = this._url+"?"+this.buildGETParams();
			else requestString=this._url+"&"+this.buildGETParams();
			
			return requestString;
		}
		
		protected function buildGETParams():String{
			var str:String = "";
			
			if (this._service != null)
				str += "SERVICE=" + this._service + "&";
			
			if (this._version != null)
				str += "VERSION=" + this._version + "&";
			
			if (this._request != null)
				str += "REQUEST=" + this._request + "&";
			
			return str;
		}
		
		//getters and setters
		public function get service():String
		{
			return this._service;
		}
		
		public function set service(value:String):void
		{
			this._service = value;
		}
		
		public function get version():String
		{
			return this._version;
		}
		
		public function set version(value:String):void
		{
			this._version = value;
		}
		
		public function get request():String
		{
			return this._request;
		}
		
		public function set request(value:String):void
		{
			this._request = value;
		}
	}
}