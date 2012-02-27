package org.openscales.core.format.csw.parser
{
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.geometry.basetypes.Bounds;

	public class CSWGetRecordByIdParser202 implements ICSWGetRecordByIdParser
	{
		
		/**
		 * Parser for CSW 2.0.2 GetRecordById response
		 */
		public function CSWGetRecordByIdParser202()
		{
		}
		
		
		
		public function read(data:Object):HashMap
		{
			if(!data)return null;
			
			var xml:XML = new XML(data);
			var result:HashMap = new HashMap();
			var records:Vector.<HashMap> = new Vector.<HashMap>();
			var record:HashMap = new HashMap();
			
			return null;
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
	}
}