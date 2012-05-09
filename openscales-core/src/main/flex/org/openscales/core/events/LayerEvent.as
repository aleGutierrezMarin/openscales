package org.openscales.core.events
{
	import flash.events.Event;
	
	import mx.controls.Button;
	
	import org.openscales.core.layer.Layer;
	
	/**
	 * Event related to a layer.
	 */
	public class LayerEvent extends OpenScalesEvent
	{
		/**
		 * Layer concerned by the event.
		 */
		private var _layer:Layer = null;
		
		/**
		 * Opacity of the layer before of layer opacity change
		 */
		private var _oldOpacity:Number;
		
		/**
		 * Opacity of the layer after the layer opacity change
		 */
		private var _newOpacity:Number;
		
		/**
		 * Boolean saying if the layer is edited
		 */
		private var _isEdited:Boolean = false;
		
		/**
		 * Event type dispatched when a layer is added to the map.
		 * 
		 * @eventType openscales.addlayer
		 */ 
		public static const LAYER_ADDED:String="openscales.addlayer";
		
		/**
		 * Event type dispatched when a layer is removed form the map.
		 * 
		 * @eventType openscales.removelayer
		 */
		public static const LAYER_REMOVED:String="openscales.removelayer";
		
		/**
		 * Event type dispatched when a layer has been updated (FIXME : need to be confirmed).
		 * 
		 * @eventType openscales.changelayer
		 */
		public static const LAYER_CHANGED:String="openscales.changelayer";
		
		/**
		 * Event type dispatched when the current map resolution is within the layer's min/max range.
		 */
		public static const LAYER_IN_RANGE:String="openscales.layerinrange";
		
		/**
		 * Event type dispatched when the current map resolution is out of the layer's min/max range.
		 */
		public static const LAYER_OUT_RANGE:String="openscales.layeroutrange";
		
		/**
		 * Event type dispatched when the layer is initialized and ready to request remote data if needed
		 */		
		public static const LAYER_INITIALIZED:String="openscales.layerinitialized";
		
		/**
		 * Event type dispatched when property visible of layer is changed
		 */		
		public static const LAYER_VISIBLE_CHANGED:String="openscales.layerVisibilityChanged";
		
		/**
		 * Event type dispatched when loading is started
		 */		
		public static const LAYER_LOAD_START:String="openscales.layerloadstart";
		
		/**
		 * Event type dispatched when loading is completed
		 */		
		public static const LAYER_LOAD_END:String="openscales.layerloadend";
		
		/**
		 * Event type dispatched when the edition mode is started
		 * */
		public static const LAYER_EDITION_MODE_START:String="openscales.layerEditionModeStart";
		/**
		 * Event type dispatched when the edition mode is finished
		 * */
		public static const LAYER_EDITION_MODE_END:String="openscales.layerEditionModeEnd";
		
		/**
		 * Event type dispatched when the order of the layers is changed
		 * */
		public static const LAYER_CHANGED_ORDER:String="openscales.layerChangeOrder";
		
		/**
		 * Event type dispatched when the originators list of the layer is changed
		 * */
		public static const LAYER_CHANGED_ORIGINATORS:String="openscales.layerChangeOriginators";
		
		/**
		 * Event type dispatched when the opacity of the layer is changed
		 */
		public static const LAYER_OPACITY_CHANGED:String = "openscales.layerOpacityChanged";
		
		/**
		 * Event type dispatched when the layer is moved up in the display list
		 */
		public static const LAYER_MOVED_UP:String = "openscales.layerMovedUp";
		
		/**
		 * Event type dispatched when the layer is moved down in the display list
		 */
		public static const LAYER_MOVED_DOWN:String = "openscales.layerMovedDown";
		
		/**
		 * Event type dispatched when a polylayer has changed.
		 */ 
		public static const POLY_LAYER_CHANGED:String="openscales.polylayerchanged";
		
		/**
		 * Event type dispatched when the layer projection is changed
		 */ 
		public static const LAYER_PROJECTION_CHANGED:String="openscales.layerProjectionChanged";
		
		/**
		 * Event type dispatched when the layer displayInLayerManager is changed
		 */ 
		public static const LAYER_DISPLAY_IN_LAYERMANAGER_CHANGED:String="openscales.displayInLayerManagerChanged";
		
		/**
		 * Event type dispatched when the layer is edited
		 */ 
		public static const LAYER_EDITED:String="openscales.layeredited";
		
		/**
		 * Event type dispatched when the layer availability has changed
		 */ 
		public static const LAYER_AVAILABILITY_CHANGED:String="openscales.layeravailabilitychanged";
		
		
		public function LayerEvent(type:String, layer:Layer, bubbles:Boolean=false,cancelable:Boolean=false)
		{
			this._layer = layer;
			super(type, bubbles, cancelable);
			this._newOpacity = layer.alpha;
		}
		
		
		/**
		 * Layer concerned by the event.
		 */
		public function get layer():Layer {
			return this._layer;
		}
		public function set layer(layer:Layer):void {
			this._layer = layer;	
		}
		
		/**
		 * Opacity of the layer before of layer opacity change
		 */
		public function get oldOpacity():Number{
			return _oldOpacity;
		}
		
		/**
		 * @private
		 */
		public function set oldOpacity(value:Number):void
		{
			this._oldOpacity = value;
		}
		
		/**
		 * Opacity of the layer after of layer opacity change
		 */
		public function get newOpacity():Number{
			return _newOpacity;
		}
		
		/**
		 * @private
		 */
		public function set newOpacity(value:Number):void
		{
			this._newOpacity = value;
		}
		
		override public function clone():Event {
			var evt:LayerEvent = new LayerEvent(this.type,this.layer,this.bubbles,this.cancelable);
			evt.oldOpacity = this.oldOpacity;
			evt.newOpacity = this.newOpacity;
			return evt;
		}
		
		/**
		 * Boolean saying if the layer is edited
		 */
		public function get isEdited():Boolean
		{
			return this._isEdited;
		}
		
		/**
		 * @private
		 */
		public function set isEdited(value:Boolean):void
		{
			this._isEdited = value;
		}
		
	}
}

