package org.openscales.core.layer.params
{
	/**
	 * Interface to implement for HTTP params objects
	 */
	public interface IHttpParams
	{

		/**
		 * This method is supposed to return a params string for HTTP GET requests like :
		 * key1=value1&amp;key2=value2&amp;key3=value3
		 *
		 * @return String
		 */
		function toGETString():String;

		/**
		 * This method is supposed to add a new key/value to the list of params.
		 *
		 * @param key
		 * @param value
		 */
		function setAdditionalParam(key:String, value:String):void;

		/**
		 * Requesting bbox
		 **/
		function get bbox():String;
		function set bbox(bbox:String):void;
	}
}

