package org.openscales.core.control
{
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.openscales.core.Map;
	import org.openscales.core.utils.Util;
	import org.openscales.core.events.MapEvent;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * Control displaying the coordinates (Lon, Lat) of the current mouse position.
	 * Don't forget to initialize the position of the control, and the width
	 */
	public class MousePosition extends Control
	{
		/**
		 * Texfield wich displays coordinates
		 */
		private var _label:TextField = null;
		
		/**
		 * Text before coordinates in the label, which doesn't change.
		 */
		private var _prefix:String = "";
		
		/**
		 * the caracter between the lon and the lat
		 */
		private var _separator:String = ", ";
		
		/**
		 * Text after coordinates in the label, which doesn't change.
		 */
		private var _suffix:String = "";
		
		private var _numdigits:Number = 5;
		
		private var _granularity:int = 10;
		
		private var _lastXy:Pixel = null;
		
		private var _useDMS:Boolean = true;
		private var _localNSEW:String = "NSEW";
		
		/**
		 * The projection display in the label
		 */
		[Bindable]
		private var _displayProjection:String = "EPSG:4326";
		
		/**
		 * MousePosition constructor
		 * 
		 * @param position. If null, position will be (0,0)
		 */
		public function MousePosition(position:Pixel = null) {
			super(position);
			
			this.label = new TextField();
			this.label.width = 200;	
			var labelFormat:TextFormat = new TextFormat();
			labelFormat.size = 11;
			labelFormat.color = 0x0F0F0F;
			labelFormat.font = "Verdana";
			this.label.setTextFormat(labelFormat);
		}
		
		override public function draw():void {
			super.draw();
			this.addChild(label);
			this.redraw();
		}
		
		/**
		 * Display the coordinate where is the mouse
		 *
		 * @param evt
		 */
		public function redraw(evt:MouseEvent = null):void {
			var lonLat:Location;
			
			if (evt != null) {
				if (this.lastXy == null ||
					Math.abs(map.mouseX - this.lastXy.x) > this.granularity ||
					Math.abs(map.mouseY - this.lastXy.y) > this.granularity)
				{
					this.lastXy = new Pixel(map.mouseX, map.mouseY);
					return;
				}
				this.lastXy = new Pixel(map.mouseX, map.mouseY);
				lonLat = this.map.getLocationFromMapPx(this.lastXy);
			}
			
			if (lonLat == null) {
				lonLat = new Location(0,0,this.map.projection);
			}
			
			if (this._displayProjection) {
				lonLat = lonLat.reprojectTo(this._displayProjection);
			}
			
			var coord1:String, coord2:String;
			if (this.useDMS && (lonLat.projection == "EPSG:4326")) {
				coord1 = (lonLat.lon < 0) ? (Util.degToDMS(-lonLat.lon)+" "+this.localNSEW.charAt(3)) : (Util.degToDMS(lonLat.lon)+" "+this.localNSEW.charAt(2));
				coord2 = (lonLat.lat < 0) ? (Util.degToDMS(-lonLat.lat)+" "+this.localNSEW.charAt(1)) : (Util.degToDMS(lonLat.lat)+" "+this.localNSEW.charAt(0));
			} else {
				var digits:int = int(this.numdigits);
				coord1 = lonLat.lon.toFixed(digits);
				coord2 = lonLat.lat.toFixed(digits);
			}
			
			this.label.text = this.prefix
				+ coord1
				+ this.separator
				+ coord2
				+ this.suffix;
		}
		
		override public function set map(map:Map):void {
			if (this.map) {
				this.map.removeEventListener(MouseEvent.MOUSE_MOVE, this.redraw);
				this.map.removeEventListener(MapEvent.DRAG_START, this.deactivateDisplay);
				this.map.removeEventListener(MapEvent.MOVE_END, this.activateDisplay);
			}
			
			super.map = map;
			
			if (this.map) {
				this.map.addEventListener(MouseEvent.MOUSE_MOVE, this.redraw);
				this.map.addEventListener(MapEvent.DRAG_START, this.deactivateDisplay);
				this.map.addEventListener(MapEvent.MOVE_END, this.activateDisplay);
			}
		}
		
		/**
		 * Stop the update of coordinates. Useful while paning the map.
		 * 
		 * @param event
		 */
		private function deactivateDisplay(event:MapEvent):void {
			this.map.removeEventListener(MouseEvent.MOUSE_MOVE, this.redraw);
		}
		
		/**
		 * Start the update of coordinates.
		 * 
		 * @param event
		 */
		private function activateDisplay(event:MapEvent):void {
			this.map.addEventListener(MouseEvent.MOUSE_MOVE, this.redraw);
		}
		
		/**
		 * Getters &amp; setters
		 */
		public function get prefix():String {
			return _prefix;
		}
		public function set prefix(value:String):void {
			_prefix = value;
		}
		
		public function get separator():String {
			return _separator;
		}
		public function set separator(value:String):void {
			_separator = value;
		}
		
		public function get suffix():String {
			return _suffix;
		}
		public function set suffix(value:String):void {
			_suffix = value;
		}
		
		public function get numdigits():Number {
			return _numdigits;
		}
		public function set numdigits(value:Number):void {
			_numdigits = value;
		}
		
		public function get granularity():int {
			return _granularity;
		}
		public function set granularity(value:int):void {
			_granularity = value;
		}
		
		public function get lastXy():Pixel {
			return _lastXy;
		}
		public function set lastXy(value:Pixel):void {
			_lastXy = value;
		}
		
		public function get useDMS():Boolean {
			return this._useDMS;
		}
		public function set useDMS(value:Boolean):void {
			this._useDMS = value;
		}
		
		/**
		 * By default localNSEW == "NSEW", which means that the
		 * north id represented by N, the south by S, the east by E
		 * and the west by W.
		 * Use localNSEW = "NSEO" in french for instance.
		 */
		public function get localNSEW():String {
			return this._localNSEW;
		}
		public function set localNSEW(value:String):void {
			if (value.length == 4) {
				this._localNSEW = value;
			}
		}
		
		/**
		 * If null, the display projection used is the projection of the base layer.
		 * By default, the display projection is "EPSG:4326" 
		 */
		public function get displayProjection():String {
			return this._displayProjection;
		}
		public function set displayProjection(value:String):void {
			this._displayProjection = value;
		}
		
		public function get label():TextField {
			return this._label;
		}
		public function set label(value:TextField):void {
			this._label = value;
		}
		
	}
}
