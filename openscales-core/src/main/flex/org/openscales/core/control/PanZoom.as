
package org.openscales.core.control
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.ui.Button;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	/**
	 * Control showing some arrows to be able to pan the map and zoom in/out.
	 * This PanZoom class represents a component to add to the map.
	 * 
	 * @example The following code describe how to add a pan on a map : 
	 * 
	 * <listing version="3.0">
	 *   var theMap = Map();
	 *   theMap.addControl(new PanZoom());
	 * </listing>
	 */
	public class PanZoom extends Control
	{
		
		public static var X:int = 4;
		public static var Y:int = 4;
		
		/**
		 * @private
		 * The pan component to pan the map.
		 * @default null
		 */
		private var _pan:Pan = null;
		
		/**
		 * @private
		 * The zoom component to zoom in/out the map.
		 * @default
		 */
		private var _zoom:Zoom = null;
		
		/**
		 * Constructor for the PanZoom component
		 * 
		 * @param position The position of the component in the scene
		 */
		public function PanZoom(position:Pixel = null) {
			super(position);
			
			this._pan = new Pan(position);
			this._zoom = new Zoom(position);
		}
		
		/**
		 * @inherit
		 */
		override public function draw():void {
			super.draw();
			
			this.addChild(this._pan);	
			this.addChild(this._zoom);	
			
			this._pan.draw();
			this._zoom.draw();
		}
		
		/**
		 * @inherit
		 */
		override public function destroy():void {
			super.destroy();
			
			this._pan.destroy();
			this._zoom.destroy();
			
			this._pan = null;
			this._zoom = null;
		}
		
		
		//Getters and setters.
		
		/**
		 * 
		 * @inherit
		 * Get the existing map
		 * @param value
		 */
		override public function set map(map:Map):void {
			super.map = map;
			
			if(this._map != null){
				this._map.addControl(this._pan);
				this._map.addControl(this._zoom);
			}
		}
		
		/**
		 * The pan component to pan the map.
		 */
		public function get pan():Pan
		{
			return this._pan;
		}
		
		/**
		 * @private
		 */
		public function set pan(value:Pan):void
		{
			this._pan = value;
		}
		
		/**
		 * The zoom component to zoom in/out the map.
		 */
		public function get zoom():Zoom
		{
			return this._zoom;
		}
		
		/**
		 * @private
		 */
		public function set zoom(value:Zoom):void
		{
			this._zoom = value;
		}
	}
}

