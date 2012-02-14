 package org.openscales.core.handler.feature
{
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.feature.CustomMarker;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LabelFeature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.ICollection;
	import org.openscales.geometry.LabelPoint;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_DRAG_START
	 */ 
	[Event(name="openscales.feature.dragstart", type="org.openscales.core.events.FeatureEvent")]
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_DRAG_STOP
	 */ 
	[Event(name="openscales.feature.dragstop", type="org.openscales.core.events.FeatureEvent")]
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_EDITED_END
	 */ 
	[Event(name="openscales.feature.editedend", type="org.openscales.core.events.FeatureEvent")]
	
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
		private var _layerToMove:VectorLayer;
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
			
			var feature:Feature;
			if (event.target is TextField){
				feature = (event.target as TextField).parent as Feature;
			}else if(event.target.parent is CustomMarker)
			{
				feature = event.target.parent as Feature;
			}
			else
				feature = event.target as Feature;
			
			if (feature != null && feature.layer == this._layerToMove){
				this.map.mouseNavigationEnabled = false;
				this.map.panNavigationEnabled = false;
				this.map.zoomNavigationEnabled = false;
				this.map.keyboardNavigationEnabled = false;
				
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
			
			this.map.mouseNavigationEnabled = true;
			this.map.panNavigationEnabled = true;
			this.map.zoomNavigationEnabled = true;
			this.map.keyboardNavigationEnabled = true;
			if(this.map.hitTestPoint(event.stageX,event.stageY))
			{
				_stopPixel = new Pixel(this._layerToMove.mouseX,this._layerToMove.mouseY);
			}
			else
			{
				_stopPixel = _startPixel;
			}
			if(_featureCurrentlyDragged != null && _featureCurrentlyDragged.layer == this._layerToMove)
			{
				_featureCurrentlyDragged.stopDrag();
				updateFeature(_featureCurrentlyDragged);
				this._layerToMove.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAG_STOP,_featureCurrentlyDragged));
				this._layerToMove.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_EDITED_END,_featureCurrentlyDragged));
				this._layerToMove.redraw();
				_featureCurrentlyDragged = null;
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
				for each(var featureLayer:VectorLayer in _draggableLayers){
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
				if(layer is VectorLayer)
					addDraggableLayer(layer as VectorLayer);
			}
		}
		/**
		 * This function add a layers as draggabble layer
		 * @param layer:FeatureLayer the layer to add
		 * */
		public function addDraggableLayer(layer:VectorLayer):void{
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
		public function get layerToMove():VectorLayer{
			return this._layerToMove;
		}
		public function set layerToMove(value:VectorLayer):void{
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
				for each(targetFeature in this.layerToMove.features){
					if(targetFeature == feature){
						// TODO : getLocationFromMapPx? create getLocationFromLayerPx?
						loc = this.map.getLocationFromMapPx(_stopPixel);
						loc.reprojectTo(feature.projection);
						targetFeature.geometry = new Point(loc.lon,loc.lat);
						targetFeature.geometry.projection = loc.projection;
						targetFeature.x = 0;
						targetFeature.y = 0;
					}
				}
			}
			else if (feature is LabelFeature){
				for each(targetFeature in this.layerToMove.features){
					if (targetFeature == feature){
						loc = this.map.getLocationFromMapPx(_stopPixel);
						loc.reprojectTo(feature.projection);
						(targetFeature as LabelFeature).lonlat = loc;
						var leftPixel:Pixel = new Pixel();
						var rightPixel:Pixel = new Pixel();
						leftPixel.x = _stopPixel.x - (targetFeature as LabelFeature).labelPoint.label.width / 2;
						leftPixel.y = _stopPixel.y + (targetFeature as LabelFeature).labelPoint.label.height / 2;
						rightPixel.x = _stopPixel.x + (targetFeature as LabelFeature).labelPoint.label.width / 2;
						rightPixel.y = _stopPixel.y - (targetFeature as LabelFeature).labelPoint.label.height / 2;
						var rightLoc:Location = this.map.getLocationFromMapPx(rightPixel);
						var leftLoc:Location = this.map.getLocationFromMapPx(leftPixel);
						(targetFeature as LabelFeature).labelPoint.updateBounds(leftLoc.x,leftLoc.y,rightLoc.x,rightLoc.y,this.map.projection);
						targetFeature.x = 0;
						targetFeature.y = 0;
					}
				}
			}
			else if(feature is LineStringFeature){
				for each(targetFeature in this.layerToMove.features){
					if(targetFeature == feature){
						var lineString:LineString;
						var tpIC:ICollection = targetFeature.geometry as ICollection;
						for(i=0; i<tpIC.componentsLength; i++){
							pt = tpIC.componentByIndex(i) as Point;
							// TODO getMapPxFromLocation
							px = this.map.getMapPxFromLocation(new Location(pt.x, pt.y, pt.projection));
							// TODO getLocationFromMapPx?
							loc = this.map.getLocationFromMapPx(new Pixel(px.x + _stopPixel.x - _startPixel.x, px.y + _stopPixel.y - _startPixel.y));
							loc.reprojectTo(feature.projection);
							pt = new Point(loc.lon,loc.lat);
							pt.projection = loc.projection;
							if(i == 0)
							{
								lineString = new LineString(new <Number>[pt.x,pt.y]);
								lineString.projection = pt.projection;
							}
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
				for each(targetFeature in this.layerToMove.features){
					if(targetFeature == feature){
						var linearRing:LinearRing;
						var polygon:Polygon;
						var tpLR:LinearRing = (targetFeature.geometry as Polygon).componentByIndex(0) as LinearRing;
						for(i=0; i<tpLR.componentsLength; i++){
							pt = tpLR.componentByIndex(i) as Point;
							// TODO : getMapPxFromLocation?
							px = this.map.getMapPxFromLocation(new Location(pt.x, pt.y, pt.projection));
							// TODO : getLocationFromMapPx
							loc = this.map.getLocationFromMapPx(new Pixel(px.x + _stopPixel.x - _startPixel.x, px.y + _stopPixel.y - _startPixel.y));
							pt = new Point(loc.lon,loc.lat);
							pt.projection = loc.projection;
							if(i == 0){
								linearRing = new LinearRing(new <Number>[pt.x,pt.y]);
								linearRing.projection = pt.projection;
								polygon = new Polygon(new <Geometry>[linearRing]);
								polygon.projection = pt.projection;
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