package org.openscales.core.layer
{
	import flash.display.DisplayObject;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.geometry.basetypes.Bounds;

	public class PolyLayer extends Layer
	{
		/**
		 * Ordered list of sub layers
		 */
		private var layers:Vector.<Layer> = new Vector.<Layer>();
		
		public function PolyLayer(name:String)
		{
			super(name);
		}
		
		/**
		 * Add a new layer to the map.
		 * A LayerEvent.LAYER_ADDED event is triggered.
		 *
		 * @param layer The layer to add.
		 * @return true if the layer have been added, false if it has not.
		 */
		public function addLayer(layer:Layer, dispatchEvent:Boolean = true):Boolean {
			if(!layer || layers.indexOf(layer)!=-1)
				return false;
			layers.push(layer);

			layer.alpha = this.alpha;
			layer.isFixed = this.isFixed;
			
			if (this.map){
				this.addChild(layer);
				layer.map = this.map;
				layer.redraw();	
			}
			
			if(dispatchEvent && this.map)
				this.map.dispatchEvent(new LayerEvent(LayerEvent.POLY_LAYER_CHANGED, this));
			
			return true;
		}
		
		/**
		 * Add a group of layers.
		 * @param layers to add.
		 */
		public function addLayers(layers:Vector.<Layer>):void {
			var layersNb:uint = layers.length;
			var dispatchEvent:Boolean = false;
			for (var i:uint=0; i<layersNb; ++i) {
				if(this.addLayer(layers[i], false))
					dispatchEvent = true;
			}
			if(dispatchEvent && this.map)
				this.map.dispatchEvent(new LayerEvent(LayerEvent.POLY_LAYER_CHANGED, this));
		}
		
		override protected function draw():void {
			var nbChildren:int = this.numChildren;
			var o:DisplayObject;
			for(var i:uint=0 ; i<nbChildren; ++i) {
				o = this.getChildAt(i);
				if (o is Layer) {
					(o as Layer).redraw(true);
				}
			}
		}
		
		override public function generateResolutions(numZoomLevels:uint=Layer.DEFAULT_NUM_ZOOM_LEVELS, nominalResolution:Number=NaN):void {
			super.generateResolutions(numZoomLevels,nominalResolution);
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].generateResolutions(numZoomLevels,nominalResolution);
			}
		}
		
		override public function destroy():void {
			var layer:Layer;
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0; i<numLayer;++i) {
				layer = layers.pop();
				layer.destroy();
			}
			super.destroy();
		}
		
		override public function removeEventListenerFromMap():void {
			super.removeEventListenerFromMap();
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].removeEventListenerFromMap();
			}
		}
		
		override public function set map(map:Map):void {
			var numLayer:uint = this.layers.length;
			var i:uint;
			if(this.map) {
				for(i = 0;i<numLayer;++i) {
					this.removeChild(layers[i]);
				}
			}
			super.map = map;
			if(this.map) {
				for(i = 0;i<numLayer;++i) {
					this.addChild(layers[i]);
					layers[i].map = this.map;
					layers[i].redraw(true);
				}
			}
		}
		
		override public function clear():void {
			super.clear();
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].clear();
			}
		}
		
		override public function reset():void {
			super.reset();
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].reset();
			}
		}
		
		override public function redraw(fullRedraw:Boolean=true):void {
			super.redraw(fullRedraw);
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].redraw(fullRedraw);
			}
		}
		
		override public function set visible(value:Boolean):void {
			super.visible = value;
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].visible = value;
			}
		}
		
		override public function set alpha(value:Number):void {
			super.alpha = value;
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].alpha = value;
			}
		}
		
		override public function get originators():Vector.<DataOriginator> {
			var ori:Vector.<DataOriginator> = new Vector.<DataOriginator>();
			ori.concat(super.originators);
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				ori.concat(layers[i].originators);
			}
			return ori;
		}
		
		/**
		 * Whether or not the layer is loading data
		 */
		override public function get loadComplete():Boolean {
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				if(!layers[i].loadComplete)
					return false;
			}
			return true;
		}
		
		override public function set maxExtent(value:*):void {
			super.maxExtent = value;
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].maxExtent = (value as Bounds);
			}
		}
		
		override public function set maxResolution(value:*):void {
			super.maxResolution = value;
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].maxResolution = value;
			}
		}
		
		override public function set minResolution(value:*):void {
			super.minResolution = value;
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].minResolution = value;
			}
		}
		
		override public function set resolutions(value:Array):void {
			super.resolutions = value;
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].resolutions = value;
			}
		}
		
		override public function set projection(value:*):void {
			super.projection = value;
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].projection = this.projection;
			}
		}
		
		override public function set isFixed(value:Boolean):void {
			super.isFixed = value;
			var numLayer:uint = this.layers.length;
			for(var i:uint = 0;i<numLayer;++i) {
				layers[i].isFixed = value;
			}
		}
	}
}