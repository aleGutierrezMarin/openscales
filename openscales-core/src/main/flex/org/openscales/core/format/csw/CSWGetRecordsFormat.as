package org.openscales.core.format.csw
{
	import flash.xml.XMLDocument;
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.GMDFormat;
	import org.openscales.core.format.csw.parser.CSWGetRecordsParser202;
	import org.openscales.core.format.csw.parser.ICSWGetRecordsParser;
	import org.openscales.core.request.csw.GetRecordByIdRequest;
	import org.openscales.core.request.csw.GetRecordsRequest;
	import org.openscales.core.utils.Trace;

	/**
	 * This class is used to read CSW 2.0.2 GetRecords data
	 * To request CSW GetRecords data, use the GetRecordsRequest class
	 */
	public class CSWGetRecordsFormat extends Format
	{
		
		/**
		 * Version of the CSW format
		 */
		private var _version:String = "2.0.2";
		
		/**
		 * custom parser to handle service specific information such as "full" elementSetName
		 */
		private var _customGetRecordsParser:ICSWGetRecordsParser;
		
		/**
		 * Response format
		 * @default org.openscales.core.format.GMDFormat
		 */
		private var _responseFormat:Format = new GMDFormat();
		
		public function CSWGetRecordsFormat()
		{
			super();
		}
		
		/**
		 * Take the XML data of a getRecords response ans
		 * return a hashmap containing the data
		 */
		override public function read(data:Object):Object
		{
			if(!data)return null;
			
			// handle custom parser
			if(this._customGetRecordsParser)
			{
				return _customGetRecordsParser.read(data);
			}
			
			if (this._version == "2.0.2")
			{
				var parser:CSWGetRecordsParser202 = new CSWGetRecordsParser202();
				parser.responseFormat = this._responseFormat;
				return parser.read(data);
			}else{
				Trace.error("CSW GetRecords version : "+_version+" not supported");
				return null;
			}
		}
		
		// getter setter
		
		/**
		 * Custom parser for CSW data to handle service specific information such as "full" elementSetName
		 * if setted to null, this class will use the version specific parser to return metadata for 
		 * "brief" and "summary" elementSetName
		 */
		public function get customGetRecordsParser():ICSWGetRecordsParser
		{
			return this._customGetRecordsParser;
		}

		/**
		 * @private
		 */
		public function set customGetRecordsParser(value:ICSWGetRecordsParser):void
		{
			this._customGetRecordsParser = value;
		}
		
		/**
		 * CSW version number.
		 * Default to 2.0.2
		 */
		public function get version():String
		{
			return this._version;
		}
		
		/**
		 * @private
		 */
		public function set version(value:String):void
		{
			this._version = value;
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