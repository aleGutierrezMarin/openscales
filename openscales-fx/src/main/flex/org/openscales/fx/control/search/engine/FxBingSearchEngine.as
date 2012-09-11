package org.openscales.fx.control.search.engine
{
	import org.openscales.core.search.engine.BingSearchEngine;
	import org.openscales.core.search.engine.SearchEngine;
	
	public class FxBingSearchEngine extends FxSearchEngine
	{
		private var _key:String = null;
		
		public function FxBingSearchEngine()
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
			return new BingSearchEngine(this._key);
		}
	}
}