package org.openscales.core.format.csw.parser
{
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.GMDFormat;
	import org.openscales.geometry.basetypes.Bounds;

	public class CSWGetRecordByIdParser202 implements ICSWGetRecordByIdParser
	{
		
		
		/**
		 * Response format
		 * @default org.openscales.core.format.GMDFormat
		 */
		private var _responseFormat:Format = new GMDFormat();
		
		/**
		 * Parser for CSW 2.0.2 GetRecordById response
		 */
		public function CSWGetRecordByIdParser202()
		{
		}
		
		
		
		public function read(data:Object):Object
		{
			if(!data)return null;
			
			return this._responseFormat.read(data);
		}
		
		/**
		 * Parse the data as "brief" elementSetName and return a Hasmap
		 */
		public function parseBriefRecord(data:XML):HashMap
		{
			return null
		}
		
		/**
		 * Parse the data as full elementSetName and return a Hasmap
		 * Override this class and implement your custom parser for "full" record here
		 */
		public function parseRecord(data:XML):HashMap
		{
			return null;
		}
		
		/**
		 * Parse a ows:BoundingBox node and return the related Bounds object
		 */
		public function parseBoundingBox(data:XML):Bounds
		{
				return null;
		}
		
		/**
		 * The format class that will be used to read the CSW reponse.
		 * @default org.openscales.core.format.GMDFormat
		 */
		public function get responseFormat():Format
		{
			return this._responseFormat;	
		}
		
		/**
		 * @private
		 */
		public function set responseFormat(value:Format):void
		{
			this._responseFormat = value;
		}
	}
}