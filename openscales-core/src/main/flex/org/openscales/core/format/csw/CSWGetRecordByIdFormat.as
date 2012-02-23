package org.openscales.core.format.csw
{
	import org.openscales.core.format.Format;
	import org.openscales.core.format.csw.parser.CSWGetRecordByIdParser202;
	import org.openscales.core.format.csw.parser.ICSWGetRecordByIdParser;
	import org.openscales.core.utils.Trace;

	/**
	 * This class is used to read CSW 2.0.2 GetRecordById data
	 * To request CSW GetRecordById data, use the GetRecordByIdRequest class
	 */
	public class CSWGetRecordByIdFormat extends Format
	{
		
		/**
		 * Version of the CSW format
		 */
		private var _version:String = "2.0.2";
		
		/**
		 * custom parser to handle service specific information such as "full" elementSetName
		 */
		private var _customGetRecordByIdParser:ICSWGetRecordByIdParser;
		
		public function CSWGetRecordByIdFormat()
		{
		}
		
		/**
		 * Take the XML data of a getRecordBuId response ans
		 * return a hashmap containing the data
		 */
		override public function read(data:Object):Object
		{
			if(!data)return null;
			
			// handle custom parser
			if(this._customGetRecordByIdParser)
			{
				return _customGetRecordByIdParser.read(data);
			}
			
			if (this._version == "2.0.2")
			{
				var parser:CSWGetRecordByIdParser202 = new CSWGetRecordByIdParser202();
				return parser.read(data);
			}else{
				Trace.error("CSW GetRecordBuId version : "+_version+" not supported");
				return null;
			}
		}
		
		// getter setter
		/**
		 * Custom parser for CSW data to handle service specific information such as "full" elementSetName
		 * if setted to null, this class will use the version specific parser to return metadata for 
		 * "brief" and "summary" elementSetName
		 */
		public function get customGetRecordByIdParser():ICSWGetRecordByIdParser
		{
			return this._customGetRecordByIdParser;
		}
		
		/**
		 * @private
		 */
		public function set customGetRecordByIdParser(value:ICSWGetRecordByIdParser):void
		{
			this._customGetRecordByIdParser = value;
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