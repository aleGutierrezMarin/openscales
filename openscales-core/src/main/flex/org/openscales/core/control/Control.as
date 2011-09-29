package org.openscales.core.control
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.I18NEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.geometry.basetypes.Pixel;

	/**
	 * Control base class
	 */
	public class Control extends Sprite implements IControl
	{

		protected var _map:Map = null;
		protected var _active:Boolean = false;
		[Bindable]
		protected var _isReduced:Boolean = false;

		public function Control(position:Pixel = null) {

			if (position != null)
				this.position = position
			else					
				this.position = new Pixel(0,0);

			this.name = getQualifiedClassName(this).split('::')[1];
		}

		public function destroy():void {  
			if(this.map != null)
				this.map.removeEventListener(MapEvent.RESIZE, this.draw);

			this.map = null;
		}

		public function get map():Map {
			return this._map;   
		}

		public function set map(value:Map):void {
			if(this._map != null) {
				this._map.removeEventListener(MapEvent.RESIZE, this.resize);
				this.map.removeEventListener(I18NEvent.LOCALE_CHANGED,onMapLanguageChange);
			}
			this._map = value;
			if(this._map) {
				this._map.addEventListener(MapEvent.RESIZE, this.resize);
				this._map.addEventListener(I18NEvent.LOCALE_CHANGED,onMapLanguageChange);
			}	
		}

		public function resize(event:MapEvent):void {
			this.draw();   
		}

		public function get active():Boolean {
			return this._active;   
		}

		public function set active(value:Boolean):void {
			this._active = value;   
		}

		public function draw():void {
			// Reset before drawing
			this.graphics.clear();
			var i:int = this.numChildren;
			for(i;i>0;--i) {
				removeChildAt(0);
			}
		}

		public function set position(px:Pixel):void {
			if (px != null) {
				this.x = px.x;
				this.y = px.y;
			}
		}

		public function get position():Pixel {
			return new Pixel(this.x, this.y);
		}

		/**
		 * to be overrided in sub classes
		 */
		public function onMapLanguageChange(event:I18NEvent):void {
			
		}
		
		public function get isReduced():Boolean
		{
			return this._isReduced;
		}
		
		public function set isReduced(value:Boolean):void
		{
			this._isReduced = value;
		}
		
		public function toggleDisplay():void
		{	
			this._isReduced = !this._isReduced;
		}
	}
}

