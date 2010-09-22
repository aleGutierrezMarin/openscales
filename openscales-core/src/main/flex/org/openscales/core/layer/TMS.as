package org.openscales.core.layer
{
	import org.openscales.basetypes.Bounds;
	import org.openscales.basetypes.Location;
	import org.openscales.basetypes.Pixel;
	import org.openscales.basetypes.Size;
	import org.openscales.core.Map;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.core.tile.Tile;

	/**
	 * The Tiled Web Service provides access to resources, in particular, to rendered
	 * cartographic tiles at fixed scales.
	 *
	 * More informations on http://wiki.osgeo.org/wiki/Tile_Map_Service_Specification
	 *
	 */
	public class TMS extends Grid
	{
		private var _serviceVersion:String = "1.0.0";

		private var _tileOrigin:Location = null;
		
		private var _format:String = "png";
		
		private var _layerName:String;
		
		/**
		 * A list of all resolutions available on the server.
		 * Only set this property if the map resolutions differs from the server
		 */
		private var _serverResolutions:Array = null;
		
		public function TMS(name:String,
							url:String, layerName:String="") {
			super(name, url);
			this._layerName = layerName;
			
		}
		
		override public function getURL(bounds:Bounds):String {
			var res:Number = this.map.resolution;
			if(this._tileOrigin==null) {
				this._tileOrigin = new Location(this.maxExtent.left,this.maxExtent.bottom);
			}
			
			var x:Number = Math.round((bounds.left - this._tileOrigin.lon) / (res * this.tileWidth));
			var y:Number = Math.round((bounds.bottom - this._tileOrigin.lat) / ( res* this.tileHeight));
			var z:Number = (this._serverResolutions!=null) ? this._serverResolutions.indexOf(res) : this.map.zoom;

			var url:String = this.url + this._serviceVersion +"/" + this.layerName + "/" + z + "/" + x + "/" + y+"."+this._format;
			return url ;
		}

		override public function addTile(bounds:Bounds, position:Pixel):ImageTile {
			return new ImageTile(this, position, bounds, this.getURL(bounds), new Size(this.tileWidth, this.tileHeight));
		}

		override public function set map(map:Map):void {
			super.map = map;
			if (! this._tileOrigin) {
				this._tileOrigin = new Location(this.map.maxExtent.left, this.map.maxExtent.bottom);
			}
		}

		/**
		 * setter for tile image format
		 * 
		 * @param value:String the tile image extention
		 */
		public function set format(value:String):void {
			if(value.length==0)
				return;
			else if(value.charAt(0)=='.')
				this._format = value.substr(1,value.length-1);
			else
				this._format = value;
		}
		/**
		 * getter for tile image format
		 * 
		 * @return String the tile image format
		 */
		public function get format():String {
			return this._format;
		}

		/**
		 * setter and getter of the TMS grid origin
		 */
		public function set origin(value:Location):void {
			this._tileOrigin = value;
		}
		public function get origin():Location {
			return this._tileOrigin.clone();
		}
		/**
		 * setter and getter of the TMS layer name
		 */
		public function set layerName(value:String):void {
			this._layerName = value;
		}
		public function get layerName():String {
			return this._layerName;
		}
	}
}

