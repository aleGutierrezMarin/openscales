package org.openscales.core.format.csw.parser
{
	import org.openscales.core.basetypes.maps.HashMap;

	public interface ICSWGetRecordParser
	{
		/**
		* read the XML data of the CSW GetRecords Request
		* return a hashmap different for each elementSetName
		*/
		function read(data:Object):HashMap;
	}
}