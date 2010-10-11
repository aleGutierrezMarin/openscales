package org.openscales.core.control
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.geometry.MultiPoint;
	
	/**
	 * Display an overview of the current map and position.
	 */	
	public class OverviewMap extends Control
	{
		private var _overviewMap:Map = null;
		private var _rectColor:uint = 0xFF0000;
		private var _newExtentColor:uint = 0x0000FF;
		
		private var _startDrag:Pixel = null;
		private var _extentLayer:FeatureLayer;
		private var _extentFeature:PolygonFeature = null;
		private var _newExtentFeature:PolygonFeature = null;
		private var _extentStyle:Style;
		private var _newExtentStyle:Style;
		
		public function OverviewMap(position:Pixel=null)
		{
			super(position);
			this.width
			this._overviewMap = new Map();
			this._overviewMap.size = new Size(100,100);
			this._extentLayer = new FeatureLayer("extentLayer");
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
					_drawExtent);
				this.map.removeEventListener(LayerEvent.BASE_LAYER_CHANGED,
					_drawExtent);
				this.removeEventListener(MouseEvent.MOUSE_WHEEL, forwardMouseWheelToMap);
				this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			super.map = value;
			if(value!=null) {
				this.map.addEventListener(MapEvent.MOVE_END,
					_drawExtent);
				this.map.addEventListener(LayerEvent.BASE_LAYER_CHANGED,
					_drawExtent);
				this._overviewMap.addEventListener(MouseEvent.MOUSE_WHEEL,
					forwardMouseWheelToMap);
				this._overviewMap.addEventListener(MouseEvent.MOUSE_DOWN,
					onMouseDown);
				this._overviewMap.addEventListener(MouseEvent.MOUSE_UP,
					onMouseUp);
			}
		}
		
		/**
		 * Forward the MouseWheel event to the map
		 * 
		 * @param event the event to forward to the map
		 */
		private function forwardMouseWheelToMap(event:MouseEvent):void {
			var zoom:Number = this.map.zoom;
			if(event.delta > 0) {
				zoom++;
				if(zoom > this.map.baseLayer.maxZoomLevel)
					return;
			} else {
				zoom--;
				if(zoom < this.map.baseLayer.minZoomLevel)
					return;
			}
			this.map.moveTo(this.map.center,zoom,false,false);
		}
		
		private function onMouseDown(event:MouseEvent):void {
			this._startDrag = new Pixel(this._overviewMap.mouseX,
				this._overviewMap.mouseY);
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			
		}
		
		private function pxToBound(px1:Pixel,px2:Pixel):Bounds {
			var left:Number;
			var right:Number;
			var top:Number;
			var bottom:Number;
			
			var loc1:Location = this._overviewMap.getLocationFromMapPx(px1);
			var loc2:Location = this._overviewMap.getLocationFromMapPx(px2);
			
			if(loc1.x>loc2.x) {
				left = loc2.x;
				right = loc1.x;
			} else {
				left = loc1.x;
				right = loc2.x;
			}
			if(loc1.y>loc2.y) {
				bottom = loc2.y;
				top = loc1.y;
			} else {
				top = loc1.y;
				bottom = loc2.y;
			}
			var bounds:Bounds = new Bounds(left,
				bottom,
				right,
				top,
				this._overviewMap.baseLayer.projection);
			return bounds;
		}
		
		private function onMouseUp(event:MouseEvent):void {
			this.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			var px:Pixel = new Pixel(this._overviewMap.mouseX,
									 this._overviewMap.mouseY);
			
			if(px.equals(this._startDrag)) {
				var loc:Location = this._overviewMap.getLocationFromMapPx(px);
				this.map.moveTo(loc.reprojectTo(this.map.baseLayer.projection));
			} else {
				var bounds:Bounds = pxToBound(px,this._startDrag);
				if(this.map.baseLayer.projection != this._overviewMap.baseLayer.projection)
					bounds.transform(this._overviewMap.baseLayer.projection,
									 this.map.baseLayer.projection);
				this.map.zoomToExtent(bounds);
			}
			
			this.cleanNewExtentFeature();
			this._startDrag = null;
		}
		
		private function cleanNewExtentFeature():void {
			if(this._newExtentFeature != null) {
				this._extentLayer.removeFeature(this._newExtentFeature);
				this._newExtentFeature.destroy();
				this._newExtentFeature = null;
			}
		}
		
		private function onMouseMove(event:MouseEvent):void {
			var px:Pixel = new Pixel(this._overviewMap.mouseX,
				this._overviewMap.mouseY);
			var bounds:Bounds = pxToBound(px,this._startDrag);
			if(this._newExtentFeature == null) {
				if(this._newExtentStyle == null) {
					this._newExtentStyle = new Style();
					this._newExtentStyle.rules[0] = new Rule();
					this._newExtentStyle.rules[0].symbolizers.push(new PolygonSymbolizer(new SolidFill(_newExtentColor,0.5),
						new Stroke(_newExtentColor,2)));
				}
				this._newExtentFeature = new PolygonFeature(bounds.toGeometry(),
					null,
					this._newExtentStyle);
				this._newExtentFeature.unregisterListeners();
				this._extentLayer.addFeature(this._newExtentFeature);
			} else {
				this._newExtentFeature.geometry = bounds.toGeometry();
				this._newExtentFeature.draw();
			}
		}
		
		/**
		 * set the overview rectangle color
		 * 
		 * @param color:uint the color
		 */
		public function set extentColor(value:uint):void {
			if(this._extentStyle == null) {
				this._extentStyle = new Style();
				this._extentStyle.rules[0] = new Rule();
				this._extentStyle.rules[0].symbolizers.push(new PolygonSymbolizer(new SolidFill(value,0.5),
					new Stroke(value,2)));
			} else {
				((this._extentStyle.rules[0].symbolizers[0] as PolygonSymbolizer).fill as SolidFill).color = value;
				((this._extentStyle.rules[0].symbolizers[0] as PolygonSymbolizer).stroke as Stroke).color = value;
			}
		}
		
		/**
		 * set color of the rectangle drawn by the user to change extent
		 * 
		 * @param color:uint the color
		 */
		public function set newExtentColor(value:uint):void {
			if(this._newExtentStyle == null) {
				this._newExtentStyle = new Style();
				this._newExtentStyle.rules[0] = new Rule();
				this._newExtentStyle.rules[0].symbolizers.push(new PolygonSymbolizer(new SolidFill(value,0.5),
					new Stroke(value,2)));
			} else {
				((this._newExtentStyle.rules[0].symbolizers[0] as PolygonSymbolizer).fill as SolidFill).color = value;
				((this._newExtentStyle.rules[0].symbolizers[0] as PolygonSymbolizer).stroke as Stroke).color = value;
			}
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
				if(this._overviewMap.baseLayer!=null) {
					this._overviewMap.removeLayer(this._extentLayer);
					this._overviewMap.removeLayer(this._overviewMap.baseLayer);
				}
				this._overviewMap.addLayer(layer,true);
				this._overviewMap.zoomToExtent(layer.maxExtent);
				this._overviewMap.addLayer(this._extentLayer);
			}
		}
		
		public function get baselayer():Layer {
			return this._overviewMap.baseLayer;
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
				this._overviewMap.addLayer(this._extentLayer);
			}
			if(this._extentStyle == null) {
				this._extentStyle = new Style();
				this._extentStyle.rules[0] = new Rule();
				this._extentStyle.rules[0].symbolizers.push(new PolygonSymbolizer(new SolidFill(_rectColor,0.5),
					new Stroke(_rectColor,2)));
			}
			this._drawExtent();
		}
		
		private function _drawExtent(event:Event=null):void {
			var _extent:Bounds = this.map.extent;
			
			if(this.map.baseLayer.projection != this._overviewMap.baseLayer.projection)
				_extent.transform(this.map.baseLayer.projection,
								  this._overviewMap.baseLayer.projection);
			
			this._extentLayer.projection = this._overviewMap.baseLayer.projection;
			if(this._extentFeature == null) {
				this._extentFeature = new PolygonFeature(_extent.toGeometry(),
					null,
					this._extentStyle);
				this._extentLayer.addFeature(this._extentFeature);
				this._extentFeature.unregisterListeners();
			}
			else {
				this._extentFeature.geometry = _extent.toGeometry();
				this._extentFeature.draw();
			}
		}
	}
}