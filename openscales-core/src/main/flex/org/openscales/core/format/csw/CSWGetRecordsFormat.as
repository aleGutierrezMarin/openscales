package org.openscales.core.format.csw
{
	import flash.xml.XMLDocument;
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.csw.parser.CSWGetRecordsParser202;
	import org.openscales.core.format.csw.parser.ICSWGetRecordParser;
	import org.openscales.core.request.csw.GetRecordsByIdRequest;
	import org.openscales.core.request.csw.GetRecordsRequest;
	import org.openscales.core.utils.Trace;

	/**
	 * This class is used to make several CSW type requests and get their content
	 * The methods of the class will return Hasmap with the values
	 * Currently implementing GetRecords and GetRecordsById request
	 */
	public class CSWGetRecordsFormat extends Format
	{
		
		/**
		 * Version of the CSW format
		 */
		private var _version:String = "2.0.2";
		
		/**
		 * The internal object for GetRecords request
		 */
		private var _getRecordsRequest:GetRecordsRequest;
		
		/**
		 * The internal object for GetRecordsByIdRequest request
		 */
		private var _getRecordsByIdRequest:GetRecordsByIdRequest;
		
		/**
		 * custom parser to handle service specific information such as "full" elementSetName
		 */
		private var _customGetRecordsParser:ICSWGetRecordParser;
		
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
		public function get customGetRecordsParser():ICSWGetRecordParser
		{
			return this._customGetRecordsParser;
		}

		/**
		 * @private
		 */
		public function set customGetRecordsParser(value:ICSWGetRecordParser):void
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
		
	}
}