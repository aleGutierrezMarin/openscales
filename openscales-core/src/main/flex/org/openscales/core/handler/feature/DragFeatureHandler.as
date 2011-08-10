package org.openscales.core.handler.feature
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.Util;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.core.layer.Layer;
	import org.openscales.geometry.Point;
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
		
		public function get featuresToMove():Vector.<Feature>{
			return this._featuresToMove;
		}
		public function set featuresToMove(value:Vector.<Feature>):void{
			this._featuresToMove = value;
		}
		
		public function get layerToMove():FeatureLayer{
			return this._layerToMove;
		}
		public function set layerToMove(value:FeatureLayer):void{
			this._layerToMove = value;
		}
		
		private function isSelectedFeature(myFeature:Feature):Boolean{
			
			for each(var fte:Feature in this.featuresToMove){
				if(fte == myFeature){
					return true;
				}
			}
			return false;
		}
		
		private function updateFeature(feature:Feature):void{
			
			if(feature is PointFeature){
				for each(var fte:Feature in this.featuresToMove){
					if(fte == feature){
						var lonlat:Location = this.map.getLocationFromLayerPx(_stopPixel);
						fte.geometry = new Point(lonlat.lon,lonlat.lat);
						fte.x = 0;
						fte.y = 0;
					}
				}
			}
		}
	}
}