package org.openscales.core.control
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.marker.WellKnownMarker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	/**
	 * Display an overview linked with the map.
	 * The map and the overview resolutions are linked with a ratio.
	 * This ratio will be kept when you zoom on the map.
	 * The overview map is a single layer
	 * 
	 * @author Viry Maxime
	 * 
	 */	
	public class OverviewMapRatio extends Control
	{
		
		/**
		 * @private
		 * Current map of the overvew
		 */
		private var _overviewMap:Map;
		
		/**
		 * @private
		 * Ratio between the overview resolution and the map resolution
		 * The ratio is MapResolution/OverviewMapResolution
		 */
		private var _ratio:Number = 1;
		
		/**
		 * @private
		 * Shape that will be displayed at the center of the overview map
		 * to show the location
		 */
		private var _centerPoint:Shape;
		
		
		/**
		 * Constructor of the overview map
		 * 
		 * @param position Position of the overview map
		 * 
		 */
		public function OverviewMapRatio(position:Pixel = null, layer:Layer = null)
		{
			super(position);
			this._overviewMap = new Map();
			this._overviewMap.size = new Size(100, 100);
			this.layer = layer;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 * @private
		 * Draw the overview map when added to the map 
		 */
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			this.mapChanged();
			this.draw();
			
			
		}
		
		/**
		 * Draw the overview map
		 */
		public override function draw():void {
			this.addChild(this._overviewMap);
		}
		
		/**
		 * Draw the center point
		 */
		private function drawCenter():void
		{
			if (this._centerPoint == null)
			{
				_centerPoint = new Shape();
			}
			_centerPoint.graphics.clear();
			_centerPoint.graphics.lineStyle(1, 0xFF0000);
			_centerPoint.graphics.moveTo(this.width/2 - 5, this.height/2);
			_centerPoint.graphics.lineTo(this.width/2 + 5, this.height/2);
			_centerPoint.graphics.moveTo(this.width/2, this.height/2 - 5);
			_centerPoint.graphics.lineTo(this.width/2, this.height/2 + 5);
			this._overviewMap.addChild(_centerPoint);
		}
		
		
		/**
		 * @private
		 * Compute the zoom level of the overviewMap according to the ratio setted
		 */
		private function computeZoomLevel():void
		{
			if (this.map != null && this._overviewMap.baseLayer != null)
			{
				// Compute the size ratio between the map and the voerview map
				var mapsRatio:Number =(this.map.size.w / this._overviewMap.size.w); 
				
				// Compute the reprojection factor for the resolution
				var unityReproj:Location = new Location(1, 1, this.map.baseLayer.projSrsCode);
				unityReproj = unityReproj.reprojectTo(this._overviewMap.baseLayer.projSrsCode);
				
				// Reproject and multiply by the maps ratio the resolution
				var targetResolution:Number = this.map.resolution * unityReproj.x* mapsRatio;
				
				
				// Find the best zoom to fit the resolutions ratio
				var bestZoomLevel:int = 0;
				var bestRatio:Number = 0;
				var i:int = Math.max(0, this._overviewMap.baseLayer.minZoomLevel);
				var len:int = Math.min(this._overviewMap.baseLayer.resolutions.length, this._overviewMap.baseLayer.maxZoomLevel+1);
				for (i; i < len; ++i)
				{
					var ratioSeeker:Number = this._overviewMap.baseLayer.resolutions[i] / targetResolution;
					if ( ratioSeeker > _ratio){
						ratioSeeker = _ratio/ratioSeeker;
					}
					if ( ratioSeeker > bestRatio){
						bestRatio = ratioSeeker;
						bestZoomLevel = i;
					}
				}
				
				this._overviewMap.zoom = bestZoomLevel;
				this._overviewMap.center = this.map.center.reprojectTo(this._overviewMap.baseLayer.projSrsCode);
			}
		}
		
		/**
		 * The size of the overview map
		 */
		public function set size(value:Size):void {
			if(!value)
				return;
			this._overviewMap.size = value;
			mapChanged();
		}
		
		/**
		 * The map used to compute the ratio
		 * It may be the main map of the application
		 */
		public override function set map(map:Map):void
		{
			if (this.map != null)
			{
				this.map.removeEventListener(MapEvent.MOVE_END,
					mapChanged);
				this.map.removeEventListener(MapEvent.LOAD_END,
					mapChanged);
				this._overviewMap.removeEventListener(MouseEvent.MOUSE_DOWN,
					onMouseDown);
			}
			super.map = map;	
			if (map != null)
			{	
				this.map.addEventListener(MapEvent.MOVE_END,
					mapChanged);
				this.map.addEventListener(MapEvent.LOAD_END,
					mapChanged);
				this._overviewMap.addEventListener(MouseEvent.MOUSE_DOWN,
					onMouseDown,true);
			}
		}
		
		/**
		 * @private
		 * Callback to recompute the zoom level of the overview when the zoom level of the map
		 * has changed 
		 */
		private function mapChanged(event:Event = null):void
		{
			computeZoomLevel();
			this.drawCenter();	
		}
		
		/**
		 * @private
		 * Callback to change the center of the general map when clicking on the minimap
		 * If the new center is out of the max extend of the base map the overview map center is not
		 * changed
		 */
		private function onMouseDown(event:MouseEvent):void {
			var mousePosition:Pixel =  new Pixel(this._overviewMap.mouseX, this._overviewMap.mouseY);
			var newCenter:Location = this._overviewMap.getLocationFromMapPx(mousePosition);
			var oldCenter:Location = this._overviewMap.center;
			
			this.map.center = newCenter.reprojectTo(this.map.baseLayer.projSrsCode);	
			//If the new center is valid change the center of the overview
			if (this.map.center == newCenter.reprojectTo(this.map.baseLayer.projSrsCode))
				{
					this._overviewMap.center = newCenter;
				}
		}
		
		/**
		 * The curent layer of the overview map
		 * 
		 * @param layer The layer of the overview
		 * 
		 */
		public function set layer(layer:Layer):void
		{
			if (layer != null)
			{
				_overviewMap.removeAllLayers();
				_overviewMap.baseLayer = layer;
				_overviewMap.addLayer(layer, true, true);
			}
		}
		
		/**
		 * 
		 * @private
		 */
		public function get layer():Layer
		{
			return _overviewMap.baseLayer;
		}
		
		/**
		 * Ratio between the overview resolution and the map resolution
		 * The ratio is MapResolution/OverviewMapResolution
		 * While setting a new ratio the oveview zoom level will be recomputed
		 * 
		 * @param ratio The curent ratio between the overview map and the map
		 */
		public function set ratio(ratio:Number):void
		{
			this._ratio = ratio;
		}
		
		/**
		 * 
		 * @private
		 */
		public function get ratio():Number
		{
			return _ratio;
		}
		
		/**
		 * The overview map resolution
		 */
		public function get resolution():Number
		{
			return _overviewMap.resolution;
		}
		
		/**
		 * The overview map
		 */
		public function get overviewMap():Map
		{
			return _overviewMap;
		}
		
		override public function set width(value:Number):void{
			_overviewMap.size = new Size(value, _overviewMap.size.h);
			mapChanged();
		}
		
		override public function get width():Number{
			return _overviewMap.size.w;
		}
		
		override public function set height(value:Number):void{
			_overviewMap.size = new Size(_overviewMap.size.w, value);
			mapChanged();
		}
		
		override public function get height():Number{
			return _overviewMap.size.h;
		}
	}
}