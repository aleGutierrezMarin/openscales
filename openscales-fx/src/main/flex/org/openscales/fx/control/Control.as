package org.openscales.fx.control
{
	import flash.events.Event;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.IControl;
	import org.openscales.core.events.I18NEvent;
	import org.openscales.fx.FxMap;
	import org.openscales.geometry.basetypes.Pixel;
	
	import spark.components.SkinnableContainer;
	
	/**
	 * <p>Base class for all Flex based OpenScales control.</p>
	 * <p>Provide a Flex compatible implementation of IControl interface.</p>
	 */
	public class Control extends SkinnableContainer implements IControl
	{
		protected var _map:Map = null;
		protected var _fxMap:FxMap = null;
		protected var _active:Boolean = false;
		
		/**
		 * Store if this control have been initialized (Event.COMPLETE has been thrown)  
		 */
		protected var _isInitialized:Boolean = false;
		
		/**
		 * Store if the control has been added to the fxMap control list
		 */
		private var _isAddedToFxMapControlList:Boolean = false;
		
		public function Control()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete); 
		}
		
		/**
		 * The Flex side of the control has been created, so activate the control if needed and if the map has been set
		 */
		protected function onCreationComplete(event:Event):void {
			this._isInitialized = true;
			
			if((this.map) && (this.active == false)) {  
				this.active = true;
			}
		}    
		
		public function get fxMap():FxMap
		{
			return this._fxMap;
		}
		
		public function set fxMap(value:FxMap):void
		{
			this._fxMap = value;
			
			if(!this._isAddedToFxMapControlList){
				if(value){
					this._fxMap.addControlToFxMapControlsList(this);
					this._isAddedToFxMapControlList = true;
				}
			}
			
			this.fxMap.addEventListener(FlexEvent.CREATION_COMPLETE, onFxMapCreationComplete);
		}
		
		/**
		 * Flex Map wrapper initialization
		 */
		protected function onFxMapCreationComplete(event:Event):void {
			this.map = this._fxMap.map;
		}
		
		/**
		 * The current map linked to the control
		 */
		[Bindable]
		public function get map():Map {
			return this._map;
		}
		
		/**
		 * @private
		 */
		public function set map(value:Map):void 
		{
			// remove listener to old map if necessary
			this.active = false;
			
			this._map = value;
			
			if(this._map) //if not null
			{
				// Activate the control 
				this.active = true;
			}
			
			if(!this._isAddedToFxMapControlList){
				if(this.fxMap){
					this.fxMap.addControlToFxMapControlsList(this);
					this._isAddedToFxMapControlList = true;
				}
			}
		}
		
		/**
		 * indicates if the control is currently active or not
		 */
		public function get active():Boolean {
			return this._active;
		}
		
		/**
		 * @private
		 */
		public function set active(value:Boolean):void {
			
			if(value)
				this.activate();
			else
				this.desactivate();
		}
		
		/**
		 * Define the active status to true and
		 * add listeners to the current map to really active the control.
		 */
		public function activate():void
		{
			this._active = true;
			
			if(this._map)
			{
				this._map.addEventListener(I18NEvent.LOCALE_CHANGED,onMapLanguageChange);
			}
		}
		
		/**
		 * Define the active status to false and
		 * remove listeners from the current map (if defined) to really desactive the control.
		 */
		public function desactivate():void
		{
			this._active = false;
			
			if(this._map)
			{
				this.map.removeEventListener(I18NEvent.LOCALE_CHANGED,onMapLanguageChange);
			}
		}
		
		public function draw():void
		{
		}
		
		public function destroy():void {
			this._map = null;
			this._fxMap = null;
			var i:int = this.numElements;
			var elt:IVisualElement;
			for(i;i>0;--i) {
				elt = this.removeElementAt(0);
				if(elt is IControl)
					(elt as IControl).destroy();
			}
		}
		public function set position(px:Pixel):void
		{
			if (px != null) {
				this.x = px.x;
				this.y = px.y;
			}
		}
		
		public function get position():Pixel
		{
			return new Pixel(this.x, this.y);
		}
		
		/**
		 * to be overrided in sub classes
		 */
		public function onMapLanguageChange(event:I18NEvent):void {
			
		}
	}
}