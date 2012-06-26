package org.openscales.core.handler.mouse
{
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.handler.Handler;

	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * ClickHandler detects a click-actions on the map simple click, double
	 * click and drag and drop are managed.
	 *
	 * To use this handler, it's  necessary to add it to the map.
	 * It is a pure ActionScript class. Flex wrapper and components can be found
	 * in the openscales-fx module (same name prefixed by Fx).
	 */
	public class ClickHandler extends Handler
	{
		private var _click:Function = null;
		
		private var _doubleClick:Function = null;
		
		private var _drag:Function = null;
		
		private var _drop:Function = null;
				
		/**
		 * Pixel under the cursor when the mouse is down
		 */
		protected var _downPixel:Pixel = null;
		
		/**
		 *  Pixel under the cursor when the mouse is up
		 */
		protected var _upPixel:Pixel = null;
		
		/**
		 * Timer used to detect a double click without throwing a simple click
		 */
		private var _timer:Timer = new Timer(1000,1);
		
		/**
		 * Number of click since the beginning of the timer.
		 * It is used to decide if the user has done a simple or a double click.
		 */
		private var _clickNum:Number = 0;
		
		/**
		 * The position of the mouse for the first click of a double click
		 */
		private var _firstPointClick:Pixel = new Pixel(0,0);
		
		/**
		 * The position of the mouse for the second click of a double click 
		 */
		private var _secondPointClick:Pixel = new Pixel(Number.NEGATIVE_INFINITY,Number.NEGATIVE_INFINITY);
		
		/**
		 * CTRL is pressed ?
		 */
		protected var _ctrlKey:Boolean = false;
		
		/**
		 * SHIFT is pressed ?
		 */
		protected var _shiftKey:Boolean = false;
		
		protected var _dragging:Boolean = false;
			
		private var _doubleClickZoomOnMousePosition:Boolean = true;
		
		/**
		 * Constructor of the handler.
		 * @param map the map associated to the handler
		 * @param active Boolean defining if the handler is active or not
		 * @param doubleClickZoomOnMousePosition boolean defining if zoom on double click should be made toward mouse position
		 */
		public function ClickHandler(map:Map=null, active:Boolean=false, doubleClickZoomOnMousePosition:Boolean = true) {
			super(map, active);
			this._doubleClickZoomOnMousePosition = doubleClickZoomOnMousePosition;
		}

				
		/**
		 * Map coordinates (in its baselayer's SRS) of the point clicked (at the
		 * beginning of the drag)
		 */
		protected function startCoordinates():Location {
			return (this.map && this._downPixel) ? this.map.getLocationFromMapPx(this._downPixel) : null;
		}
		
		/**
		 * The select box, in pixels, defining by the pixel clicked at the
		 * beginning of the drag (mouseDown) and the pixel where the mouseUp
		 * event occurs.
		 * 
		 * @param evt the MouseEvent that defines the second point of the box
		 * @param buffer the buffer, in pixels, to use to enlarge the selection
		 * box (useful to improve the ergonomy)
		 */
		protected function selectionBoxPixels(p:Pixel, buffer:Number=0):Rectangle {
			if (! this._downPixel) {
				return null;
			}
			var left:Number = Math.min(this._downPixel.x,p.x) - buffer;
			var top:Number = Math.min(this._downPixel.y,p.y) - buffer;
			var w:Number = Math.abs(this._downPixel.x-p.x) + 2*buffer;
			var h:Number = Math.abs(this._downPixel.y-p.y) + 2*buffer;
			return new Rectangle(left, top, w, h);
		}
		
		/**
		 * The select box, in map's coordinates, defining by the point clicked
		 * at the beginning of the drag (mouseDown) and the point where the
		 * mouseUp event occurs.
		 * This function calls selectBoxPixels and convert the Rectangle of
		 * pixels in a  Bounds of map's coordinates.
		 * 
		 * @param evt the MouseEvent that defines the second point of the box
		 * @param buffer the buffer, in pixels (not in coordinates), to use to
		 * enlarge the selection box (useful to improve the ergonomy)
		 * */
		protected function selectionBoxCoordinates(p:Pixel, buffer:Number=0):Bounds {
			var rect:Rectangle = this.selectionBoxPixels(p, buffer);
			if ((! rect) || (! this.map)) {
				return null;
			}
			var bottomLeft:Location = this.map.getLocationFromMapPx(new Pixel(rect.left, rect.bottom));
			var topRight:Location = this.map.getLocationFromMapPx(new Pixel(rect.right, rect.top));
			return new Bounds(bottomLeft.lon, bottomLeft.lat, topRight.lon, topRight.lat, this.map.projection);
		}
		
		/**
		 * Add the listeners to the associated map
		 */
		override protected function registerListeners():void {
			// Listeners of the super class
			super.registerListeners();
			// Listeners of the internal timer
			// Listeners of the associated map
			if (this.map) {
				this.map.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown);
				this.map.addEventListener(MouseEvent.MOUSE_UP,this.mouseUp);
			}
		}
		
		/**
		 * Remove the listeners to the associated map
		 */
		override protected function unregisterListeners():void {
			// Listeners of the associated map
			if (this.map) {
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown);
				this.map.removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMove);
				this.map.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUp);
			}
			this._downPixel = null;
			this._upPixel = null;
			this._ctrlKey = false;
			this._shiftKey = false;
			this._dragging = false;
			// Listeners of the internal timer
			this._timer.stop();
			this._clickNum = 0;
			_firstPointClick = new Pixel(0,0);
			_secondPointClick = new Pixel(100,100);
			
			// Listeners of the super class
			super.unregisterListeners();
		}
		
		/**
		 * The MouseDown Listener
		 * @param evt the MouseEvent
		 */
		protected function mouseDown(evt:MouseEvent):void {
			if (evt) {
				this._downPixel = new Pixel(evt.currentTarget.mouseX, evt.currentTarget.mouseY);
				this.map.addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMove);
			}
		}
		
		/**
		 * The MouseMove Listener
		 * @param evt the MouseEvent
		 */
		protected function mouseMove(evt:MouseEvent):void {
			if (evt) {
				this._dragging = true;
				if (this.drag != null) {
					// Use the callback function for a drag click
					this.drag(evt);
				}
			}
		}
		
		/**
		 * MouseUp Listener
		 * @param evt the MouseEvent
 		 */
		protected function mouseUp(evt:MouseEvent):void {
			if (evt) {
				this.map.removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMove);
				if (this._downPixel != null) {
					this._timer.removeEventListener(TimerEvent.TIMER, onDoubleClickTimerTimeout);
					
					this._upPixel = new Pixel(evt.currentTarget.mouseX, evt.currentTarget.mouseY);
					this._ctrlKey = evt.ctrlKey;
					this._shiftKey = evt.shiftKey;
					
					if(this._dragging) {
						this._dragging = false;
						if (this.drop != null) {
							// Use the callback function for a drop click
							this.drop(this._upPixel);
						}	
					}
					// If it's a drag do nothing
					if ((Math.abs(this._downPixel.x - this._upPixel.x) > 10) || (Math.abs(this._downPixel.y - this._upPixel.y) > 10))
					{
						return;
					}
					
					// Register coordinates
					if (_clickNum == 0)
					{
						this._firstPointClick = new Pixel(evt.currentTarget.mouseX, evt.currentTarget.mouseY);
					} else {
						this._secondPointClick = new Pixel(evt.currentTarget.mouseX, evt.currentTarget.mouseY);
					}
					
					// If the click is too far away from the previous click
					if (this._clickNum != 0 && ((Math.abs(this._firstPointClick.x - this._secondPointClick.x) > 5) || (Math.abs(this._firstPointClick.y - this._secondPointClick.y) > 5)))
					{
						this._clickNum = 0;
						this._firstPointClick = this._secondPointClick;
					}
					
					this._clickNum++;
					if (this._clickNum == 1) {
						this._timer.reset();
						this._timer.start();
						this._timer.addEventListener(TimerEvent.TIMER, onDoubleClickTimerTimeout);
						var clickEvent:MapEvent = new MapEvent(MapEvent.MOUSE_CLICK, this.map);
						this.map.dispatchEvent(clickEvent);
						if (this.click != null) 
						{
							this.click(this._downPixel);
						}
					}else {
						this._clickNum = 0;
						this._timer.stop();
						if (this.doubleClick != null) 
						{
							this.doubleClick(this._downPixel);
						}
					}
				}
			}
		}
	
		/**
		 * reinit the 
		 */
		public function onDoubleClickTimerTimeout(event:TimerEvent):void
		{
			this._timer.stop();
			this._timer.removeEventListener(TimerEvent.TIMER, onDoubleClickTimerTimeout);
			this._clickNum = 0;
			_firstPointClick = new Pixel(0,0);
			_secondPointClick = new Pixel(Number.NEGATIVE_INFINITY,Number.NEGATIVE_INFINITY);
		}
		
		/**
		 * Call back method for doubleclick events
		 */ 
		private function onDoubleClick():void
		{
			// TODO refactor double click
			// If the handler is configured to zoom on mouse position
			if(this.doubleClickZoomOnMousePosition && this.map.mouseNavigationEnabled && this.map.doubleclickZoomEnabled){
				this.map.zoomBy(0.5, new Pixel(this.map.mouseX, this.map.mouseY));
			}
		}

		/**
		 * boolean specifying if zoom on double click should be made toward mouse position or not.
		 * Default is true.
		 */
		public function get doubleClickZoomOnMousePosition():Boolean
		{
			return _doubleClickZoomOnMousePosition;
		}

		/**
		 * @private
		 */ 
		public function set doubleClickZoomOnMousePosition(value:Boolean):void
		{
			_doubleClickZoomOnMousePosition = value;
		}

		/**
		 * Callback function click(evt:MouseEvent):void
		 * This function is called after a MouseUp event (in the case of a
		 * simple click)
		 */
		public function get click():Function
		{
			return _click;
		}

		/**
		 * @private
		 */
		public function set click(value:Function):void
		{
			_click = value;
		}

		/**
		 * Callback function doubleClick(evt:MouseEvent):void
		 * This function is called after a MouseUp event (in the case of a
		 * double click)
		 */
		public function get doubleClick():Function
		{
			return _doubleClick;
		}

		/**
		 * @private
		 */
		public function set doubleClick(value:Function):void
		{
			_doubleClick = value;
		}

		/**
		 * Callback (with one param of type MouseEvent)
		 * This function is called during a MouseMove event (in the case of a
		 * drag and drop click) the function is not called at the MouseDown time.
		 */
		public function get drag():Function
		{
			return _drag;
		}

		/**
		 * @private
		 */
		public function set drag(value:Function):void
		{
			_drag = value;
		}

		/**
		 * Callback function drop(evt:MouseEvent):void
		 * This function is called after a MouseUp event (in the case of a
		 * drag and drop click)
		 */
		public function get drop():Function
		{
			return _drop;
		}

		/**
		 * @private
		 */
		public function set drop(value:Function):void
		{
			_drop = value;
		}

		
	}
}
