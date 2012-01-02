package org.openscales.core.control
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * Display an overview of the current map and position.
	 */	
	public class OverviewMap extends Control
	{
		private var _overviewMap:Map = null;
		private var _rectColor:uint = 0xFF0000;
		private var _newExtentColor:uint = 0x0000FF;
		
		private var _startDrag:Pixel = null;
		private var _extentLayer:VectorLayer;
		private var _extentFeature:PolygonFeature = null;
		private var _newExtentFeature:PolygonFeature = null;
		private var _extentStyle:Style;
		private var _newExtentStyle:Style;
		
		public function OverviewMap(position:Pixel=null)
		{
			super(position);
			this._overviewMap = new Map();
			this._overviewMap.size = new Size(100,100);
			this._extentLayer = new VectorLayer("extentLayer");
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
				this.map.removeEventListener(MapEvent.CENTER_CHANGED,
					_drawExtent);
				this.map.removeEventListener(MapEvent.RESOLUTION_CHANGED,
					_drawExtent);
				this.map.removeEventListener(MapEvent.RESIZE,
					_drawExtent);
				this.removeEventListener(MouseEvent.MOUSE_WHEEL, forwardMouseWheelToMap);
				this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			super.map = value;
			if(value!=null) {
				this.map.addEventListener(MapEvent.CENTER_CHANGED,
					_drawExtent);
				this.map.addEventListener(MapEvent.RESOLUTION_CHANGED,
					_drawExtent);
				this.map.addEventListener(MapEvent.RESIZE,
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
			if(event.delta > 0) {
				this.map.zoomIn();
			} else {
				this.map.zoomOut();
			}
		}
		
		private function onMouseDown(event:MouseEvent):void {
			this._startDrag = new Pixel(this._overviewMap.mouseX,
				this._overviewMap.mouseY);
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			
		}
		
		private function pxToBound(firstpx:Pixel,secondpx:Pixel):Bounds {
			var left:Number;
			var right:Number;
			var top:Number;
			var bottom:Number;
			
			var loc1:Location = this._overviewMap.getLocationFromMapPx(firstpx);
			var loc2:Location = this._overviewMap.getLocationFromMapPx(secondpx);
			
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
				this._overviewMap.projection);
			return bounds;
		}
		
		private function onMouseUp(event:MouseEvent):void {
			if(this._startDrag==null)
				return;
			this.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			var px:Pixel = new Pixel(this._overviewMap.mouseX,
									 this._overviewMap.mouseY);
			
			if(px.equals(this._startDrag)) {
				var loc:Location = this._overviewMap.getLocationFromMapPx(px);
				this.map.center = loc.reprojectTo(this.map.projection);
			} else {
				var bounds:Bounds = pxToBound(px,this._startDrag);
				if (this.map.projection != this._overviewMap.projection) {
					bounds = bounds.reprojectTo(this.map.projection);
				}
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
		
		public function addLayer(value:Layer):void
		{
			this._overviewMap.addLayer(value);
			//we always need this layer above the others!
			this._overviewMap.removeLayer(this._extentLayer);
			this._overviewMap.addLayer(this._extentLayer);
		}
		
		public function removeLayer(value:Layer):void {
			this._overviewMap.removeLayer(value);
		}
		
		public function removeAllLayers():void {
			this._overviewMap.removeAllLayers();
			//we always need this layer!
			this._overviewMap.addLayer(this._extentLayer);
		}
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			this.draw();
		}
		
		override public function draw():void {
			this.addChild(this._overviewMap);
			if(this._overviewMap.layers.length==0) {
				var layer:Layer = new Mapnik("defaultbaselayer");
				this._overviewMap.projection=layer.projection;
				this._overviewMap.maxExtent = layer.maxExtent;
				this._overviewMap.minResolution = layer.minResolution;
				this._overviewMap.maxResolution = layer.maxResolution;
				this._overviewMap.addLayer(layer,true);
				//this._overviewMap.zoomToMaxExtent();
			}
			this._overviewMap.addLayer(this._extentLayer);
			
			if(this._extentStyle == null) {
				this._extentStyle = new Style();
				this._extentStyle.rules[0] = new Rule();
				this._extentStyle.rules[0].symbolizers.push(new PolygonSymbolizer(new SolidFill(_rectColor,0.5),
					new Stroke(_rectColor,2)));
			}
			this._drawExtent();
		}
		
		private function _drawExtent(event:Event=null):void {
			if(!this.map)
				return;
			if (this._extentFeature != null) {
				this._extentLayer.removeFeature(this._extentFeature);
			}
			var _extent:Bounds = this.map.extent;
			
			_extent = _extent.getIntersection(this._overviewMap.maxExtent);
			
			if(!_extent) {
				return;
			}
			
			if (_extent.projection != this._extentLayer.projection) {
				_extent = _extent.reprojectTo(this._extentLayer.projection);
			}
			
			this._extentFeature = new PolygonFeature(_extent.toGeometry(),null,this._extentStyle);
			this._extentLayer.addFeature(this._extentFeature);
			this._extentFeature.unregisterListeners();
		}
		
		/**
		 * The Actual projection of the overviewMap, the default value is Geometry.DEFAULT_SRS_CODE
		 */
		public function set projection(value:*):void
		{
			this._overviewMap.projection = value;
		}
		
		/**
		 * Private
		 */
		public function get projection():ProjProjection
		{
			return this._overviewMap.projection;
		}
	}
}