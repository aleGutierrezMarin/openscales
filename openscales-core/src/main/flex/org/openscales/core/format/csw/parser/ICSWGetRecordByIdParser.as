package org.openscales.core.format.csw.parser
{
	import org.openscales.core.basetypes.maps.HashMap;

	public interface ICSWGetRecordByIdParser
	{
		/**
		 * read the XML data of the CSW GetRecordById Request
		 * 
		 * @param data The raw data to be read
		 * @param An a hash map different for each elementSetName
		 */
		function read(data:Object):Object;
	}
}