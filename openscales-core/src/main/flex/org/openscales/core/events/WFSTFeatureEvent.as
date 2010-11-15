package org.openscales.core.events
{
	import org.openscales.core.feature.Feature;
	import org.openscales.geometry.basetypes.Bounds;
	
	/**
	 * Event related to the drawing action :
	 *
	 * In order to not mix all handler (pan, drawing...), this event can determine when you're drawing.
	 * So if there are problems with control (like zoomBox or selectBox), you can easily manage
	 * all different handlers.
	 **/
	public class WFSTFeatureEvent extends FeatureEvent
	{
		
		/**
		 * insert a feature
		 */
		public static const INSERT:String="openscales.wfst.insert";
		
		/**
		 * delete a feature
		 */
		public static const DELETE:String="openscales.wfst.delete";
		
		/**
		 * update a feature
		 */
		public static const UPDATE:String="openscales.wfst.update";
		
		/**
		 * insert a feature
		 */
		public static const LOCKED:String="openscales.wfst.locked";
		
		
		public function WFSTFeatureEvent(type:String,feature:Feature,ctrlStatus:Boolean = false,bubbles:Boolean=false,cancelable:Boolean=false,bounds:Bounds = null)
		{
			super(type,feature,ctrlStatus, bubbles, cancelable,bounds);
		}
		
	}
}
