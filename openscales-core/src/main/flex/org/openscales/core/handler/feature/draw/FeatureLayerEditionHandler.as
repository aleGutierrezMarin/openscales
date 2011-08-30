package org.openscales.core.handler.feature.draw
{
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.handler.feature.FeatureClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * This handler is used to have an edition Mode 
	 * Which allow to modify all types of geometries
	 * */
	public class FeatureLayerEditionHandler extends Handler
	{
		//add
		private var _featuresToEdit:Vector.<Feature>;
		/**
		 *Layer to edit
		 * @private 
		 **/
		protected var _layerToEdit:VectorLayer=null;
		
		private var iEditPoint:IEditFeature=null; 
		private var iEditPath:IEditFeature=null;
		private var iEditPolygon:IEditFeature=null;
		
		private var _featureClickHandler:FeatureClickHandler=null;
		
		private var _drawContainer:Sprite=new Sprite();
		
		private var _editPoint:Boolean;
		private var _editPath:Boolean;
		private var _editPolygon:Boolean;
		//The type of the feature edited
		//0 point MultiPoint
		//1 linestring MultiLinestring
		//2 polygon MultiPolygon
		//-1 no modification at this moment
		
		private var _featureEditedType:int=-1;
		/**
		 * @private
		 * */
		private var _displayedvirtualvertice:Boolean=true;
		/**
		 * Handler of edition mode 
		 * @param editPoint to know if the edition of point is allowed
		 * @param editPath to know if the edition of path is allowed
		 * @param editPolygon to know if the edition of polygon is allowed
		 * */
		public function FeatureLayerEditionHandler(map:Map = null,layer:VectorLayer = null,active:Boolean = false,editPoint:Boolean = true,editPath:Boolean = true,editPolygon:Boolean = true)
		{
			// Handler click management
			this._featureClickHandler = new FeatureClickHandler(map,active);
			this._featureClickHandler.click = featureClick;
			this._featureClickHandler.doubleclick = featureDoubleClick;
			this._featureClickHandler.startDrag = dragVerticeStart;
			this._featureClickHandler.stopDrag = dragVerticeStop;
			
			//
			this._editPoint = editPoint;
			this._editPath = editPath;
			this._editPolygon = editPolygon;
			
			this.layerToEdit = layer;
			
			super(map,active);
		}
		
		/**
		 * drag vertice start function
		 */
		private function dragVerticeStart(event:FeatureEvent):void{
			
			var vectorfeature:PointFeature = (event.feature) as PointFeature;
			
			if(vectorfeature != null){
				
				var dragAlreadyStart:Boolean = false;
				if(!dragAlreadyStart && iEditPolygon != null){
					if(isSelectedFeature(iEditPolygon.findVirtualVerticeParent(vectorfeature))){
						iEditPolygon.dragVerticeStart(vectorfeature);
						_featureEditedType = 2;
						dragAlreadyStart = true;
					}
				}
				if(!dragAlreadyStart && iEditPath != null){
					if(isSelectedFeature(iEditPath.findVirtualVerticeParent(vectorfeature))){
						iEditPath.dragVerticeStart(vectorfeature);
						_featureEditedType = 1;
						dragAlreadyStart = true;
					}
				}
				if(!dragAlreadyStart && iEditPoint != null){
					if(isSelectedFeature(event.feature)){
						_featureEditedType = 0;
						iEditPoint.dragVerticeStart(vectorfeature);
					}
				}
				
				// events management
				this.map.removeEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
				this.map.removeEventListener(FeatureEvent.FEATURE_OUT,onFeatureOut);
				this.map.dispatchEvent(new FeatureEvent(FeatureEvent.EDITION_POINT_FEATURE_DRAG_START,vectorfeature));
			}
		}
		
		/**
		 * drag vertice stop function
		 */
		private function dragVerticeStop(event:FeatureEvent):void{
			
			var vectorfeature:PointFeature = (event.feature) as PointFeature;
			if(vectorfeature != null){
				
				switch(_featureEditedType){
					case 0:
						if(isSelectedFeature(vectorfeature))
							iEditPoint.dragVerticeStop(vectorfeature);
						break;
					case 1:
						if(isSelectedFeature(iEditPath.findVirtualVerticeParent(vectorfeature)))
							iEditPath.dragVerticeStop(vectorfeature);
						break;
					case 2:
						if(isSelectedFeature(iEditPolygon.findVirtualVerticeParent(vectorfeature)))
							iEditPolygon.dragVerticeStop(vectorfeature);
						break;
					default:
						break;
				}
			}
			
			_featureEditedType = -1;
			// events management
			this.map.addEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
			this.map.addEventListener(FeatureEvent.FEATURE_OUT,onFeatureOut);
		}
		
		/**
		 * feature click function
		 */
		private function featureClick(event:FeatureEvent):void{
			var vectorfeature:PointFeature = (event.feature) as PointFeature;
			if(vectorfeature != null){
				var clickAlreadyStart:Boolean = false;
				
				if(iEditPolygon != null){
					if(iEditPolygon.findVirtualVerticeParent(vectorfeature) != null){
						iEditPolygon.featureClick(event);
						clickAlreadyStart = true;
					}
				}
				if(!clickAlreadyStart && iEditPath != null){
					if(iEditPath.findVirtualVerticeParent(vectorfeature) != null){
						iEditPath.featureClick(event);
						clickAlreadyStart = true;
					}
				}
				if(!clickAlreadyStart && iEditPoint != null){
					if(isSelectedFeature(vectorfeature)){
						iEditPoint.featureClick(event);
					}
				}
				
				// events management
				this.map.addEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
				this.map.addEventListener(FeatureEvent.FEATURE_OUT,onFeatureOut);
			}
		}
		
		/**
		 * feature double click
		 */
		private function featureDoubleClick(event:FeatureEvent):void{
			var vectorfeature:PointFeature = (event.feature) as PointFeature;
			if(vectorfeature != null){
				var dblclickAlreadyStart:Boolean = false;
				
				if(iEditPolygon != null){
					if(iEditPolygon.findVirtualVerticeParent(vectorfeature) != null){
						iEditPolygon.featureDoubleClick(event);
						dblclickAlreadyStart = true;
					}
				}
				if(!dblclickAlreadyStart && iEditPath != null){
					if(iEditPath.findVirtualVerticeParent(vectorfeature) != null){
						iEditPath.featureDoubleClick(event);
						dblclickAlreadyStart = true;
					}
				}
				if(!dblclickAlreadyStart && iEditPoint != null){
					if(isSelectedFeature(vectorfeature)){
						iEditPoint.featureDoubleClick(event);
					}
				}
				
				// events management
				this.map.addEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
				this.map.addEventListener(FeatureEvent.FEATURE_OUT,onFeatureOut);
			}
		}
		
		/**
		 * Start the edition Mode
		 * */
		protected function editionModeStart():Boolean{
			if(_layerToEdit !=null)
			{
				//We refresh the edited feature just one time
				/* var alreadystarted:Boolean=false; */
				
				if(iEditPoint!=null) {
					(this.iEditPoint as AbstractEditHandler).map=this.map;
					iEditPoint.refreshEditedfeatures();
					/* alreadystarted=true;  */
				}
				if(iEditPath!=null){
					(this.iEditPath as AbstractEditHandler).map=this.map;
					/* 						if(!alreadystarted){ */
					iEditPath.refreshEditedfeatures();				
					/* 							alreadystarted=true;
					} */
				}
				if(iEditPolygon!=null){
					(this.iEditPolygon as AbstractEditHandler).map=this.map;
					/* 						if(!alreadystarted){ */
					iEditPolygon.refreshEditedfeatures();
					/* 							alreadystarted=true;
					} */
				}
			} 
			if(map!=null){
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_EDITION_MODE_START,_layerToEdit));
			}
			_layerToEdit.redraw(); 
			return true;
		}
		/**
		 * Stop the edition Mode
		 * */
		protected function editionModeStop():Boolean{
			if(_layerToEdit !=null)
			{
				
				
				if(iEditPath!=null)(this.iEditPath as AbstractEditHandler).editionModeStop();
				
				if(iEditPolygon!=null)(this.iEditPolygon as AbstractEditHandler).editionModeStop();
				
				if(iEditPoint!=null) (this.iEditPoint as AbstractEditHandler).editionModeStop();
				
			}
			if(map!=null)
			{
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_EDITION_MODE_END,_layerToEdit));
				
			}
			this._layerToEdit.removeFeature(AbstractEditCollectionHandler._pointUnderTheMouse);
			if(AbstractEditCollectionHandler._pointUnderTheMouse!=null){
				AbstractEditCollectionHandler._pointUnderTheMouse.destroy();
				AbstractEditCollectionHandler._pointUnderTheMouse=null;
			}
			_layerToEdit.redraw();
			return true;
		}
		
		/**
		 * This function is used to manage the mouse when the mouse is out of the feature
		 */
		private function onFeatureOut(evt:FeatureEvent):void{
			var vectorfeature:Feature = evt.feature;
			if((vectorfeature is PolygonFeature || vectorfeature is MultiPolygonFeature) && iEditPolygon != null && isSelectedFeature(vectorfeature))
				(iEditPolygon as AbstractEditCollectionHandler).onFeatureOut(evt);
			else if((vectorfeature is LineStringFeature || vectorfeature is MultiLineStringFeature) && iEditPath != null && isSelectedFeature(vectorfeature))
				(iEditPath as AbstractEditCollectionHandler).onFeatureOut(evt);
		}
		
		/**
		 * This function creates a virtual point under the mouse
		 */
		private function createPointUndertheMouse(evt:FeatureEvent):void{
			var vectorfeature:Feature = evt.feature;
			if((vectorfeature is PolygonFeature || vectorfeature is MultiPolygonFeature) && iEditPolygon != null && isSelectedFeature(vectorfeature))
				(iEditPolygon as AbstractEditCollectionHandler).createPointUndertheMouse(evt);
			else if((vectorfeature is LineStringFeature || vectorfeature is MultiLineStringFeature) && iEditPath != null && isSelectedFeature(vectorfeature))
				(iEditPath as AbstractEditCollectionHandler).createPointUndertheMouse(evt);
		}
		
		
		public  function refreshEditedfeatures(event:MapEvent=null):void{
			if(_layerToEdit !=null)
			{		
				//Collection treatment
				if(iEditPath!=null)iEditPath.refreshEditedfeatures(event);
				
				if(iEditPolygon!=null)iEditPolygon.refreshEditedfeatures(event);
				
				if(iEditPoint!=null) iEditPoint.refreshEditedfeatures(event);
				_layerToEdit.redraw();
			}
		}
		
		private function isSelectedFeature(myFeature:Feature):Boolean{
			
			for each(var fte:Feature in this.featuresToEdit){
				if(fte == myFeature){
					return true;
				}
			}
			return false;
		}
		
		/**
		 * @inherited
		 **/
		override protected function registerListeners():void {
			if(this.map){		
				this.map.addEventListener(MapEvent.MOVE_END,refreshEditedfeatures);
				this.map.addEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
				this.map.addEventListener(FeatureEvent.FEATURE_OUT,onFeatureOut);
			}
		}
		/**
		 * @inherited
		 * */
		override protected function unregisterListeners():void {
			if(this.map){	
				this.map.removeEventListener(MapEvent.MOVE_END,refreshEditedfeatures);
				this.map.removeEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
				this.map.addEventListener(FeatureEvent.FEATURE_OUT,onFeatureOut);
			}	
		}
		//getters && setters
		/**
		 * The layer concerned by the Modification
		 * */
		public function get layerToEdit():VectorLayer{
			return this._layerToEdit;
		}
		/**
		 * @private
		 * */
		public function set layerToEdit(value:VectorLayer):void{
			if(value!=null){
				this._layerToEdit=value;
				if(this._editPoint)//change
					iEditPoint = new EditPointHandler(map,active,value,_featureClickHandler,_drawContainer,false,_featuresToEdit);
				if(this._editPath)
					iEditPath = new EditPathHandler(map,active,value,_featureClickHandler,_drawContainer,false,_featuresToEdit);
				if(this._editPolygon)
					iEditPolygon = new EditPolygonHandler(map,active,value,_featureClickHandler,_drawContainer,false,_featuresToEdit);
			}
		}
		/**
		 *@inheritDoc 
		 * */
		override public function set map(value:Map):void{
			if(value!=null){
				super.map=value;
				if(iEditPoint!=null)(this.iEditPoint as AbstractEditHandler).map=this.map;
				if(iEditPath!=null)(this.iEditPath as AbstractEditHandler).map=this.map;
				if(iEditPolygon!=null)(this.iEditPolygon as AbstractEditHandler).map=this.map;
				this._featureClickHandler.map=value;
				this.map.addChild(_drawContainer);
			}
		}
		
		/**
		 *@inheritDoc 
		 * */
		override public function set active(value:Boolean):void{
			
			if(!this.active && value && map!=null)
			{
				if(iEditPoint!=null)  (this.iEditPoint as AbstractEditHandler).active=value;
				if(iEditPath!=null)(this.iEditPath as AbstractEditHandler).active=value;	
				if(iEditPolygon!=null)(this.iEditPolygon as AbstractEditHandler).active=value;
				this._featureClickHandler.active=value;
				editionModeStart();
				
			}
			else if(this.active && !value && map!=null){
				if(iEditPoint!=null)  (this.iEditPoint as AbstractEditHandler).active=value;
				if(iEditPath!=null)(this.iEditPath as AbstractEditHandler).active=value;	
				if(iEditPolygon!=null)(this.iEditPolygon as AbstractEditHandler).active=value;
				this._featureClickHandler.active=value;
				editionModeStop();
			}
			super.active=value;
		}
		
		public function get displayedvirtualvertice():Boolean{
			return this._displayedvirtualvertice;
		}
		public function set displayedvirtualvertice(value:Boolean):void{
			if(value!=this._displayedvirtualvertice){	
				this._displayedvirtualvertice=value;
				if(iEditPath!=null)	(iEditPath as AbstractEditCollectionHandler).displayedVirtualVertices=value;
				if(iEditPolygon!=null)(iEditPolygon as AbstractEditCollectionHandler).displayedVirtualVertices=value;
			}
		}
		
		
		public function get featuresToEdit():Vector.<Feature>{
			return this._featuresToEdit;
		}
		public function set featuresToEdit(value:Vector.<Feature>):void{
			if(this._layerToEdit != null && value != null){
				this._featuresToEdit = value;
				if(this._editPoint)
					iEditPoint = new EditPointHandler(map,active,_layerToEdit,_featureClickHandler,_drawContainer,false,value);
				if(this._editPath)
					iEditPath = new EditPathHandler(map,active,_layerToEdit,_featureClickHandler,_drawContainer,false,value);
				if(this._editPolygon)
					iEditPolygon = new EditPolygonHandler(map,active,_layerToEdit,_featureClickHandler,_drawContainer,false,value);
			}
		}
	}
}