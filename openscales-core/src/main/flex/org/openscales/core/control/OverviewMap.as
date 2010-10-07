package org.openscales.core.control
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.basetypes.Location;
	import org.openscales.basetypes.Pixel;
	import org.openscales.basetypes.Size;
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.osm.Mapnik;
	
	public class OverviewMap extends Control
	{
		private var _overviewMap:Map = null;
		private var _rectColor:uint = 0xFF0000;
		private var _newExtentColor:uint = 0x0000FF;
		private var _overview:Sprite = null;
		
		public function OverviewMap(position:Pixel=null)
		{
			super(position);
			this.width
			this._overviewMap = new Map();
			this._overviewMap.size = new Size(100,100);
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		public function set size(value:Size):void {
			if(!value)
				return;
			this._overviewMap.size = value;
		}
		
		override public function set width(value:Number):void {
			
		}
		
		override public function set height(value:Number):void {
			
		}
		
		override public function set map(value:Map):void {
			if (this.map != null) {
				this.map.removeEventListener(MapEvent.MOVE_END,
					updateRectFromMainMap);
				this.map.removeEventListener(LayerEvent.BASE_LAYER_CHANGED,
					updateRectFromMainMap);
				this.removeEventListener(MouseEvent.MOUSE_WHEEL, forwardMouseWheelToMap);
			}
			super.map = value;
			if(value!=null) {
				this.map.addEventListener(MapEvent.MOVE_END, updateRectFromMainMap);
				this.map.addEventListener(LayerEvent.BASE_LAYER_CHANGED, updateRectFromMainMap);
				this._overviewMap.addEventListener(MouseEvent.MOUSE_WHEEL, forwardMouseWheelToMap);
			}
		}
		
		/**
		 * Forward the MouseWheel event to the map
		 * 
		 * @param event the event to forward to the map
		 */
		private function forwardMouseWheelToMap(event:MouseEvent):void {
			var px:Pixel = new Pixel(this._overviewMap.mouseX,
									 this._overviewMap.mouseY);
			var loc:Location = this._overviewMap.getLocationFromMapPx(px);
			var zoom:Number = this.map.zoom;
			if(event.delta > 0) {
				zoom++;
			} else {
				zoom--;
			}
			this.map.moveTo(loc,zoom,false,false);
		}
		
		private function clic(event:MouseEvent):void {
			
		}
		
		private function updateRectFromMainMap(event:Event=null):void {
		}
		
		/**
		 * set the overview rectangle color
		 * 
		 * @param color:uint the color
		 */
		public function set rectColor(value:uint):void {
			this._rectColor = value;
		}
		
		/**
		 * set color of the rectangle drawn by the user to change extent
		 * 
		 * @param color:uint the color
		 */
		public function set newExtentColor(value:uint):void {
			_newExtentColor = value;
		}
		
		/**
		 * return the size of the overview
		 * 
		 * @return Size the size of the overview
		 */
		public function set OverViewSize(value:Size):void {
			this._overviewMap.size = value;
		}
		
		/**
		 * change the baselayer
		 * @param layer:Layer the new baselayer of the overview
		 */
		public function set baselayer(layer:Layer):void {
			if(this._overviewMap.baseLayer != layer) {
				if(this._overviewMap.baseLayer!=null)
					this._overviewMap.removeLayer(this._overviewMap.baseLayer);
				this._overviewMap.addLayer(layer,true);
				this._overviewMap.zoomToExtent(layer.maxExtent);
			}
		}
		
		/**
		 * add overlayer to the overviewmap
		 * @param layer:Layer the layer to add
		 */
		public function addLayer(layer:Layer):void {
			if(layer.isBaseLayer != false)
				return;
			this._overviewMap.addLayer(layer);
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			this.draw();
		}
		
		override public function draw():void {
			this.addChild(this._overviewMap);
			// by default it uses a mapnik baselayer 
			if(this._overviewMap.baseLayer == null) {
				var layer:Layer = new Mapnik("defaultbaselayer");
				this._overviewMap.addLayer(layer,true);
				this._overviewMap.zoomToExtent(layer.maxExtent);
			}
		}
	}
}