package org.openscales.core.events
{
	public class DisplayMeasureEvent extends OpenScalesEvent
	{
		public function DisplayMeasureEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}