package org.openscales.fx.control.search
{
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.search.SearchEngine;
	import org.openscales.core.search.result.Address;
	import org.openscales.fx.control.search.engine.FxSearchEngine;
	import org.openscales.fx.control.skin.SearchDefaultSkin;
	import org.openscales.geometry.basetypes.Location;
	
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	
	/**
	 * Search control
	 * Skinnable component, default skin is SearchDefaultSkin
	 */
	public class Search extends SkinnableComponent implements IHandler
	{
		/**
		 * Input field where users enter his search query
		 */
		[SkinPart(required="true")]
		public var searchText:TextInput;
		
		/**
		 * Arraycollection containing search results
		 */
		[SkinPart(required="true")]
		public var searchResult:ArrayCollection;
		
		private var _searchEngine:SearchEngine = null;
		
		private var _map:Map = null;
		
		private var _active:Boolean = true;
		
		/**
		 * constructor
		 */
		public function Search()
		{
			super();
			
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			if (instance == searchText) {
				searchText.addEventListener(KeyboardEvent.KEY_UP,this.autoComplete);
			}
		}
		/**
		 * @inheritDoc
		 */
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			if (instance == searchText) {
				searchText.removeEventListener(KeyboardEvent.KEY_UP,this.autoComplete);
			}
		}
		/**
		 * Method called when user enter text in searchText field
		 * 
		 * @param event the keyboard event
		 */
		protected function autoComplete(event:KeyboardEvent):void {
			if(this._searchEngine)
				this._searchEngine.searchByQueryString(this.onSearchResult,searchText.text);
		}
		/**
		 * Method called when results are returned by the search engine
		 * @param results vector of results
		 */
		protected function onSearchResult(results:Vector.<Address>):void {
			var i:uint = 0;
			var j:uint = results.length;
			searchResult.removeAll();
			for(;i<j;++i) {
				searchResult.addItem(results[i]);
			}
		}
		/**
		 * Method than can be used to reverse geocode a location
		 * 
		 * @param loc the location to reverse geocode
		 */
		public function reverseGeocode(loc:Location):void {
			this._searchEngine.reverseGeocode(this.onSearchResult,loc);
		}
		/**
		 * search engine
		 */
		public function get searchEngine():SearchEngine {
			return this._searchEngine;
		}
		/**
		 * @private
		 */
		public function set searchEngine(engine:SearchEngine):void {
			this._searchEngine = engine;
		}
		/**
		 * The map that is controlled by this handler
		 */
		public function get map():Map
		{
			return _map;
		}
		/**
		 * @private
		 */
		public function set map(value:Map):void
		{
			_map = value;
		}
		/**
		 * Usually used to register or unregister event listeners
		 */
		public function get active():Boolean
		{
			return _active;
		}
		/**
		 * @private
		 */
		public function set active(value:Boolean):void
		{
			_active = value;
		}


	}
}