package org.openscales.core.layer
{
	import org.openscales.core.Map;
	import org.openscales.core.events.MapEvent;
	import org.openscales.geometry.basetypes.Bounds;
    /**
     *this class allow to have a layer with two layer inside , one layer is displayed according to scale 
     */
	public class SwitchLayers extends Layer
	{
		private var _firstLayer:Layer;
		
		private var _lastLayer:Layer;
		
		private var _isFirstLayer:Boolean;
		
		override public function set maxExtent(value:*):void {
			super.maxExtent = value;
			this._firstLayer.maxExtent = value as Bounds;
			this._lastLayer.maxExtent = value as Bounds;
		}
		
		override public function set map(map:Map):void {
			if(map != null){
			  this._firstLayer.map = map;
			  this._firstLayer.removeEventListenerFromMap();
			  this._lastLayer.map  = map;
			  this._lastLayer.removeEventListenerFromMap();
			  super.map = map;
			  if(this.map.resolution.reprojectTo(this.projSrsCode).value > this._resolutionToSwitch)
			  {
			  	_isFirstLayer = true;
			    this.addChild(this._firstLayer);
			  }
			  else{
			  	_isFirstLayer = false;
			    this.addChild(this._lastLayer);
			  }
			}
			
		}
		
		public function changeLayer():void{
		
			 if(_isFirstLayer== false && this.map.resolution.reprojectTo(this.projSrsCode).value > this._resolutionToSwitch )
			  {
			  	this.removeChild(this._lastLayer);
			  	_isFirstLayer = true;
			    this.addChild(this._firstLayer);
			  }
			  if(_isFirstLayer== true && this.map.resolution.reprojectTo(this.projSrsCode).value <= this._resolutionToSwitch ){
			  	this.removeChild(this._firstLayer);
			  	_isFirstLayer = false;
			    this.addChild(this._lastLayer);
			  }
			
		}
		
		override public function destroy():void {
			if(_isFirstLayer== false)
			{
			  this.removeChild(this._lastLayer);
            }else{
			  this.removeChild(this._firstLayer);
			}
			super.destroy();
		}
		
		override protected function onMapMove(e:MapEvent):void {
			if(e.zoomChanged) {
				changeLayer();
			}
			super.onMapMove(e);
		}
		
		
		override public function get projSrsCode():String {
			if (this.map == null) {
				  return this._firstLayer.projSrsCode;
			}
			if(this.map.resolution.reprojectTo(this.projSrsCode).value > this._resolutionToSwitch) {
			  return this._firstLayer.projSrsCode;
			} else {
			  return this._lastLayer.projSrsCode;
			}
		}
		
		override public function get minResolution():Number {
			if(this.map.resolution.reprojectTo(this.projSrsCode).value > this._resolutionToSwitch) {
			  return this._firstLayer.minResolution;
			} else {
			  return this._lastLayer.minResolution;
			}
			
		}
		
		override public function get maxResolution():Number {
			if(this.map.resolution.reprojectTo(this.projSrsCode).value > this._resolutionToSwitch) {
			  return this._firstLayer.maxResolution;
			} else {
			  return this._lastLayer.maxResolution;
			}
		}
		/*before this zoom the firtlayer will be visible
		  after this zoom the lastlayer will be visible
		  */
		  
		private var _resolutionToSwitch:Number;
		
		public function SwitchLayers(name:String,
								   firstLayer:Layer,
								   lastLayer:Layer,
								   resolutionToSwitch:Number)
		{
			
            this._firstLayer = firstLayer;
            this._lastLayer = lastLayer;	
            this._resolutionToSwitch = resolutionToSwitch;		
			super(name);
		}
		
		override protected function onMapResize(e:MapEvent):void {
			
			if(this.visible)
			{
			  if(this.map.resolution.reprojectTo(this.projSrsCode).value > this._resolutionToSwitch) {
				this._firstLayer.redraw();
			  }
			  else{
			  	this._lastLayer.redraw();
			  }
		    }
		}
	
		
		/**
		 * Clear the layer graphics
		 */
		override public function clear():void {
			
			if(this.map.resolution.reprojectTo(this.projSrsCode).value > this._resolutionToSwitch) {
				this._firstLayer.clear();
			  }
			  else{
			  	this._lastLayer.clear();
			  }
			
		}
		
		/**
		 * Reset layer data
		 */
		override public function reset():void {
			if(this.map.resolution.reprojectTo(this.projSrsCode).value > this._resolutionToSwitch) {
				this._firstLayer.reset();
			  }
			  else{
			  	this._lastLayer.reset();
			  }
		}
		/**
		 * Clear and draw, if needed, layer based on current data eventually retreived previously by moveTo function.
		 * 
		 * @return true if the layer was redrawn, false if not
		 */
		override public function redraw(fullRedraw:Boolean = true):void {
			if(this.map.resolution.reprojectTo(this.projSrsCode).value > this._resolutionToSwitch) {
				this._firstLayer.redraw();
			  }
			  else{
			  	this._lastLayer.redraw();
			  }
		}
		/**
		 * return the layer that is displayed on the map
		 */ 
		public function getDisplayLayer():Layer{
			
			if(this.map.resolution.reprojectTo(this.projSrsCode).value > this._resolutionToSwitch) {
				return this._firstLayer;
			  }
			  else{
			  	return this._lastLayer;
			  }
		}
		/**
		 * return the vector layer, if there one
		 * return the vector layer that is displayed if there are two
		 * return null if there are no vector layer
		 * this function is usefull , for legend(for example).
		 */
		public function getFeatureLayer():VectorLayer{
			if(this._firstLayer is VectorLayer && this._lastLayer is VectorLayer){
				if(this.map.resolution.reprojectTo(this.projSrsCode).value > this._resolutionToSwitch) {
				 return this._firstLayer as VectorLayer;
			  }
			  else{
			  	return this._lastLayer as VectorLayer;
			  }
			}
			else{
				if(this._firstLayer is VectorLayer){
					return this._firstLayer as VectorLayer;
				}
				if(this._lastLayer is VectorLayer){
					return this._lastLayer as VectorLayer;
				}
				return null;
			}
		}

		/**
		 * Get a polyLayers zoomToSwitch
		 */
		public function get resolutionToSwitch():Number{
			return this._resolutionToSwitch;
		}

		/**
		 * Set a polyLayers zoomToSwitch
		 */
		public function set resolutionToSwitch(value:Number):void {
			this._resolutionToSwitch = value;
		}
	}
}