package org.openscales.core.handler.feature.draw
{	
	import org.openscales.core.Map;
	import org.openscales.core.events.HandlerEvent;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.handler.HandlerBehaviour;
	import org.openscales.core.layer.FeatureLayer;
	import org.openscales.proj4as.ProjProjection;

	/**
	 * Handler base class for Drawing Handler
	 */	
	public class AbstractDrawHandler extends Handler
	{
		/**
		 * The layer concerned by the drawing Operation
		 * */
		private var _drawLayer:org.openscales.core.layer.FeatureLayer;
		/**
		 * Constructor 
		 * @param map Map Object
		 * @param active for handler activation
		 * @param drawLayer the layer concerned by the drawing operation
		 * Abstract class never use this constructor
		 * */
		public function AbstractDrawHandler(map:Map=null, active:Boolean=false, drawLayer:org.openscales.core.layer.FeatureLayer=null)
		{
			// AbstractDrawHandler is a draw handler
			this.behaviour = HandlerBehaviour.DRAW;
			this.drawLayer = drawLayer;
			super(map, active, this.behaviour);
		}
		
		override public function set map(value:Map):void{
			if(value!=null){
				super.map=value;
				 if(map.baseLayer!=null && this.drawLayer.projection!=null){
					this.drawLayer.projection=new ProjProjection(this.map.baseLayer.projection.srsCode);
					this.drawLayer.resolutions=this.map.baseLayer.resolutions;
				} 
			}
		}
		//Getters and setters
		
		/**
		 * The layer concerned by the drawing Operation
		 * */
		public function get drawLayer():FeatureLayer{
			return _drawLayer;
		}
		/**
		 * @private
		 * */
		public function set drawLayer(value:FeatureLayer):void{
			_drawLayer = value;
		}
		
		/**
		* Callback use when another handler is activated
		*/
		override protected function onOtherHandlerActivation(handlerEvent:HandlerEvent):void{
			// Check if it's not the current handler which has just been activated
			if(handlerEvent != null) {
				if(handlerEvent.handler != this) {
					if(handlerEvent.handler && handlerEvent.handler.behaviour == HandlerBehaviour.MOVE) {
						// A move handler has been activated
						this.active = false;
					} else if (handlerEvent.handler && handlerEvent.handler.behaviour == HandlerBehaviour.SELECT) {
						// A select handler has been activated
						this.active = false;
					} else if (handlerEvent.handler && handlerEvent.handler.behaviour == HandlerBehaviour.DRAW) {
						// A draw handler has been activated
						this.active = false;
					} else {
						// Do nothing
					}
				}
			}
		}
	}
}

