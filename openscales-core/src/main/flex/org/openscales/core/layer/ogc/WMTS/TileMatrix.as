package org.openscales.core.layer.ogc.WMTS
{
	import org.openscales.geometry.basetypes.Location;

	/**
	 * A class that represents a tile matrix as specified by WMTS GetCapabilities response.
	 * 
	 * The class is meant to be created while parsing the capabilities response and meant to be accessed
	 * when the user creates a WMTS layer.
	 * <p>
	 * Corresponds to TileMatrix tag in WMTS GetCapabilities xml document
	 * </p>
	 * 
	 * @author htulipe
	 */ 
	public class TileMatrix
	{
		private var _identifier:String;
		private var _scaleDenominator:Number;
		private var _topLeftCorner:Location;
		private var _tileWidth:uint;
		private var _tileHeight:uint;
		private var _matrixWidth:uint;
		private var _matrixHeight:uint;
		
		/**
		 * @param identifer String The string that uniquely identify this tile matrix within its tile matrix set
		 * @param scaleDenominator Number The scale denominator for this tile matrix (in map units)
		 * @param topLeftCorner Location The location of this tile matrix top left corner (in maps units)
		 * @param tileWidth uint The width of this tile matrix (in pixels)
		 * @param tileHeight uint The height of this tile matrix (in pixels)
		 * @param matrixWidth uint The width of this tile matrix (ie the number of tiles in a row)
		 * @param matrixHeight uint The height of this tile matrix (ie the number of tiles in a column)
		 */ 
		public function TileMatrix(identifier:String,
								   scaleDenominator:Number,
								   topLeftCorner:Location,
								   tileWidth:uint,
								   tileHeight:uint,
								   matrixWidth:uint,
								   matrixHeight:uint)
		{
			this._identifier = identifier;
			this._scaleDenominator = scaleDenominator;
			this._topLeftCorner = topLeftCorner;
			this._tileWidth = tileWidth;
			this._tileHeight = tileHeight;
			this._matrixWidth = matrixWidth;
			this._matrixHeight = matrixHeight;
		}

		/**
		 * The string that uniquely identify this tile matrix in its tile matrix set
		 * <p>
		 * Corresponds to identifier tag in capabilities xml file 
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
		 * The scale denominator for this tile matrix (in map units)
		 * <p>
		 * Corresponds to scaleDenominator tag in capabilities xml file 
		 * </p>
		 */ 
		public function get scaleDenominator():Number
		{
			return _scaleDenominator;
		}

		/**
		 * @private
		 */ 
		public function set scaleDenominator(value:Number):void
		{
			_scaleDenominator = value;
		}

		/**
		 * The location of this tile matrix top left corner (in maps units)
		 * <p>
		 * Corresponds to topLeftCorner tag in capabilities xml file 
		 * </p>
		 */ 
		public function get topLeftCorner():Location
		{
			return _topLeftCorner;
		}

		/**
		 * @private
		 */ 
		public function set topLeftCorner(value:Location):void
		{
			_topLeftCorner = value;
		}

		/**
		 * The width of this tile matrix (in pixels)
		 * <p>
		 * Corresponds to tileWidth tag in capabilities xml file 
		 * </p>
		 */ 
		public function get tileWidth():uint
		{
			return _tileWidth;
		}

		/**
		 * @private
		 */ 
		public function set tileWidth(value:uint):void
		{
			_tileWidth = value;
		}

		/**
		 * The height of this tile matrix (in pixels)
		 * <p>
		 * Corresponds to tileHeight tag in capabilities xml file 
		 * </p>
		 */ 
		public function get tileHeight():uint
		{
			return _tileHeight;
		}

		/**
		 * @private
		 */ 
		public function set tileHeight(value:uint):void
		{
			_tileHeight = value;
		}

		/**
		 * The width of this tile matrix (ie the number of tiles in a row)
		 * <p>
		 * Corresponds to matrixWidth tag in capabilities xml file 
		 * </p>
		 */ 
		public function get matrixWidth():uint
		{
			return _matrixWidth;
		}

		/**
		 * @private
		 */ 
		public function set matrixWidth(value:uint):void
		{
			_matrixWidth = value;
		}

		/**
		 * The height of this tile matrix (ie the number of tiles in a column)
		 * <p>
		 * Corresponds to matrixHeight tag in capabilities xml file 
		 * </p>
		 */ 
		public function get matrixHeight():uint
		{
			return _matrixHeight;
		}

		/**
		 * @private
		 */ 
		public function set matrixHeight(value:uint):void
		{
			_matrixHeight = value;
		}
	}
}