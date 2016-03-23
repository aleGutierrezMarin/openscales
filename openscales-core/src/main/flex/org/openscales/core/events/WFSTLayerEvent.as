package org.openscales.core.events
{
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WFST;

	/**
	 * Event related to a layer.
	 */
	public class WFSTLayerEvent extends OpenScalesEvent
	{
		/**
		 * Layer concerned by the event.
		 */
		private var _layer:WFST = null;

		/**
		 * Event type dispatched when a layer is added to the map.
		 */ 
		public static const WFSTLAYER_ADDED:String="openscales.added";
		
		public static const WFSTLAYER_REMOVED:String="openscales.removed";
		
		public static const WFSTLAYER_UPDATE_MODEL:String="openscales.updated";
		
		public static const WFSTLAYER_TRANSACTION_SUCCES:String="openscales.transactionsucces";
		
		public static const WFSTLAYER_TRANSACTION_FAIL:String="openscales.transactionfail";
		
		public static const WFSTLAYER_READY:String="openscales.ready";


		public function WFSTLayerEvent(type:String, layer:WFST, bubbles:Boolean=false,cancelable:Boolean=false)
		{
			this._layer = layer;
			super(type, bubbles, cancelable);
		}
		
		/**
		 * Layer concerned by the event.
		 */
		public function get layer():WFST {
			return this._layer;
		}
		public function set layer(layer:WFST):void {
			this._layer = layer;	
		}



	}
}

