package org.openscales.core.format
{
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.proj4as.ProjProjection;

	public class DCFormat extends Format
	{
		public function DCFormat()
		{
			super();
		}
		
		/**
		 * read the XML data of the CSW GetRecords Request
		 * in DC format.
		 * return a Vector of hashmap different for each elementSetName
		 * 
		 * for "brief" :
		 * - records:Vector[Hasmap]
		 * 		- identifiers:Vector.[String]
		 * 		- titles:Vector.[String]
		 * 		- type:String
		 * 		- BoundingBox:Vector.[Bounds]
		 * 
		 * for "summary" :
		 * - records:Vector Hasmap 
		 * 		- identifiers:Vector.[String]
		 * 		- titles:Vector.[String]
		 * 		- type:String
		 * 		- subjects:Vector.[String]
		 * 		- format:Vector.[String]
		 * 		- relation: Vector.[String]
		 * 		- modified: Vector.[String]
		 * 		- abstract:Vector.[String]
		 * 		- spatial:Vector.[String]
		 * 		- BoundingBox:Vector.[Bounds]
		 * 
		 * for "full" : 
		 * return null, you need to extend this class  and override the method parseRecord 
		 * to handle this record set. You need to set your custom class to the customGetRecordsParser 
		 * parameter of the CSWGetRecordsFormat class. 
		 */
		override public function read(data:Object):Object
		{
			if(!data)return null;
			
			var xml:XML = new XML(data);
			var records:Vector.<HashMap> = new Vector.<HashMap>();
			var record:HashMap = new HashMap();
			
			var cswNS:Namespace = xml.namespace("csw");
			
			if (!cswNS)
				return null;
			
			var getRecordsResponse:XML = xml.cswNS::GetRecordsResponse[0];
			
			var searchResult:XML = xml.cswNS::SearchResults[0];
			if (!searchResult)
				return null;
			
			var dataRecords:XMLList = searchResult.cswNS::SummaryRecord;
			var parseFunction:Function;
			
			// Choose the parse function according to balise type
			if (dataRecords.length() > 0)
			{
				parseFunction = this.parseSummaryRecord;
			}else{
				dataRecords = searchResult.cswNS::BriefRecord;
				if (dataRecords.length() > 0)
				{
					parseFunction = this.parseBriefRecord;
				}else
				{
					dataRecords = searchResult.cswNS::Record;
					if (dataRecords.length() > 0)
					{
						parseFunction = this.parseRecord;
					}
				}
			}
			if (!dataRecords.length() > 0)
				return null;
			
			var recordData:XML;
			for each(recordData in dataRecords){
				record = parseFunction.call(this,recordData);
				if (record)
					records.push(record);
			}
			return records;
		}
		
		/**
		 * Parse the data as "brief" elementSetName and return a Hasmap
		 */
		public function parseBriefRecord(data:XML):HashMap
		{
			var record:HashMap = new HashMap();
			var dcNS:Namespace = data.namespace("dc");
			
			var identifiers:Vector.<String> = null ;
			var titles:Vector.<String> = null;
			var type:String = "";
			var boundingBox:Vector.<Bounds> = null;
			
			// Parse identifier
			var identifiersData:XMLList = data.dcNS::identifier;
			if (identifiersData.length() > 0)
			{
				identifiers = new Vector.<String>();
				var idData:XML;
				
				for each(idData in identifiersData)
				{
					identifiers.push(idData)	
				}
			}
			
			// Parse title
			var titlesData:XMLList = data.dcNS::title;
			if (titlesData.length() > 0)
			{
				titles = new Vector.<String>();
				var titleData:XML;
				
				for each(titleData in titlesData)
				{
					titles.push(titleData);
				}
			}
			
			// Parse type
			var typeData:XML = data.dcNS::type[0];
			if (typeData)
			{
				type = typeData;
			}
			
			// Parse boundingBox
			var owsNS:Namespace = data.namespace("ows");
			var bboxsData:XMLList = data.owsNS::BoundingBox;
			if (bboxsData.length() > 0)
			{
				boundingBox = new Vector.<Bounds>();
				var bboxData:XML;
				for each (bboxData in bboxsData)
				{
					var bbox:Bounds = this.parseBoundingBox(bboxData);
					if (bbox)
					{
						boundingBox.push(bbox);
					}
				}
			}
			
			record.put("identifier",identifiers);
			record.put("title", titles);
			record.put("type",type);
			record.put("boundingBox",boundingBox);
			return record;
		}
		
		/**
		 * Parse the data as "summary" elementSetName and return a Hasmap
		 */
		public function parseSummaryRecord(data:XML):HashMap
		{
			var record:HashMap = new HashMap();
			var dcNS:Namespace = data.namespace("dc");
			var dctNS:Namespace = data.namespace("dct");
			
			var identifiers:Vector.<String> = null ;
			var titles:Vector.<String> = null;
			var type:String = "";
			var subjects:Vector.<String> = null;
			var formats:Vector.<String> = null;
			var relations:Vector.<String> = null;
			var modifieds:Vector.<String> = null;
			var abstracts:Vector.<String> = null;
			var spatials:Vector.<String> = null;
			var boundingBox:Vector.<Bounds> = null;
			
			// Parse identifier
			var identifiersData:XMLList = data.dcNS::identifier;
			if (identifiersData.length() > 0)
			{
				identifiers = new Vector.<String>();
				var idData:XML;
				
				for each(idData in identifiersData)
				{
					identifiers.push(idData)	
				}
			}
			
			// Parse title
			var titlesData:XMLList = data.dcNS::title;
			if (titlesData.length() > 0)
			{
				titles = new Vector.<String>();
				var titleData:XML;
				
				for each(titleData in titlesData)
				{
					titles.push(titleData);
				}
			}
			
			// Parse type
			var typeData:XML = data.dcNS::type[0];
			if (typeData)
			{
				type = typeData;
			}
			
			// Parse subject
			var subjectsData:XMLList = data.dcNS::subject;
			if (subjectsData.length() > 0)
			{
				subjects = new Vector.<String>();
				var subjectData:XML;
				
				for each(subjectData in subjectsData)
				{
					subjects.push(subjectData);
				}
			}
			
			// Parse format
			var formatsData:XMLList = data.dcNS::format;
			if (formatsData.length() > 0)
			{
				formats = new Vector.<String>();
				var formatData:XML;
				
				for each(formatData in formatsData)
				{
					formats.push(formatData);
				}
			}
			
			// Parse relation
			var relationsData:XMLList = data.dcNS::relation;
			if (relationsData.length() > 0)
			{
				relations = new Vector.<String>();
				var relationData:XML;
				
				for each (relationData in relationsData)
				{
					relations.push(relationsData);
				}
			}
			
			// Parse modified
			var modifiedsData:XMLList = data.dctNS::modifier;
			if (modifiedsData.length() > 0)
			{
				modifieds = new Vector.<String>();
				var modifiedData:XML;
				
				for each (modifiedData in modifiedsData)
				{
					modifieds.push(modifiedData);
				}
			}
			
			// Parse abstract
			var abstractsData:XMLList = data.dctNS::abstract;
			if (abstractsData.length() > 0)
			{
				abstracts = new Vector.<String>();
				var abstractData:XML;
				
				for each (abstractData in abstractsData)
				{
					abstracts.push(abstractData);
				}
			}
			
			// Parse spatial
			var spatialsData:XMLList = data.dctNS::spatial;
			if (spatialsData.length() > 0)
			{
				spatials = new Vector.<String>();
				var spatialData:XML;
				
				for each (spatialData in spatialsData)
				{
					spatials.push(spatialData);
				}
				
			}
			
			// Parse boundingBox
			var owsNS:Namespace = data.namespace("ows");
			var bboxsData:XMLList = data.owsNS::BoundingBox;
			if (bboxsData.length() > 0)
			{
				boundingBox = new Vector.<Bounds>();
				var bboxData:XML;
				for each (bboxData in bboxsData)
				{
					var bbox:Bounds = this.parseBoundingBox(bboxData);
					if (bbox)
					{
						boundingBox.push(bbox);
					}
				}
			}
			
			record.put("indentifier",identifiers);
			record.put("title", titles);
			record.put("type",type);
			record.put("subject", subjects);
			record.put("format", formats);
			record.put("relation", relations);
			record.put("modified", modifieds);
			record.put("abstract", abstracts);
			record.put("spatial", spatials);
			record.put("boundingBox",boundingBox);
			return record;
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
			if (!data)
				return null;
			
			var owsNS:Namespace = data.namespace("ows");
			var proj:ProjProjection = ProjProjection.getProjProjection(data.@crs[0].toString());
			
			// Unknown projection
			if (!proj)
				return null;
			
			var lowerCorner:String = data.owsNS::LowerCorner[0];
			var upperCorner:String = data.owsNS::UpperCorner[0];
			var lowerCornerArray:Array = lowerCorner.split(" ");
			var upperCornerArray:Array = upperCorner.split(" ");
			if (proj.lonlat)
				return new Bounds(lowerCornerArray[0], upperCornerArray[1], upperCornerArray[0], lowerCornerArray[1], proj);
			else
				return new Bounds(lowerCornerArray[1], upperCornerArray[0], upperCornerArray[1], lowerCornerArray[0], proj);
			
		}
	}
}