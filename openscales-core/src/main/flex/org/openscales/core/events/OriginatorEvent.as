package org.openscales.core.events
{
	import org.openscales.core.layer.originator.DataOriginator;
	
	/**
	 * Event related to an originator.
	 */
	public class OriginatorEvent extends OpenScalesEvent
	{
		/**
		 * @private
		 * Originator concerned by the event.
		 * @default null
		 */
		private var _originator:DataOriginator = null;
		
		/**
		 * @private
		 * Position of this originator in its container list.
		 * @default -1
		 */
		private var _position:Number = -1;
		
		/**
		 * Event type dispatched when an originator is added to the map.
		 */ 
		public static const ORIGINATOR_ADDED:String="openscales.addOriginator";
		
		/**
		 * Event type dispatched when an originator is removed form the map.
		 */
		public static const ORIGINATOR_REMOVED:String="openscales.removeOriginator";
		
		/**
		 * Constructor of the class OriginatorEvent.
		 * 
		 * @param type The type of event (mandatory).
		 * @param originator The DataOriginator concerned by the event (mandatory).
		 * @param bubbles Indicates whether an event is a bubbling event.
		 * @param cancelable Indicates whether the behavior associated with the event can be prevented.
		 */ 
		public function OriginatorEvent(type:String, originator:DataOriginator, position:Number=-1, bubbles:Boolean=false,cancelable:Boolean=false)
		{
			this._originator = originator;
			this._position = position;
			super(type, bubbles, cancelable);
		}
		
		// getter / setter
		
		/**
		 * Originator concerned by the event.
		 */
		public function get originator():DataOriginator {
			return this._originator;
		}
		
		/**
		 * @private
		 */
		public function set originator(originator:DataOriginator):void {
			this._originator = originator;	
		}

		/**
		 * Position of this originator in its container list.
		 */
		public function get position():Number {
			return this._position;
		}
		
		/**
		 * @private
		 */
		public function set position(value:Number):void {
			this._position = value;	
		}

	}
}