package org.openscales.core.handler.feature.draw
{
	import flash.display.Sprite;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LabelFeature;
	import org.openscales.core.handler.feature.FeatureClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_SIMPLECLICK
	 */ 
	[Event(name="org.openscales.feature.simpleclick", type="org.openscales.core.events.FeatureEvent")]
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_DRAG_START
	 */ 
	[Event(name="org.openscales.feature.dragstart", type="org.openscales.core.events.FeatureEvent")]
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_DRAG_STOP
	 */ 
	[Event(name="org.openscales.feature.dragstop", type="org.openscales.core.events.FeatureEvent")]
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_DELETING
	 */ 
	[Event(name="org.openscales.feature.deleting", type="org.openscales.core.events.FeatureEvent")]
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_EDITED_END
	 */ 
	[Event(name="org.openscales.feature.editedend", type="org.openscales.core.events.FeatureEvent")]
	
	/**
	 * This handler is used for label edition
	 */
	public class EditLabelHandler extends AbstractEditHandler
	{
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
			var evt:FeatureEvent = new FeatureEvent(FeatureEvent.FEATURE_SIMPLECLICK, event.feature);
			this.map.dispatchEvent(evt);
		}
		
		/**
		 * Call on starting a selected label drag
		 */
		public function dragLabelStart(feature:Feature):void
		{
			feature.startDrag();
			this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAG_START,feature));
		}
		
		/**
		 * Call on stopping a selected label drag
		 */
		public function dragLabelStop(feature:Feature):void
		{
			feature.stopDrag();
			var px:Pixel = new Pixel(this._layerToEdit.mouseX,this._layerToEdit.mouseY);
			var loc:Location = this.map.getLocationFromMapPx(px);
			loc.reprojectTo(feature.projection);
			feature.geometry = new Point(loc.lon,loc.lat);
			feature.geometry.projection = loc.projection;
			feature.x = 0;
			feature.y = 0;
			this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAG_STOP,feature));
			this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_EDITED_END,feature));
			this._layerToEdit.redraw();
		}
	}
}