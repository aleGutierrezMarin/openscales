package org.openscales.core.layer.grid.provider
{
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	
	public class HTTPTileProvider implements ITileProvider
	{
		/**
		 * @protected 
		 * Service url
		 */ 
		protected var _url:String;
		
		/**
		 * @protected 
		 * Additional params
		 */ 
		protected var _params:HashMap;
		
		public function HTTPTileProvider(url:String,params:HashMap)
		{
			this._url=url;
			this._params=params;			
		}
		
		public function getTile(bounds:Bounds):ImageTile
		{
			return null;
		}
		
		/** 
		 * Service url
		 */ 
		public function get url():String
		{
			return _url;
		}
		/**
		 * @private
		 */
		public function set url(value:String):void
		{
			_url = value;
		}
	}
}