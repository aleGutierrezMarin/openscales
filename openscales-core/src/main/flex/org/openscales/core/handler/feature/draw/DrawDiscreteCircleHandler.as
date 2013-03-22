package org.openscales.core.handler.feature.draw
{
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.feature.DiscreteCircleFeature;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;

	public class DrawDiscreteCircleHandler extends AbstractDrawHandler
	{		
		/**
		 * The layer in which we'll draw
		 */
		private var _drawLayer:VectorLayer = null;
		
		/**
		 * Single ID for point
		 */		
		private var id:Number = 0;
		
		private var _clickHandler:ClickHandler = new ClickHandler(null, true);
		
		/**
		 * 
		 */
		private var _style:Style = Style.getDefaultPointStyle();
		
		/**
		 * Default radius for the drawn circle (default in 3000 meter)
		 */ 
		public var circleRadius:Number = 10000;
		
		private var _savedCenter:Location;
		
		public function DrawDiscreteCircleHandler(map:Map=null, active:Boolean=false, drawLayer:org.openscales.core.layer.VectorLayer=null)
		{
			super(map, active, drawLayer);
		}
		
		override protected function registerListeners():void{
			if (this.map) {
				//this.map.addEventListener(MapEvent.MOUSE_CLICK, this.drawPoint);
				_clickHandler.map = this.map;
				_clickHandler.active = true;
				_clickHandler.click = this.drawCircle;
			}
		}
		
		override protected function unregisterListeners():void{
			if (this.map) {
				//this.map.removeEventListener(MapEvent.MOUSE_CLICK, this.drawPoint);
				_clickHandler.active = false;
			}
		}
		
	
		/**
		 * Create a point and draw it
		 */		
		protected function drawCircle(px:Pixel = null):void {
			//We draw the point
			if (drawLayer != null){
				
				drawLayer.scaleX=1;
				drawLayer.scaleY=1;

				var center:Location = map.getLocationFromMapPx(px);		
				
				var circleFeature:DiscreteCircleFeature = new DiscreteCircleFeature(center,circleRadius);
				drawLayer.addFeature(circleFeature);
				this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAWING_END,circleFeature));
			}
		}
		
		/**
		 * The style of the point
		 */
		public function get style():Style{
			
			return this._style;
		}
		public function set style(value:Style):void{
			
			this._style = value;
		}
	}
}