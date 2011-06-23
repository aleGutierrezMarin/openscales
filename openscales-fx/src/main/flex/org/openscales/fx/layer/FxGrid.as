package org.openscales.fx.layer
{
	import org.openscales.core.layer.Grid;

	/**
	 * Abstract Grid Flex wrapper
	 */
	public class FxGrid extends FxHTTPRequest
	{
		public function FxGrid()
		{
			super();
		}
		
		public function set tileWidth(value:Number):void {
	    	if(this._layer != null)
	    		(this._layer as Grid).tileWidth = value;
	    }
	    
	    public function set tileHeight(value:Number):void {
	    	if(this._layer != null)
	    		(this._layer as Grid).tileHeight = value;
	    }

		/**
		 * @Deprecated
		 */
		public function set singleTile(value:Boolean):void {
			if(this._layer != null)
				(this._layer as Grid).tiled = !value;
		}
		
		/**
		 * Value to set if the layer is tiled
		 * 
		 */
		public function set tiled(value:Boolean):void{
			if(this._layer != null)
				(this._layer as Grid).tiled = value;
		}		
	}
}