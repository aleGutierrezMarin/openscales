package org.openscales.core.handler.feature.draw
{
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LabelFeature;
	import org.openscales.core.handler.feature.FeatureClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.popup.LabelPopup;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	/**
	 * This handler is used for label edition
	 */
	public class EditLabelHandler extends AbstractEditHandler
	{
		private var _labelFeature:LabelFeature;
		
		/**
		 * EditLabelHandler
		 * This handler is used for edition on selected label such operation as modifying, dragging or deleting
		 */
		public function EditLabelHandler(map:Map = null,active:Boolean = false,layerToEdit:VectorLayer = null,featureClickHandler:FeatureClickHandler = null,drawContainer:Sprite = null,isUsedAlone:Boolean = true,featuresToEdit:Vector.<Feature> = null)
		{
			this.featureClickHandler = featureClickHandler;
			super(map,active,layerToEdit,featureClickHandler,drawContainer,isUsedAlone);
			this.featuresToEdit = featuresToEdit;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function featureDoubleClick(event:FeatureEvent):void
		{
			this._layerToEdit.removeFeature(event.feature);
			this._layerToEdit.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DELETING,event.feature));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function featureClick(event:FeatureEvent):void
		{
			this._labelFeature = (event.feature as LabelFeature);
			var labelPopup:LabelPopup = new LabelPopup(this.map,this.updateLabel);
		}
		
		/**
		 * Call on starting a selected label drag
		 */
		public function dragLabelStart(feature:Feature):void{
			
			feature.startDrag();
			this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAG_START,feature));
		}
		
		/**
		 * Call on stopping a selected label drag
		 */
		public function dragLabelStop(feature:Feature):void{
			
			feature.stopDrag();
			var px:Pixel = new Pixel(this._layerToEdit.mouseX,this._layerToEdit.mouseY);
			var lonlat:Location = this.map.getLocationFromMapPx(px);
			(feature as LabelFeature).lonlat = lonlat;
			feature.x = 0;
			feature.y = 0;
			this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAG_STOP,feature));
			this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_EDITED_END,feature));
			this._layerToEdit.redraw();
		}
		
		/**
		 * Callback
		 */
		protected function updateLabel(str:String):void
		{
			if(str != null)
			{
				this._labelFeature.labelPoint.label.text = str;
				this._labelFeature.draw();
			}
			else
			{
				this._layerToEdit.removeFeature(this._labelFeature);
				this._layerToEdit.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DELETING,this._labelFeature));
			}
		}
	}
}