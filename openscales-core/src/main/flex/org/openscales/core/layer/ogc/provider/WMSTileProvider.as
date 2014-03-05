package org.openscales.core.layer.ogc.provider
{
	import org.openscales.core.events.OpenScalesEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.ProjProjection;
	
	use namespace os_internal;
	
	/**
	 * The WMSTileProvider is the exclusive way of requesting a service.
	 * It contains the mandatory and optional parameters needed to construct the request.
	 * The request is automaticaly generated when necessary, based on the previously set parameters.
	 * 
	 * @author javocale
	 * 
	 */
	
	public class WMSTileProvider extends OGCTileProvider
	{	
		/**
		 * @private
		 * Layer identifier to request from service
		 */
		private var _layer:String;
		
		/**
		 * @private
		 * Style identifier for the requested layer
		 */
		private var _style:String = '';
		
		/**
		 * @private
		 * MIME type for the requested layer
		 */
		private var _format:String;
		
		/**
		 * @private 
		 * Projection system used
		 */
		private var _projection:ProjProjection;
		
		/**
		 * @private 
		 * Way to display errors for the requested tile
		 */
		private var _exceptions:String="XML";
		
		/**
		 * @private 
		 * Indicates if the tile should be transparent or not
		 */
		private var _transparent:Boolean=true;
		
		/**
		 * @private
		 * Background color of the requested tile
		 */
		private var _bgcolor:String;
		
		/**
		 * @pivate
		 * Width of the requested tile
		 */
		private var _width:Number;
		
		/**
		 * @private
		 * Height of the requested tile
		 */
		private var _height:Number;
		
		/**
		 * @private
		 * Bounding box corners (lower left, upper right)
		 */
		private var _bbox:String;
		
		/**
		 * @private
		 * Is the service returning tiled layers?
		 */
		private var _tiled:Boolean=false;
		
		
		/**
		 * Constructor of the WMSTileProvider.
		 * 
		 * @param openscalesLayer Layer in openscales linked to this tileProvider.
		 * @param url URL of the server to request.
		 * @param version Version of the service requested.
		 * @param layer Layers to request on the server.
		 * @param projection Projection system used to request the service.
		 * @param style Styles of the requested layers.
		 * @param format Mime type used for the returned tiles.
		 * 
		 */
		public function WMSTileProvider(url:String,
										version:String,
										layer:String,
										projection:*,
										style:String = "",
										format:String = "image/jpeg")
		{
			//call the constructor of the mother class OGCTileProvider
			super(url,"WMS",version,"GetMap");
			
			//Save WMS specific parameters
			this._layer=layer;
			this.projection=projection
			this._style=style;
			this._format=format;
		}
		
		/**
		 * @inheritDoc
		 */ 
		override public function getTile(bounds:Bounds, center:Pixel, layer:Layer):ImageTile
		{
			var url:String = this.buildGETQuery(bounds, null);
			var img:ImageTile = new ImageTile(layer, center, bounds, url, new Size(this._width, this._height));
			img.useNoDataTile = _useNoDataTile;
			if(layer is WMS && (layer as WMS).method != null)
				img.method = (layer as WMS).method;
			return img;
		}
		
		/**
		 * Generate a well-formated URL to request a WMS tile with all the parameters set in the provider.
		 * 
		 * @param bounds Bounds of the requested tile 
		 */
		public function getTileUrl(bounds:Bounds):String {
			return this.buildGETQuery(bounds,null);
		}
		
		/**
		 * Generate a request URL based on the parameters set in the tile provider
		 * 
		 * @param bounds bounds of the tile to set in the request string
		 */ 
		override os_internal function buildGETQuery(bounds:Bounds, params:Object):String {
						
			var str:String = super.buildGETQuery(bounds, params);
			
			// Mandatory LAYERS parameter
			str += "LAYERS=" + ((this._layer != null) ? this._layer : '') + "&";
			
			// Mandatory STYLES parameter
			str += "STYLES=" + ((this._style != null) ? this._style : '') +'&';
	
			
			// Mandatory CRS or SRS parameter
			if(this.version=="1.3.0") {
				str += "CRS=" + this._projection.srsCode + "&";
			} else {
				str += "SRS=" + this._projection.srsCode + "&";
			}
			
			// Mandatory BBOX parameters
			// Lon/Lat if less than 1.3.0 or if axis order of the projection is East/North, lat/lon otherwise
			if(this.version=="1.3.0"
					&& !this.projection.lonlat){
				str += "BBOX=" + bounds.bottom+","+ bounds.left +","+ bounds.top +","+ bounds.right+"&";
			}else {
				str += "BBOX=" + bounds.left+","+ bounds.bottom +","+ bounds.right +","+ bounds.top+"&";
			}
				
			// Mandatory HEIGHT and WIDTH parameters
			str += "WIDTH=" + this._width + "&";
			str += "HEIGHT=" + this._height + "&";
			
			// Mandatory FORMAT parameters
			str += "FORMAT=" + this._format + "&";
			
			str += "TRANSPARENT=" + this._transparent.toString().toUpperCase() + "&";
			
			if (this._bgcolor != null && this._bgcolor != "")
				str += "BGCOLOR=" + this._bgcolor + "&";
			
			if (this._exceptions != null && this._exceptions != "")
				str += "EXCEPTIONS=" + this._exceptions + "&";
			
			str += "TILED=" + this._tiled + "&";
			
			
			return str.substr(0, str.length-1);
		}
		
		/**
		 * Layer identifier to request from service
		 */
		public function get layer():String
		{
			return _layer;
		}
		
		/**
		 * @private
		 */
		public function set layer(value:String):void
		{
			_layer = value;
		}
		
		/**
		 * Style identifier for the requested layer
		 */
		public function get style():String
		{
			return _style;
		}
		
		/**
		 * @private
		 */
		public function set style(value:String):void
		{
			_style = value;
		}
		
		/**
		 * MIME type for the requested layer
		 */
		public function get format():String
		{
			return _format;
		}
		
		/**
		 * @private
		 */
		public function set format(value:String):void
		{
			_format = value;
		}
		
		/**
		 * Projection system used
		 */
		public function get projection():ProjProjection
		{
			return _projection;
		}
		
		/**
		 * @private
		 */
		public function set projection(value:*):void
		{
			_projection = ProjProjection.getProjProjection(value);
		}
		
		/**
		 * Way to display errors for the requested tile
		 */
		public function get exceptions():String
		{
			return _exceptions;
		}
		
		/**
		 * @private
		 */
		public function set exceptions(value:String):void
		{
			_exceptions = value;
		}
		
		/**
		 * Indicates if the tile should be transparent or not
		 */
		public function get transparent():Boolean
		{
			return _transparent;
		}
		
		/**
		 * @private
		 */
		public function set transparent(value:Boolean):void
		{
			_transparent = value;
		}
		
		/**
		 * Background color of the requested tile
		 */
		public function get bgcolor():String
		{
			return _bgcolor;
		}
		
		/**
		 * @private
		 */
		public function set bgcolor(value:String):void
		{
			_bgcolor = value;
		}
		
		/**
		 * Width of the requested tile
		 */
		public function get width():Number
		{
			return _width;
		}
		
		/**
		 * @private
		 */
		public function set width(value:Number):void
		{
			_width = value;
		}
		
		/**
		 * Height of the requested tile
		 */
		public function get height():Number
		{
			return _height;
		}
		
		/**
		 * @private
		 */
		public function set height(value:Number):void
		{
			_height = value;
		}
		
		/**
		 * Bounding box corners (lower left, upper right)
		 */
		public function get bbox():String
		{
			return _bbox;
		}
		
		/**
		 * @private
		 */
		public function set bbox(value:String):void
		{
			_bbox = value;
		}

		/**
		 * Is the service returning tiled layers?
		 */
		public function get tiled():Boolean
		{
			return _tiled;
		}

		/**
		 * @private
		 */
		public function set tiled(value:Boolean):void
		{
			_tiled = value;
		}
	}
}