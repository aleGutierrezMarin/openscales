package org.openscales.core.handler.feature.draw
{
	import flash.events.MouseEvent;
	
	import mx.managers.PopUpManager;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LabelFeature;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.popup.LabelPopup;
	import org.openscales.core.popup.Popup;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.LabelPoint;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;

	public class DrawLabelHandler extends AbstractDrawHandler
	{
		/**
		 * The layer in which we'll draw
		 */
		private var _drawLayer:VectorLayer = null;
		
		/**
		 * Single ID for label
		 */
		private var id:Number = 0;
		
		/**
		 * 
		 */
		private var _labelLocation:Location;
		
		/**
		 * 
		 */
		private var _style:Style = Style.getDefinedLabelStyle("Arial",12,0,false,false);
		
		/**
		 * Constructor
		 */
		public function DrawLabelHandler(map:Map=null, active:Boolean=false, drawLayer:VectorLayer=null)
		{
			super(map, active, drawLayer);
		}
		
		/**
		 * @inherits
		 */
		override protected function registerListeners():void
		{
			if (this.map){
				this.map.addEventListener(MouseEvent.CLICK, this.openPopup);
			}
		}
		
		/**
		 * @inherits
		 */
		override protected function unregisterListeners():void
		{
			if (this.map){
				this.map.removeEventListener(MouseEvent.CLICK, this.openPopup);
			}
		}
		
		protected function openPopup(event:MouseEvent):void
		{
			if (drawLayer != null)
			{
				var pixel:Pixel = new Pixel(this.map.mouseX, this.map.mouseY);
				this._labelLocation = this.map.getLocationFromMapPx(pixel);
				var labelPopup:LabelPopup = new LabelPopup(this.map,this.drawLabel);
			}
		}
		
		/**
		 * Create a label and draw it
		 */
		protected function drawLabel(str:String):void
		{
			if (str != null)
			{
				drawLayer.scaleX = 1;
				drawLayer.scaleY = 1;
				var labelPoint:LabelPoint = new LabelPoint(str,this._labelLocation.x, this._labelLocation.y);
				var middlePixel:Pixel = this.map.getMapPxFromLocation(this._labelLocation);
				var leftPixel:Pixel = new Pixel();
				var rightPixel:Pixel = new Pixel();
				leftPixel.x = middlePixel.x - labelPoint.label.width / 2;
				leftPixel.y = middlePixel.y + labelPoint.label.height / 2;
				rightPixel.x = middlePixel.x + labelPoint.label.width / 2;
				rightPixel.y = middlePixel.y - labelPoint.label.height / 2;
				var rightLoc:Location = this.map.getLocationFromMapPx(rightPixel);
				var leftLoc:Location = this.map.getLocationFromMapPx(leftPixel);
				labelPoint.updateBounds(leftLoc.x,leftLoc.y,rightLoc.x,rightLoc.y,this.map.projection);
				var feature:Feature = new LabelFeature(labelPoint,null,this._style);
				feature.name = "label." + id.toString();
				id++;
				drawLayer.addFeature(feature);
				feature.draw();
			}
			this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAWING_END,feature));
		}
		
		/**
		 * The style of the label
		 */
		public function get style():Style{
			
			return this._style;
		}
		public function set style(value:Style):void{
			
			this._style = value;
		}
	}
}