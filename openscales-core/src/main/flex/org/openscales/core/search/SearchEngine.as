package org.openscales.core.search
{
	import org.openscales.core.search.result.Address;
	import org.openscales.geometry.basetypes.Location;

	public class SearchEngine
	{
		
		private var _maxResults:int = 5;
		
		public function SearchEngine()
		{
		}
		
		/**
		 * reverse geocode a location
		 * 
		 * @param callback the callback function to wall when search ends. It must take a Vector.<Address> in parameter
		 * @param loc the location
		 */
		public function reverseGeocode(callback:Function, loc:Location):void {
			callback(new Vector.<Address>());
		}
		
		/**
		 * search with a querystring
		 * 
		 * @param callback the callback function to wall when search ends. It must take a Vector.<Address> in parameter
		 * @param queryString the queryString
		 */
		public function searchByQueryString(callback:Function, queryString:String):void {
			callback(new Vector.<Address>());
		}

		/**
		 * maximum number of result
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

	}
}