package org.openscales.fx.control.search.engine
{
	import org.openscales.core.search.BingSearch;
	import org.openscales.core.search.SearchEngine;
	
	public class FxBingSearch extends FxSearchEngine
	{
		private var _key:String = null;
		
		public function FxBingSearch()
		{
			super();
		}
		
		/**
		 * Bing api key
		 */
		public function get key():String {
			return this._key;
		}
		/**
		 * @private
		 */
		public function set key(value:String):void {
			this._key = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get searchEngine():SearchEngine {
			return new BingSearch(this._key);
		}
	}
}