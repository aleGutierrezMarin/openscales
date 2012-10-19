package org.openscales.core.json
{
	import flash.system.ApplicationDomain;
	
	public final class GENERICJSON
	{
		/**
		 * Encodes a object into a JSON string.
		 *
		 * @param o The object to create a JSON string for
		 * @return the JSON string representing o
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */
		public static function encode( o:Object ):String
		{
			if ( ApplicationDomain.currentDomain.hasDefinition("JSON") ) {
				return JSON.stringify(o);
			}
			return new JSONEncoder(o).getString();
		}
		/**
		 * Encodes a object into a JSON string.
		 *
		 * @param o The object to create a JSON string for
		 * @return the JSON string representing o
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */
		public static function stringify( o:Object ):String
		{
			return GENERICJSON.encode(o);
		}
		
		/**
		 * Decodes a JSON string into a native object.
		 *
		 * @param s The JSON string representing the object
		 * @param strict Flag indicating if the decoder should strictly adhere
		 * 		to the JSON standard or not.  The default of <code>true</code>
		 * 		throws errors if the format does not match the JSON syntax exactly.
		 * 		Pass <code>false</code> to allow for non-properly-formatted JSON
		 * 		strings to be decoded with more leniancy.
		 * @return A native object as specified by s
		 * @throw JSONParseError
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */
		public static function decode( s:String, strict:Boolean = true ):*
		{
			if ( ApplicationDomain.currentDomain.hasDefinition("JSON") ) {
				return JSON.parse(s);
			}
			return new JSONDecoder( s, strict ).getValue();
		}
		
		/**
		 * Decodes a JSON string into a native object.
		 *
		 * @param s The JSON string representing the object
		 * @return A native object as specified by s
		 * @throw JSONParseError
		 * @langversion ActionScript 3.0
		 * @playerversion Flash 9.0
		 * @tiptext
		 */
		public static function parse( s:String):*
		{
			return GENERICJSON.decode(s);
		}
	}
}