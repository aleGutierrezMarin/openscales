package org.openscales.core.events
{
	import flash.events.Event;
	
	/**
	 * Event related to a search.
	 */
	public class SearchEvent extends OpenScalesEvent
	{
		/**
		 * Event type dispatched when a completion search is finished.
		 */ 
		public static const AUTOCOMPLETE_END:String="openscales.autocompletesearch";
		
		/**
		 * Event type dispatched when an OpenLS search is finished.
		 */
		public static const SEARCH_END:String="openscales.openlssearch";
		
		
		public function SearchEvent(type:String, bubbles:Boolean=false,cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			var evt:SearchEvent = new SearchEvent(this.type,this.bubbles,this.cancelable);
			return evt;
		}
		
	}
}
