package org.openscales.core.handler.feature.draw
{
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.State;
	import org.openscales.core.handler.feature.FeatureClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;

	/**
	 * This Handler is used for point edition 
	 * its extends CollectionHandler
	 * */
	public class EditPointHandler extends AbstractEditHandler
	{
		/**
		 * EditPointHandler
		 * This handler is used for edition on selected point such operation as dragging or deleting
		 * @param map:Map object
		 * @param active:Boolean for handler activation
		 * @param layerToEdit:FeatureLayer 
		 * @param featureClickHandler:FeatureClickHandler handler only use it when you want to use this handler alone
		 * */
		public function EditPointHandler(map:Map = null,active:Boolean = false,layerToEdit:VectorLayer = null,featureClickHandler:FeatureClickHandler = null,drawContainer:Sprite = null,isUsedAlone:Boolean = true,featuresToEdit:Vector.<Feature> = null)
		{
			this.featureClickHandler = featureClickHandler;
			super(map,active,layerToEdit,featureClickHandler,drawContainer,isUsedAlone);
			this.featuresToEdit = featuresToEdit;
		}
		
		 /**
		 * @inheritDoc
		 */
		override public function featureDoubleClick(event:FeatureEvent):void{
			
			this._layerToEdit.removeFeature(event.feature);
			this._layerToEdit.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DELETING,event.feature));
		}
		
		 /**
		 * @inheritDoc
		 */
		override public function dragVerticeStart(vectorfeature:PointFeature):void{
			
			vectorfeature.startDrag();
			this._layerToEdit.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAG_START,vectorfeature));
		}
		
		 /**
		 * @inheritDoc
		 */
		override public function dragVerticeStop(vectorfeature:PointFeature):void{
			
			vectorfeature.stopDrag();
			
			// update vectorfeature ?
			var px:Pixel = new Pixel(this._layerToEdit.mouseX,this._layerToEdit.mouseY);
			var lonlat:Location = this.map.getLocationFromLayerPx(px);
			vectorfeature.geometry = new Point(lonlat.lon,lonlat.lat);
			vectorfeature.x = 0;
			vectorfeature.y = 0;
			this._layerToEdit.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAG_STOP,vectorfeature));
			this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_EDITED_END,vectorfeature));
			this._layerToEdit.redraw();
		}
		
	    /**
		 * @inheritDoc
		 */
		override public function editionModeStart():Boolean{
			
			if(this._layerToEdit != null){
				for each(var vectorFeature:Feature in this.featuresToEdit){
					if(vectorFeature.isEditable && vectorFeature is PointFeature){
						this._featureClickHandler.addControledFeature(vectorFeature);
						this._featureClickHandler.active = true;
					}
				}
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_EDITION_MODE_START,this._layerToEdit));
			}
		 	return true;
		 }
		
		/**
		 * @inheritDoc
		 */
		override public function refreshEditedfeatures(event:MapEvent = null):void{
			
		 	if(_layerToEdit != null && !_isUsedAlone){
				for each(var feature:Feature in this.featuresToEdit){
					if(feature is PointFeature && feature.isEditable){
						this._featureClickHandler.addControledFeature(feature);
					}
				}
		 	}
		}
	}
}