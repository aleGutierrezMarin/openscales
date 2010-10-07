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
			if (this._map) {
				this._map.addHandler(this);
			}
			// If the handler is active, register its listeners
			if (this._active) {
				this.registerListeners();
			}
			
			if(!this._map) {
				this._map.removeEventListener(HandlerEvent.HANDLER_ACTIVATION, onOtherHandlerActivation);
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
				if(_map){
					if(value){
						this._map.dispatchEvent(new HandlerEvent(HandlerEvent.HANDLER_ACTIVATION, this));
					} else {
						this._map.dispatchEvent(new HandlerEvent(HandlerEvent.HANDLER_DESACTIVATION, this));
					}
				}
			}
		}
		
		/**
		 * Getter and setter of the String defining the behaviour of the handler
		 */
		public function get behaviour():String{
			return this._behaviour;
		}
		public function set behaviour(value:String):void {
			this._behaviour = value;
		}
		
		/**
		 * Add the listeners to the associated map
		 */
		protected function registerListeners():void {
			this.map.addEventListener(HandlerEvent.HANDLER_ACTIVATION, onOtherHandlerActivation);
		}
		
		/**
		 * Remove the listeners to the associated map
		 */
		protected function unregisterListeners():void {
			
		}
		
		/**
		 * Callback use when another handler is activated
		 * This method has to be implemented in each handler to specify the functionnement
		 */
		protected function onOtherHandlerActivation(handlerEvent:HandlerEvent):void{
			
		}
		
	}
}
