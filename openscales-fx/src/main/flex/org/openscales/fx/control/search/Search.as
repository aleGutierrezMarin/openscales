package org.openscales.fx.control.search
{
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.search.engine.SearchEngine;
	import org.openscales.core.search.result.Address;
	import org.openscales.fx.control.search.engine.FxSearchEngine;
	import skins.search.SearchDefaultSkin;
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
		private var _autocompleteEngine:SearchEngine = null;
		
		private var _map:Map = null;
		
		private var _active:Boolean = true;
		
		private var _minAutoCompleteInterval:Number = 300;
		
		private var _timer:Timer;
		private var _canSendRequest:Boolean = true;
		private var _buffer:String = null;
		
		/**
		 * constructor
		 */
		public function Search()
		{
			super();
			this._timer = new Timer(_minAutoCompleteInterval,1);
			this._timer.addEventListener(TimerEvent.TIMER, this.onTimerEnd);
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
			switch (event.keyCode){
				case Keyboard.UP:
				case Keyboard.DOWN:
				case Keyboard.END:
				case Keyboard.HOME:
				case Keyboard.PAGE_UP:
				case Keyboard.PAGE_DOWN:
				case Keyboard.TAB:
				case Keyboard.ESCAPE:
					break;
				case Keyboard.ENTER:
					this._buffer = null;
					if(this._searchEngine)
						this._searchEngine.searchByQueryString(this.onSearchResult,searchText.text);
					break;
				default:
					if(this._autocompleteEngine) {
						if(!searchText.text || searchText.text.length==0)
							return;
						if(!this._canSendRequest || searchText.text.length<3 ) {
							this._buffer = searchText.text;
							return;
						}
						
						this._timer.stop();
						this._buffer = null;
						this._canSendRequest = false;
						
						this._autocompleteEngine.searchByQueryString(this.onSearchResult,searchText.text);
						
						this._timer.reset();
						this._timer.start();
					}
			}
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
		
		private function onTimerEnd(event:TimerEvent):void
		{
			this._timer.stop();
			if(this._buffer && this._buffer.length>=3) {
				this._canSendRequest = false;
				if(this._autocompleteEngine)
					this._autocompleteEngine.searchByQueryString(this.onSearchResult,this._buffer);
				this._buffer = null;
				this._timer.reset();
				this._timer.start();
			} else {
				this._canSendRequest = true;
			}
			
		}
		
		/**
		 * Method than can be used to reverse geocode a location
		 * 
		 * @param loc the location to reverse geocode
		 */
		public function reverseGeocode(loc:Location):void {
			if(this._searchEngine)
				this._searchEngine.reverseGeocode(this.onSearchResult,loc);
		}
		/**
		 * search engine
		 */
		public function get autocompleteEngine():SearchEngine {
			return this._autocompleteEngine;
		}
		/**
		 * @private
		 */
		public function set autocompleteEngine(engine:SearchEngine):void {
			this._autocompleteEngine = engine;
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

		/**
		 * Minimum interval in milliseconds between two autocomplete request
		 * @default 300 milliseconds
		 */
		public function get minAutoCompleteInterval():Number
		{
			return _minAutoCompleteInterval;
		}
		/**
		 * @private
		 */
		public function set minAutoCompleteInterval(value:Number):void
		{
			_minAutoCompleteInterval = value;
			this._timer.stop();
			this._timer.reset();
			this._timer.start();
			this._timer.delay = _minAutoCompleteInterval;
		}


	}
}