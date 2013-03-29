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

	/**
	 * Add DiscreteFeature instance inside the specified Layer
	 * 
	 * <p>You can change the default radius</p>
	 * 
	 * <p>This class disptaches <code>FeatureEvent.FEATURE_DRAWING_START</code> and <code>FeatureEvent.FEATURE_DRAWING_END</code></p>
	 */ 
	public class DrawDiscreteCircleHandler extends AbstractDrawHandler
	{		
		/**
		 * The layer in which we'll draw
		 */
		private var _drawLayer:VectorLayer = null;
		
		private var _clickHandler:ClickHandler = new ClickHandler(null, true);
		
		/**
		 * A style to apply to the drawn circle. If null, no style will be applied;
		 */
		private var _style:Style;
		
		/**
		 * Default radius for the drawn circle (default in 3000 meter)
		 */ 
		public var circleRadius:Number = 10000;
		
		private var _savedCenter:Location;
		
		public function DrawDiscreteCircleHandler(map:Map=null, active:Boolean=false, drawLayer:org.openscales.core.layer.VectorLayer=null)
		{
			super(map, active, drawLayer);
			_clickHandler.click = this.drawCircle;
		}
		
		override protected function registerListeners():void{
			if (this.map) {
				_clickHandler.map = this.map;
				_clickHandler.active = true;
			}
		}
		
		override protected function unregisterListeners():void{
			if (this.map) {
				_clickHandler.active = false;
			}
		}
		
	
		/**
		 * Create a circle and draw it
		 */		
		protected function drawCircle(px:Pixel = null):void {
			
			if (drawLayer != null){
				var center:Location = map.getLocationFromMapPx(px);	
				var circleFeature:DiscreteCircleFeature = new DiscreteCircleFeature(center,circleRadius);
				
				var evt:FeatureEvent = new FeatureEvent(FeatureEvent.FEATURE_DRAWING_START,circleFeature);
				this.map.dispatchEvent(evt); // For backward compatibility				
				this.dispatchEvent(evt)
			
				drawLayer.scaleX=1;
				drawLayer.scaleY=1;
				if(_style) circleFeature.style = style;	
				drawLayer.addFeature(circleFeature);
				
				evt = new FeatureEvent(FeatureEvent.FEATURE_DRAWING_END,circleFeature);
				this.map.dispatchEvent(evt); // For backward compatibility
				this.dispatchEvent(evt);
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