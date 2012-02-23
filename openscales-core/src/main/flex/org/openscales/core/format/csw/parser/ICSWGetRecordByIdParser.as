package org.openscales.core.format.csw.parser
{
	import org.openscales.core.basetypes.maps.HashMap;

	public interface ICSWGetRecordByIdParser
	{
		/**
		 * read the XML data of the CSW GetRecordById Request
		 * return a hashmap different for each elementSetName
		 */
		function read(data:Object):HashMap;
	}
}