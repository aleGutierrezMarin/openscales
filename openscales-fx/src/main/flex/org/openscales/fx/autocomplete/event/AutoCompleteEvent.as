package org.openscales.fx.autocomplete.event
{
	import flash.events.Event;
	/**
	 * <P>Auto complete event class.</P>
	 * stores custom data in the <code>data</code> variable.
	 */	
	public class AutoCompleteEvent extends Event{
		
		public var data:Object;
		
		public function AutoCompleteEvent(type:String, mydata:Object, bubbles:Boolean = false, cancelable:Boolean = false){
			
			super(type, bubbles,cancelable);
			
			data = mydata;
		}
		
		override public function clone():Event {
			return new AutoCompleteEvent(this.type, this.data, this.bubbles, this.cancelable);
		}
		
	}
}