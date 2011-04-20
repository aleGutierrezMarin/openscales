package org.openscales.core.layer.ogc
{
	import org.openscales.core.Trace;
	import org.openscales.core.layer.Grid;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.provider.WMTSTileProvider;
	import org.openscales.core.layer.params.IHttpParams;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * Instances of the WMTS class allow viewing of tiles from a service that 
	 *     implements the OGC WMTS specification version 1.0.0.
	 * <br/><br/>
	 * Bellow is an example:
	 * <code>
	 * 		var m:Map = new Map();
	 * 		var wmts:WMTS = new WMTS("myLayer","http://foo.org","layer1","matrixSet15","image/jpeg","_null");
	 * 		m.addLayer(wmts);
	 * </code>
	 */
	public class WMTS extends Grid
	{
		/**
		 * @private
		 *  
		 * A tile provider for this layer.
		 */ 
		private var _tileProvider:WMTSTileProvider;
		private var _matrixIds:Object;
		
		/**
		 * Constructor
		 * 
		 * @param name String A name for the layer
		 * @param url String The url where is located the WMTS service that will be queried by the instance
		 * @param layer String The desired layer identifier. It must be a valid identifier (ie it must be in getCapablities)
		 * @param tileMatrixSet String The desired matrix set identifier. It must be a valid identifier (ie it must be in getCapablities)
		 * @param format String The Mime type defining the format for returned tiles (see getCapablities for supported format)
		 * @param style String the desired style identifier for returned tiles (see getCapablities for supported format)
		 * @param matrixIds Object An object containing for each matrix (of the matrix set) its identifier an its scaleDenominator
		 */ 
		public function WMTS(name:String, 
							 url:String, 
							 layer:String, 
							 tileMatrixSet:String, 
							 format:String, 
							 style:String,
							 matrixIds:Object)
		{
			this._matrixIds = matrixIds;
			super(name, url);
			
			
			
			// building the tile provider
			_tileProvider = new WMTSTileProvider(url,format,tileMatrixSet,layer,style,matrixIds);
		}
		
		/**
		 * @inheritDoc
		 */ 
		override public function addTile(bounds:Bounds, center:Pixel):ImageTile
		{
			var left:Number = this.map.maxExtent.left;
			var top:Number = this.map.maxExtent.top;
			var srs:String = this.map.maxExtent.projSrsCode;
			var tileOrigin:Location = new Location(left,top,srs);  
			
			_tileProvider.tileOrigin = tileOrigin;
			
			// using the provider to get a tile from its bounds
			_tileProvider.zoom = this.map.zoom;
			var tile:ImageTile = _tileProvider.getTile(bounds);
			
			// Setting the tile center
			tile.position = center;
			tile.layer = this;
			
			return tile;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function generateResolutions(numZoomLevels:uint=Layer.DEFAULT_NUM_ZOOM_LEVELS, nominalResolution:Number=NaN):void {
			//TODO;
			var resolutions:Array = new Array();
			for each(var matrix:Object in this._matrixIds){
				if(matrix["scaleDenominator"]) {
					var scale:Number = parseFloat(matrix["scaleDenominator"] as String);
					var resolution:Number = scale * Unit.PIXEL_SIZE /  Unit.getMetersPerUnit(ProjProjection.getProjProjection(this.projSrsCode).projParams.units);
					resolutions.push(resolution);
				}
			}
			this.resolutions = resolutions;
			this._autoResolution = true;
		}
		
		override public function getURL(bounds:Bounds):String {
			return this._tileProvider.getTile(bounds).url;
		}

	}
	
}