package org.openscales.core.search.engine
{
	import org.openscales.core.search.result.Address;
	import org.openscales.core.security.ISecurity;
	import org.openscales.geometry.basetypes.Location;

	/**
	 * Abstract search engine
	 * This class defines the common methods that any SearchEngine should provide
	 */
	public class SearchEngine
	{
		/**
		 * @private
		 * maximum number of resluts
		 */
		private var _maxResults:int = 5;
		
		/**
		 * @private
		 * security module to use for a request
		 */
		private var _security:ISecurity = null;
		
		/**
		 * constructor
		 */
		public function SearchEngine()
		{
		}
		
		/**
		 * reverse geocode a location
		 * 
		 * @param callback the callback function to wall when search ends. It must take a Vector.&lt;Address&gt; in parameter
		 * @param loc the location
		 */
		public function reverseGeocode(callback:Function, loc:Location):void {
			callback(new Vector.<Address>());
		}
		
		/**
		 * search with a querystring
		 * 
		 * @param callback the callback function to wall when search ends. It must take a Vector.&lt;Address&gt; in parameter
		 * @param queryString the queryString
		 */
		public function searchByQueryString(callback:Function, queryString:String):void {
			callback(new Vector.<Address>());
		}

		/**
		 * maximum number of results
		 * @default 5
		 */
		public function get maxResults():int
		{
			return _maxResults;
		}
		/**
		 * @private
		 */
		public function set maxResults(value:int):void
		{
			_maxResults = value;
		}

		/**
		 * Getter and setter of the security module to use for a request.
		 * Default value is null.
		 */
		public function get security():ISecurity {
			return this._security;
		}
		/**
		 * @private
		 */
		public function set security(value:ISecurity):void {
			this._security = value;
		}
	}
}