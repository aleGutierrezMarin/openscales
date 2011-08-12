package org.openscales.core.handler.feature
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.Util;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.ICollection;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * DragFeature is use to drag a feature
	 * To use this handler, it's  necessary to add it to the map
	 * It dispatch FeatureEvent.FEATURE_DRAG_START and FeatureEvent.FEATURE_DRAG_STOP events
	 */
	public class DragFeatureHandler extends DragHandler
	{
		private var _featuresToMove:Vector.<Feature>;
		private var _startPixel:Pixel;
		private var _stopPixel:Pixel;
		private var _layerToMove:FeatureLayer;
		/**
		* The feature currently dragged
		* */
		private var _featureCurrentlyDragged:Feature=null;
		/**
		 * Array of features which are undraggabled and belongs to a
		 * draggable layers 
	 	* */	 
		 private var _undraggableFeatures:Vector.<Layer> = new Vector.<Layer>();	
		 /**
		 * Array of layers which allow dragging
		 * */
		 private var _draggableLayers:Vector.<Layer> = new Vector.<Layer>();
	 	/**
	 	 * Constructor class
	 	 * 
	 	 * @param map:Map Object 
	 	 * @param active:Boolean to active or deactivate the handler
	 	 * */
		public function DragFeatureHandler(map:Map=null, active:Boolean=false)
		{
			super(map, active);
		}
		/**
		 * This function is launched when the Mouse is down
		 */
		override  protected function onMouseDown(event:MouseEvent):void{
			var feature:Feature = event.target as Feature;
			if(feature != null && isSelectedFeature(feature)){
				_startPixel = new Pixel(this._layerToMove.mouseX,this._layerToMove.mouseY);
				feature.startDrag();
				_featureCurrentlyDragged = feature;
				this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAG_START,feature));
			}
		}
		/**
		 * This function is launched when the Mouse is up
		 */
		override protected function onMouseUp(event:MouseEvent):void{
		 	var feature:Feature = event.target as Feature;
		 	if(feature != null && _featureCurrentlyDragged == feature){
				_stopPixel = new Pixel(this._layerToMove.mouseX,this._layerToMove.mouseY);
				feature.stopDrag();
				_featureCurrentlyDragged = null;
				updateFeature(feature);
				this._layerToMove.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAG_STOP,feature));
				this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_EDITED_END,feature));
				this._layerToMove.redraw();
			}
		 }
		 /**
		 * This function is used to add an array of undraggable feature which belong to a draggable layer
		 * @param features:Array Array of feature to make undraggable
		 * */
		 public function addUndraggableFeatures(features:Array):void{
		 	for(var i:int=0;i<features.length;i++){
		 		addUndraggableFeature(features[i] as Feature);
		 	}
		 }
		/**
		 * This function is used to add an undraggable feature which belong to a draggable layer
		 * @param feature:Feature The feature to add
		 * */
		public function addUndraggableFeature(feature:Feature):void{
			var addFeature:Boolean=false;
			if(feature!=null){
				for each(var featureLayer:FeatureLayer in _draggableLayers){
					//The feature belongs to a draggable layers
					if(featureLayer.features.indexOf(feature)!=-1){
						addFeature=true;	
						break;
					}
				}
				if(addFeature){
					if(_undraggableFeatures.indexOf(feature)==-1){
						_undraggableFeatures.push(feature);
					}
				}
			}
		}
		/**
		 * This function add an array of  layers as draggabble layer
		 * @param layers: Array of  layer to add
		 * */
		public function addDraggableLayers(layers:Vector.<Layer>):void {
			var layer:Layer;
			for each(layer in layers) {
				if(layer is FeatureLayer)
					addDraggableLayer(layer as FeatureLayer);
			}
		}
		/**
		 * This function add a layers as draggabble layer
		 * @param layer:FeatureLayer the layer to add
		 * */
		public function addDraggableLayer(layer:FeatureLayer):void{
			if(layer!=null && _draggableLayers.indexOf(layer)==-1){
				_draggableLayers.push(layer);
			}
		}
		
		/**
		 * The selected features
		 */
		public function get featuresToMove():Vector.<Feature>{
			return this._featuresToMove;
		}
		public function set featuresToMove(value:Vector.<Feature>):void{
			this._featuresToMove = value;
		}
		
		/**
		 * The layer
		 */
		public function get layerToMove():FeatureLayer{
			return this._layerToMove;
		}
		public function set layerToMove(value:FeatureLayer):void{
			this._layerToMove = value;
		}
		
		/**
		 * Is the feature selected ?
		 */
		private function isSelectedFeature(myFeature:Feature):Boolean{
			
			for each(var fte:Feature in this.featuresToMove){
				if(fte == myFeature){
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Update the feature when moved
		 */
		private function updateFeature(feature:Feature):void{
			
			var targetFeature:Feature;
			var loc:Location;
			var pt:Point;
			var px:Pixel;
			var i:uint;
			
			if(feature is PointFeature){
				for each(targetFeature in this.featuresToMove){
					if(targetFeature == feature){
						loc = this.map.getLocationFromLayerPx(_stopPixel);
						targetFeature.geometry = new Point(loc.lon,loc.lat);
						targetFeature.x = 0;
						targetFeature.y = 0;
					}
				}
			}
			else if(feature is LineStringFeature){
				for each(targetFeature in this.featuresToMove){
					if(targetFeature == feature){
						var lineString:LineString;
						var tpIC:ICollection = targetFeature.geometry as ICollection;
						for(i=0; i<tpIC.componentsLength; i++){
							pt = tpIC.componentByIndex(i) as Point;
							px = this.map.getLayerPxFromLocation(new Location(pt.x, pt.y, pt.projSrsCode));
							loc = this.map.getLocationFromLayerPx(new Pixel(px.x + _stopPixel.x - _startPixel.x, px.y + _stopPixel.y - _startPixel.y));
							pt = new Point(loc.lon,loc.lat);
							if(i == 0)
								lineString = new LineString(new <Number>[pt.x,pt.y]);
							else{
								lineString.addPoint(pt.x,pt.y);
							}
						}
						targetFeature.geometry = lineString;
						targetFeature.x = 0;
						targetFeature.y = 0;
					}
				}
			}
			else if(feature is PolygonFeature){
				for each(targetFeature in this.featuresToMove){
					if(targetFeature == feature){
						var linearRing:LinearRing;
						var polygon:Polygon;
						var tpLR:LinearRing = (targetFeature.geometry as Polygon).componentByIndex(0) as LinearRing;
						for(i=0; i<tpLR.componentsLength; i++){
							pt = tpLR.componentByIndex(i) as Point;
							px = this.map.getLayerPxFromLocation(new Location(pt.x, pt.y, pt.projSrsCode));
							loc = this.map.getLocationFromLayerPx(new Pixel(px.x + _stopPixel.x - _startPixel.x, px.y + _stopPixel.y - _startPixel.y));
							pt = new Point(loc.lon,loc.lat);
							if(i == 0){
								linearRing = new LinearRing(new <Number>[pt.x,pt.y]);
								polygon = new Polygon(new <Geometry>[linearRing]);
							}
							else{
								linearRing.addPoint(pt.x,pt.y);
							}
						}
						targetFeature.geometry = polygon;
						targetFeature.x = 0;
						targetFeature.y = 0;
					}
				}
			}
		}
	}
}