package org.openscales.core.layer.ogc.WMTS
{
	import org.openscales.core.basetypes.maps.HashMap;
	
	/**
	 * This class represents a tile matrix set as defined in getCapablilties. It is meant to be created
	 * while parsing WMTS GetCapabilities response and meant to be accessed when a user creates a WMTS layer.
	 * <p>
	 * The class corresponds to the TileMatrixSet tag of the capabilities xml file
	 * </p>
	 * @author htulipe
	 */ 
	public class TileMatrixSet
	{
		
		private var _identifier:String;
		private var _supportedCRS:String;
		private var _tileMatrices:HashMap;
		
		/**
		 * @param identifier String A String that uniquely identify this tile matrix set
		 * @param supportedCRS String A string that uniquely identify the supported CRS for this tile matrix set
		 * @param tileMatrices HashMap An HashMap containing all tileMatrices contained within this tile matrix set (key:String, value:TileMatrix) 
		 */ 
		public function TileMatrixSet(identifier:String,supportedCRS:String,tileMatrices:HashMap)
		{
			this._identifier = identifier;
			this._supportedCRS = supportedCRS;
			this._tileMatrices = tileMatrices;
		}
		
		/**
		 * The string that uniquely identify this tile matrix set
		 * <p>
		 * Corresponds to identifier tag 
		 * </p>
		 */ 
		public function get identifier():String
		{
			return _identifier;
		}
		
		/**
		 * @private
		 */ 
		public function set identifier(value:String):void
		{
			_identifier = value;
		}
		
		/**
		 * The string that uniquely identify the supported CRS for this tile matrix set
		 * <p>
		 * Corresponds to supportedCRS tag 
		 * </p>
		 */ 
		public function get supportedCRS():String
		{
			return _supportedCRS;
		}
		
		/**
		 * @private
		 */
		public function set supportedCRS(value:String):void
		{
			_supportedCRS = value;
		}
		
		/**
		 * An HashMap containing all tileMatrices contained within this tile matrix set.
		 * <ul>
		 * 	<li>Key: the tile matrix resolution (calculated from scaleDenominator)</li>
		 *  <li>Value: the TileMatrix instance that represents the tile matrix</li>
		 * </ul>
		 * <p>
		 * corresponds to all TileMatrix tags
		 * </p>
		 */ 
		public function get tileMatrices():HashMap
		{
			return _tileMatrices;
		}
		
		/**
		 * @private
		 */ 
		public function set tileMatrices(value:HashMap):void
		{
			_tileMatrices = value;
		}
		
		/**
		 * Destroy the TileMatrixSet
		 */
		public function destroy():void {
			if(!this._tileMatrices)
				return;
			var tms:Array = this._tileMatrices.getValues();
			var l:uint = tms.length;
			for(var i:uint = 0; i<l; ++i) {
				(tms[i] as TileMatrix).destroy();
			}
			this._tileMatrices.clear();
			this._tileMatrices = null;
		}
		
	}
}