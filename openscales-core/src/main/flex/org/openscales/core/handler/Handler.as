package org.openscales.core.handler
{
	import org.openscales.core.Map;

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
		
		private var _toggleHandlerActivity:Function = null;
		
		/**
		 * Constructor of the handler.
		 * @param map the map associated to the handler
		 * @param active boolean defining if the handler is active or not (default=false)
		 */
		public function Handler(map:Map = null, active:Boolean = false) {
			this.map = map;
			this.active = active;
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
				this._map.removeControl(this);
			}
			// Associate the handler and the input map
			this._map = value;
			if (this.map) {
				this.map.addControl(this);
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
		 * Callback function toggleHandlerActivity(active:Boolean):void
		 */
		public function get toggleHandlerActivity():Function
		{
			return _toggleHandlerActivity;
		}

		/**
		 * @private
		 */
		public function set toggleHandlerActivity(value:Function):void
		{
			_toggleHandlerActivity = value;
		}

		
	}
}
