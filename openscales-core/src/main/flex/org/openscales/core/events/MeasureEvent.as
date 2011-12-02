package org.openscales.core.events
{
	import flash.events.Event;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.measure.IMeasure;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Unit;
	
	public class MeasureEvent extends OpenScalesEvent
	{
		private var _tool:IMeasure = null;
		
		/**
		 * Event type dispatched when the get feature info response has been received.
		 */
		public static const MEASURE_AVAILABLE:String="openscales.measureAvailable";
		public static const MEASURE_UNAVAILABLE:String="openscales.measureUnavailable";
		
		public function MeasureEvent(type:String, tool:IMeasure, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this._tool = tool;
			super(type, bubbles, cancelable);
		}

		public function get tool():IMeasure {
			return this._tool;
		}
		
		override public function clone():Event {
			return new MeasureEvent(this.type,this._tool,this.bubbles,this.cancelable);
		}
		
	}
}