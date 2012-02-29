package org.openscales.core.format.csw.parser
{
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.GMDFormat;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * Parser for CSW 2.0.2 GetRecords response, 
	 */
	public class CSWGetRecordsParser202
	{
		
		/**
		 * Response format
		 * @default org.openscales.core.format.GMDFormat
		 */
		private var _responseFormat:Format = new GMDFormat();
		
		public function CSWGetRecordsParser202()
		{
		}
		
		
		/**
		 * read the XML data of the CSW GetRecords Request
		 * return a hashmap with the metadata
		 * 
		 * - numberOfRecordsMatched:Number
		 * - numberOfRecordsReturned:Number
		 * - nextRecord:Number
		 * - recordType:String ="summary"
		 * - records:Vector(Hasmap)
		 * 
		 * for "full" recordType you need to extend a parser and give it as reponseFormat Format and override the method parseRecord 
		 * to handle this record set.
		 */
		public function read(data:Object):HashMap
		{
			
			var xml:XML = new XML(data);
			var result:HashMap = new HashMap();
			var records:Vector.<HashMap> = new Vector.<HashMap>();
			var record:HashMap = new HashMap();
			
			var cswNS:Namespace = xml.namespace("csw");
			var getRecordsResponse:XML = xml.cswNS::GetRecordsResponse[0];
			
			var searchResult:XML = xml.cswNS::SearchResults[0];
			if (!searchResult)
				return null;
			
			result.put("numberOfRecordsMatched", new Number(searchResult.@numberOfRecordsMatched));
			result.put("numberOfRecordsReturned", new Number(searchResult.@numberOfRecordsReturned));
			result.put("nextRecord", new Number(searchResult.@nextRecord));
			
			records = (this._responseFormat.read(data) as Vector.<HashMap>);
			result.put("records", records);
			return result;
		}
		
		//Getter Setter
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