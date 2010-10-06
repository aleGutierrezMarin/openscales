package org.openscales.core.handler
{
	import flash.events.Event;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.HandlerEvent;

	/**
	 * Handler base class
	 */
	public class Handler implements IHandler
	{
		/**
		 * Map associated to the handler
		 */
		private var _map:Map;
		/**
		 * Boolean defining if the handler is active or not
		 */
		private var _active:Boolean;
		
		/**
		 * String defining the behaviour of the handler
		 */
		private var _behaviour:String=null;
		
		/**
		 * Callback function toggleHandlerActivity(active:Boolean):void
		 */
		private var _toggleHandlerActivity:Function = null;
		
		/**
		 * Constructor of the handler.
		 * @param map the map associated to the handler
		 * @param active boolean defining if the handler is active or not (default=false)
		 */
		public function Handler(map:Map = null, active:Boolean = false, behaviour:String = null) {
			this.map = map;
			this.active = active;
			this.behaviour = behaviour;
			this.map.addEventListener(HandlerEvent.HANDLER_ACTIVATION, onOtherHandlerActivation);
		}

		/**
		 * Getter and setter of the map associated to the handler
		 */
		public function get map():Map {
			return this._map;
		}
		public function set map(value:Map):void {
			// Is the input map the current map associated to the handler ?
			if (value == map) {
				return;
			}
			// If the handler is active, unregister its listeners
			if (this._active) {
				this.unregisterListeners();
			}
			// Remove the handler of its previous associated map
			if (this._map) {
				this._map.removeHandler(this);
			}
			// Associate the handler and the input map
			this._map = value;
			if (this.map) {
				this.map.addHandler(this);
			}
			// If the handler is active, register its listeners
			if (this._active) {
				this.registerListeners();
			}
		}

		/**
		 * Getter and setter of the boolean defining the activity of the handler
		 */
		public function get active():Boolean {
			return this._active;
		}
		public function set active(value:Boolean):void {
			// If the handler becomes active, register the listeners
			if (!this._active && value && (this._map != null)) {
				this.registerListeners();
			}
			// If the handler becomes inactive, unregister the listeners
			if (this._active && !value && (this._map != null)) {
				this.unregisterListeners();
			}
			// Update the property if needed
			if (this._active != value) {
				this._active = value;
				if (this.toggleHandlerActivity != null) {
					this.toggleHandlerActivity(this._active);
				}
			}
		}
		
		/**
		 * Getter and setter of the callback function used when the handler's
		 * activity changes
		 */
		public function get toggleHandlerActivity():Function {
			return this._toggleHandlerActivity;
		}
		public function set toggleHandlerActivity(value:Function):void {
			this._toggleHandlerActivity = value;
			
			//TODO pas au bon endroit
			if(value){
				this.map.dispatchEvent(new HandlerEvent(HandlerEvent.HANDLER_ACTIVATION, false, false, this.behaviour));
			} else {
				this.map.dispatchEvent(new HandlerEvent(HandlerEvent.HANDLER_DESACTIVATION, false, false, this.behaviour));
			}
		}
		
		/**
		 * Getter and setter of the String defining the behaviour of the handler
		 */
		public function get behaviour():String{
			return this._behaviour;
		}
		public function set behaviour(value:String):void {
			this.behaviour = value;
		}
		
		/**
		 * Add the listeners to the associated map
		 */
		protected function registerListeners():void {
		}
		
		/**
		 * Remove the listeners to the associated map
		 */
		protected function unregisterListeners():void {
		}
		
		/**
		 * Callback use when another handler is activated
		 */
		protected function onOtherHandlerActivation(handlerEvent:HandlerEvent):void{
			if(handlerEvent.behaviour == HandlerBehaviour.MOVE){
				// A move handler has been activated
			} else if (handlerEvent.behaviour == HandlerBehaviour.SELECT) {
				// A select handler has been activated
			} else if (handlerEvent.behaviour == HandlerBehaviour.DRAW) {
				// A draw handler has been activated
			} else {
				// Do nothing
			}
		}
		
	}
}
