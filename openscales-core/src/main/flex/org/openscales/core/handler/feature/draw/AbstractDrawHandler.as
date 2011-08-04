package org.openscales.core.handler.feature.draw
{	
	import org.openscales.core.Map;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.layer.FeatureLayer;

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
			this.drawLayer = drawLayer;
			super(map, active);
		}
		
		override public function set map(value:Map):void{
			if(value!=null){
				super.map = value;
				if (map.baseLayer!=null && this.drawLayer.projSrsCode!=null) {
					this.drawLayer.projSrsCode = this.map.projection;
					this.drawLayer.resolutions = this.map.baseLayer.resolutions;
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
	}
}

