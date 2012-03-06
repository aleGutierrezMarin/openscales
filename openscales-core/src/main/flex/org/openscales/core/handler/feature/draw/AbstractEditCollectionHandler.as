package org.openscales.core.handler.feature.draw
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LabelFeature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.State;
	import org.openscales.core.handler.feature.FeatureClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.ICollection;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;

	/** 
	 * @eventType org.openscales.core.events.LayerEvent.LAYER_EDITION_MODE_START
	 */ 
	[Event(name="openscales.layerEditionModeStart", type="org.openscales.core.events.LayerEvent")]
	
	/**
	 * This class is a handler used for Collection(Linestring Polygon MultiPolygon etc..) modification
	 * don't use it use EditPathHandler if you want to edit a LineString or a MultiLineString
	 * or EditPolygon 
	 * */
	public class AbstractEditCollectionHandler extends AbstractEditHandler
	{
		/**
		 * index of the feature currently drag in the geometry collection
		 * 
		 * */
		protected var indexOfFeatureCurrentlyDrag:int=-1;
		
		/**
		 * This singleton represents the point under the mouse during the dragging operation
		 * */
		public static var _inBetweenFeature:PointFeature=null;
		
		/**
		 * The point that is created under the mouse in edition mode.
		 */
		private var _dummyPointOnTheMouse:Feature;
		/**
		 * This tolerance is used to manage the point on the segments
		 * */
		 private var _detectionTolerance:Number=2;
		 /**
		 * This tolerance is used to discern Virtual vertices from point under the mouse
		 * */
		 private var _ToleranceVirtualReal:Number=10;
		/**
		 * We use a timer to manage the mouse out of a feature
		 */
		private var _timer:Timer = new Timer(500,1);
		/**
		 * To know if we displayed the virtual vertices of collection feature or not
		 **/
		 private var _displayedVirtualVertices:Boolean=true;
		/**
		 * This class is a handler used for Collection(Linestring Polygon MultiPolygon etc..) modification
	 	* don't use it use EditPathHandler if you want to edit a LineString or a MultiLineString
	 	* or EditPolygon 
	 	* */
		public function AbstractEditCollectionHandler(map:Map=null, active:Boolean=false, layerToEdit:VectorLayer=null, featureClickHandler:FeatureClickHandler=null,drawContainer:Sprite=null,isUsedAlone:Boolean=true)
		{
			super(map, active, layerToEdit, featureClickHandler,drawContainer,isUsedAlone);
			this.featureClickHandler=featureClickHandler;
			this._timer.addEventListener(TimerEvent.TIMER, deletepointUnderTheMouse);
		}
		/**
		 * This function is used for Polygons edition mode starting
		 * 
		 * */
		override public function editionModeStart():Boolean
		{
		 	/*for each(var vectorFeature:Feature in this._layerToEdit.features)
			{	
				if(vectorFeature.isEditable && vectorFeature.geometry is ICollection)
				{			
					//Clone or not
					if(displayedVirtualVertices)displayVisibleVirtualVertice(vectorFeature);
				}
			}
			if(_isUsedAlone)
			{
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_EDITION_MODE_START,this._layerToEdit));	
				//this.map.addEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
			}*/
			this.map.addEventListener(FeatureEvent.FEATURE_OVER, onFeatureOver);
			this.map.addEventListener(FeatureEvent.FEATURE_OUT, onFeatureOut);
 			return true;
		}
		
		 /**
		 * @inheritDoc 
		 * */
		  override public function editionModeStop():Boolean{
		  	//if the handler is used alone we remove the listener
		  	if(_isUsedAlone)
		 	//this.map.removeEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
		 	this._timer.removeEventListener(TimerEvent.TIMER, deletepointUnderTheMouse);		 	
		 	super.editionModeStop();
			this.map.removeEventListener(FeatureEvent.FEATURE_OVER, onFeatureOver);
			this.map.removeEventListener(FeatureEvent.FEATURE_OUT, onFeatureOut);
		 	return true;
		 } 
		  
		  private function onFeatureOver(evt:FeatureEvent):void
		  {
			  
			  if(!(evt.feature == _featureCurrentlyDrag) && (evt.feature is PointFeature) &&(this.isVirtualVertice(evt.feature as PointFeature) != -1))
			  {
				  evt.feature.originalStyle = evt.feature.style;
				  
				  if(evt.feature is PointFeature || evt.feature is MultiPointFeature) {
					  evt.feature.style = Style.getDefaultSelectedPointStyle();
				  } else if (evt.feature is LineStringFeature || evt.feature is MultiLineStringFeature) {
					  evt.feature.style = Style.getDefaultSelectedLineStyle();
				  } else if (evt.feature is LabelFeature) {
					  //evt.feature.style = Style.getDefinedLabelStyle(evt.feature.style.textFormat.font,(evt.feature.style.textFormat.size as Number),
					  //	0x0000FF,evt.feature.style.textFormat.bold,evt.feature.style.textFormat.italic);
				  } else {
					  evt.feature.style = Style.getDefaultSelectedPolygonStyle();
				  }
				  
				  //set feature style as a selected style
				  evt.feature.style.isSelectedStyle = true;
				  
				  evt.feature.draw();
			  }
		  }
		  
		  private function onFeatureOut(evt:FeatureEvent):void
		  {
			  if(!(evt.feature == _featureCurrentlyDrag) && (evt.feature is PointFeature) &&(this.isVirtualVertice(evt.feature as PointFeature) != -1))
			  {	
				  if(evt.feature.originalStyle != null) {
					  evt.feature.style = evt.feature.originalStyle;
				  } else {
					  if(evt.feature is PointFeature || evt.feature is MultiPointFeature) {
						  evt.feature.style = Style.getDefaultPointStyle();
					  } else if (evt.feature is LineStringFeature || evt.feature is MultiLineStringFeature) {
						  evt.feature.style = Style.getDefaultLineStyle();
					  } else if (evt.feature is LabelFeature) {
						  //evt.feature.style = Style.getDefinedLabelStyle(evt.feature.style.textFormat.font,(evt.feature.style.textFormat.size as Number),
						  //	0x0000FF,evt.feature.style.textFormat.bold,evt.feature.style.textFormat.italic);
					  } else {
						  evt.feature.style = Style.getDefaultPolygonStyle();
					  }
				  }
				  
				  //set feature style as a normal style
				  evt.feature.style.isSelectedStyle = false;
				  
				  evt.feature.draw();
			  }
		  }
		 
		 /**
		 * @inheritDoc 
		 * */
		 override public function dragVerticeStart(vectorfeature:PointFeature):void{
			if(vectorfeature!=null){
					var parentFeature:Feature=findVirtualVerticeParent(vectorfeature);
		 			if(parentFeature && parentFeature.geometry is ICollection){
						//We start to drag the vector feature
						vectorfeature.startDrag();
						//We see if the feature already belongs to the edited vector feature
						indexOfFeatureCurrentlyDrag=findIndexOfFeatureCurrentlyDrag(vectorfeature);
						if(vectorfeature!=AbstractEditCollectionHandler._inBetweenFeature)
							this._featureCurrentlyDrag=vectorfeature;
						else
							this._featureCurrentlyDrag=null;
						//we add the new mouseEvent move and remove the previous
						_timer.stop();
						this.map.mouseNavigationEnabled = false;
						this.map.panNavigationEnabled = false;
						this.map.zoomNavigationEnabled = false;
						this.map.keyboardNavigationEnabled = false;
						this.map.addEventListener(MouseEvent.MOUSE_MOVE,drawTemporaryFeature);
		 			}
			}
			
		 }
		 /**
		 * @inheritDoc 
		 * */
		override  public function dragVerticeStop(vectorfeature:PointFeature):void{
		 	if(vectorfeature!=null){
		 		//We stop the drag 
		 		vectorfeature.stopDrag();
		 		var parentFeature:Feature=findVirtualVerticeParent(vectorfeature);
		 		if(parentFeature && parentFeature.geometry is ICollection){
		 			var parentGeometry:ICollection=editionFeatureParentGeometry(vectorfeature,parentFeature.geometry as ICollection);
					var componentLength:Number=parentGeometry.componentsLength;
					this._layerToEdit.removeFeature(vectorfeature);
					this._featureClickHandler.removeControledFeature(vectorfeature);
		 			if(parentGeometry!=null){
		 				var lonlat:Location=this.map.getLocationFromMapPx(new Pixel(this._layerToEdit.mouseX,this._layerToEdit.mouseY)); //this.map.getLocationFromLayerPx(new Pixel(this._layerToEdit.mouseX,this._layerToEdit.mouseY));			
		 				var newVertice:Point=new Point(lonlat.lon,lonlat.lat,lonlat.projection);
		 				//if it's a real vertice of the feature
		 				if(vectorfeature!=AbstractEditCollectionHandler._inBetweenFeature)
							parentGeometry.replaceComponent(indexOfFeatureCurrentlyDrag/2,newVertice);
		 				else
							parentGeometry.addComponent(newVertice,(indexOfFeatureCurrentlyDrag+1)/2);
		 				if(displayedVirtualVertices)
							displayVisibleVirtualVertice(findVirtualVerticeParent(vectorfeature as PointFeature));	 
		 			} 	
		 		}
				parentFeature.draw();
		 	}
		 	//we add the new mouseEvent move and remove the MouseEvent on the draw Temporary feature
		 	this._layerToEdit.removeFeature(AbstractEditCollectionHandler._inBetweenFeature);	
			this.map.removeEventListener(MouseEvent.MOUSE_MOVE,drawTemporaryFeature);
			this.map.mouseNavigationEnabled = true;
			this.map.panNavigationEnabled = true;
			this.map.zoomNavigationEnabled = true;
			this.map.keyboardNavigationEnabled = true;
		 	this._featureCurrentlyDrag=null;
		 	if(AbstractEditCollectionHandler._inBetweenFeature!=null){
		 		this._layerToEdit.removeFeature(AbstractEditCollectionHandler._inBetweenFeature);
		 		this._featureClickHandler.removeControledFeature(AbstractEditCollectionHandler._inBetweenFeature);
		 		AbstractEditCollectionHandler._inBetweenFeature=null;
		 	}
		 	this._drawContainer.graphics.clear();
			vectorfeature.draw();
		 	vectorfeature=null;
		   _timer.stop();
		 	this._layerToEdit.redraw(true);
		 }
		 
		 /**
		 * @inheritDoc 
		 * */
		 override public function featureClick(event:FeatureEvent):void{
		 	var vectorfeature:PointFeature=event.feature as PointFeature;
		 	//We remove listeners and tempoorary point
		 	//This is a bug we redraw the layer with new vertices for the impacted feature
		 	//The click is considered as a bug for the moment	 	
		 	if(displayedVirtualVertices)
				displayVisibleVirtualVertice(findVirtualVerticeParent(vectorfeature as PointFeature));
		 	this._layerToEdit.removeFeature(AbstractEditCollectionHandler._inBetweenFeature);
		 	this._layerToEdit.removeFeature(vectorfeature);
		 	this._featureClickHandler.removeControledFeature(vectorfeature);
			vectorfeature.draw();
		 	vectorfeature=null;
			if(_isUsedAlone)
		 		this.map.removeEventListener(MouseEvent.MOUSE_MOVE,drawTemporaryFeature);
		 	this._featureCurrentlyDrag=null;
		 	//we remove it
		 	if(AbstractEditCollectionHandler._inBetweenFeature!=null){
		 		this._layerToEdit.removeFeature(AbstractEditCollectionHandler._inBetweenFeature);
		 		AbstractEditCollectionHandler._inBetweenFeature=null;
		 	}
		 	this._drawContainer.graphics.clear();
		 	_timer.stop();
		 	this._layerToEdit.redraw();
		 }
		 /**
		 * @inheritDoc 
		 * */
		 override public function featureDoubleClick(event:FeatureEvent):void{
		 	
		 	var vectorfeature:PointFeature=event.feature as PointFeature;
		 	
			//Avoid removing inbetween features
			if (this.isInbetweenVertice(vectorfeature) != -1)
			{
				return;
			}
		 	var parentFeature:Feature=findVirtualVerticeParent(vectorfeature);
		 	if(parentFeature && parentFeature.geometry is ICollection){
			 	var parentGeometry:ICollection=editionFeatureParentGeometry(vectorfeature,parentFeature.geometry as ICollection);
			 	var index:int=IsRealVertice(vectorfeature,parentGeometry);

			 	if(index!=-1){	 		
			 		 parentGeometry.removeComponent(parentGeometry.componentByIndex(index));
					 
					 //add
					 if(parentGeometry.componentsLength == 1){
						 parentGeometry.removeComponent(parentGeometry.componentByIndex(0));
						 this._layerToEdit.removeFeature(parentFeature);
					 }
					 
			 		 if(displayedVirtualVertices)
						 displayVisibleVirtualVertice(findVirtualVerticeParent(vectorfeature as PointFeature));
		 		}
			 	//we delete the point under the mouse 
			 	this._layerToEdit.removeFeature(AbstractEditCollectionHandler._inBetweenFeature);
			 	if(_isUsedAlone)
			 		this.map.removeEventListener(MouseEvent.MOUSE_MOVE,drawTemporaryFeature);
			 	this._featureCurrentlyDrag=null;
			 	if(AbstractEditCollectionHandler._inBetweenFeature!=null){
		 			this._layerToEdit.removeFeature(AbstractEditCollectionHandler._inBetweenFeature);
		 			AbstractEditCollectionHandler._inBetweenFeature=null;
			 	}
			 	this._drawContainer.graphics.clear();
			 	_timer.stop();
				vectorfeature.draw();
		 		this._layerToEdit.redraw(true);
				this.map.mouseNavigationEnabled = true;
				this.map.panNavigationEnabled = true;
				this.map.zoomNavigationEnabled = true;
				this.map.keyboardNavigationEnabled = true;
		 	}
		 }
		 

		 private function deletepointUnderTheMouse(evt:TimerEvent):void{
		 	//we hide the point under the mouse
		 
		   if(AbstractEditCollectionHandler._inBetweenFeature!=null)	AbstractEditCollectionHandler._inBetweenFeature.visible=false;
		 	_timer.stop();
		 }
		 
		 private function filterCallbackOnPointUnderTheMouse(item:Vector.<Feature>, index:int, vector:Vector.<Vector.<Feature>>):Boolean {
			 if (item[0] == this._dummyPointOnTheMouse)
				 return false
			return true;
		 }
		 
		 /**
		  * To draw the temporaries feature during drag Operation
		 * */
		 protected function drawTemporaryFeature(event:MouseEvent):void{
		 	
		 }
	
		 override public function refreshEditedfeatures(event:MapEvent=null):void{
		 	if(AbstractEditCollectionHandler._inBetweenFeature){
		 		this._layerToEdit.removeFeature(AbstractEditCollectionHandler._inBetweenFeature);
		 		this._featureClickHandler.removeControledFeature(AbstractEditCollectionHandler._inBetweenFeature);
		 		AbstractEditCollectionHandler._inBetweenFeature=null;
		 	}
		 }
		
		/**
		 * To find the index of feature currently dragged in it's geometry parent array
		 * @param vectorfeature:PointFeature the dragged feature
		 */
		public function findIndexOfFeatureCurrentlyDrag(vectorfeature:PointFeature):Number {
			
			var virtualVLength:Number = this._editionFeatureArray.length;
			for (var i:int=0; i < virtualVLength; ++i)
			{
				var editionfeaturegeom:Point=_editionFeatureArray[i][0].geometry as Point;
				if((vectorfeature.geometry as Point).x==editionfeaturegeom.x && (vectorfeature.geometry as Point).y==editionfeaturegeom.y)
					return i;
			}
			return -1;
		}
		
		 /**
		 * To know if a dragged point is a under the mouse or is a vertice
		 * if it's a point returns its index else returns -1
		 * @private
		 * */
		 private function IsRealVertice(vectorfeature:PointFeature,parentgeometry:ICollection):Number{
		 	
		 				if(parentgeometry){
							var index:Number=0;		
							var geom:Point=vectorfeature.geometry as Point;
							//for each components of the geometry we see if the point belong to it
							for(index=0;index<parentgeometry.componentsLength;index++){		
								var editionfeaturegeom:Point=parentgeometry.componentByIndex(index) as Point;
								if((vectorfeature.geometry as Point).x==editionfeaturegeom.x && (vectorfeature.geometry as Point).y==editionfeaturegeom.y)
									break;
							}
							if(index<parentgeometry.componentsLength) return index;
						}
		 			return -1;
		 }
		 
		 /**
		 * Return the index of the feature in the _inbetweenEditionFeatureArray Array or -1 otherwise
		 */
		public function isInbetweenVertice(vectorfeature:PointFeature):Number
		 {
			 var index:Number=0;		
			 var geom:Point=vectorfeature.geometry as Point;
			 //for each components of the geometry we see if the point belong to it
			 for(index=0;index<this._inbetweenEditionFeatureArray.length;index++){		
				 var editionfeaturegeom:Point=this._inbetweenEditionFeatureArray[index][0].geometry as Point;
				 if((vectorfeature.geometry as Point).x==editionfeaturegeom.x && (vectorfeature.geometry as Point).y==editionfeaturegeom.y)
					 break;
			 }
			 if(index<this._inbetweenEditionFeatureArray.length) return index;
			 return -1;
		 }
		
		/**
		 *  Return the index of the feature in the _editionFeatureArray Array or -1 otherwise
		 */
		public function isVirtualVertice(vectorfeature:PointFeature):Number
		{
			var index:Number=0;		
			var geom:Point=vectorfeature.geometry as Point;
			//for each components of the geometry we see if the point belong to it
			for(index=0;index<this._editionFeatureArray.length;index++){		
				var editionfeaturegeom:Point=this._editionFeatureArray[index][0].geometry as Point;
				if((vectorfeature.geometry as Point).x==editionfeaturegeom.x && (vectorfeature.geometry as Point).y==editionfeaturegeom.y)
					break;
			}
			if(index<this._editionFeatureArray.length) return index;
			return -1;
		}
		
		 /**
		 * This function find a parent Geometry of an edition feature
		 * @param point
		 * TODO: really needs to be rewrited
		 * */
		 public function editionFeatureParentGeometry(point:PointFeature,parentGeometry:ICollection):ICollection{
			if(point && parentGeometry){
				if(parentGeometry){
					var i:int;
					if(parentGeometry.componentsLength==0) return null;
					else{
					 if(parentGeometry.componentByIndex(0) is Point){
						for(i=0;i<parentGeometry.componentsLength;i++){
							if((point.geometry as Point).equals(parentGeometry.componentByIndex(i) as Point)){
								return parentGeometry;
							}	
						}
					}
					else{
						for(i=0;i<parentGeometry.componentsLength;i++){
							var geomParent:ICollection=editionFeatureParentGeometry(point,parentGeometry.componentByIndex(i) as ICollection);
							if(geomParent!=null){
								return geomParent;
							}
						}
					} 
					return parentGeometry as ICollection;
				}
				}
			}
			return null;
		 }
		
		 //getters && setters
		 /**
		 * Tolerance used for detecting  point
		 * */
		 public function get detectionTolerance():Number{
		 	return this._detectionTolerance;
		 }
		 public function set detectionTolerance(value:Number):void{	 	
		 	 this._detectionTolerance=value;
		 }
		 /**
		 * To know if we displayed the virtual vertices of collection feature or not
		 **/
		 public function get displayedVirtualVertices():Boolean{
		 	return this._displayedVirtualVertices;
		 }
		 /**
		 * @private
		 * */
		 public function set displayedVirtualVertices(value:Boolean):void{
		 	if(value!=this._displayedVirtualVertices){
		 		this._displayedVirtualVertices=value;
		 		refreshEditedfeatures();
		 	}
		 }
		 
		 
	}
}