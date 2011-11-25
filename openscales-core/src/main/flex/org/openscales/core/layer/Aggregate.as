package org.openscales.core.layer
{	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;
	
	/**
	 * The Aggregate class defines a Layer container. 
	 * 
	 * <p>
	 * 	It extends the Layer class itslef. Thus, it inherits every methods and attributes of that class and also can be added to a Map.
	 * </p> 
	 * <p>
	 * Each contained layer lives indpendently of its Aggregate. Though, properties of the aggregate will have priority to contained layers properties.
	 * </p>
	 * <p>
	 * 	By default, contained layers have displayInLayerManager set to false.
	 * </p>
	 */ 
	public class Aggregate extends Layer
	{
		protected var _layers:Vector.<Layer>;
		private var _stopPropagating:Boolean = true;
		/**
		 * Constructor
		 */ 
		public function Aggregate(name:String){
			super(name);
			this._layers = new Vector.<Layer>();
			this._stopPropagating = false;
		}
		
		/**
		 * Tells if the specified layer should be visible at the given resolution.
		 * 
		 * this method will check if:
		 * 
		 * <ul>
		 * 	<li>layer is within the aggregate</li>
		 * 	<li>the aggregate is visible</li>
		 *  <li>the given resolution is within the aggregate maxRes/minRes range</li>
		 *  <li>the layer intersect the aggregate maxExtent</li>
		 * </ul>
		 */ 
		public function shouldIBeVisible(layer:Layer, resolution:Resolution):Boolean{
			if(this._layers.indexOf(layer)<0)return false;
			if(!layer)return false;
			if(!this.map)return false;
			if(!this.visible)return false;
			if(this.minResolution && resolution.value<this.minResolution.value)return false;
			if(this.maxResolution && resolution.value>this.maxResolution.value)return false;
			if(!layer.isAvailableForBounds(this.maxExtent,resolution))return false;		
			return true;
		}
		
		/**
		 * Add a layer to the list of layers
		 * 
		 * @param layer The layer to add, should not be an Aggregate itself
		 * 
		 * @return True except when layer is null or layer already belong to an Aggregate or layer is an Aggregate or layer is already in the list or the map refused to add the layer.
		 */ 
		public function addLayer(layer:Layer):Boolean{
			if(!layer) return false;
			if(layer is Aggregate) return false;
			if(_layers.indexOf(layer)>0) return false;
			if(layer.aggregate)return false
			prepareLayer(layer);			
			this._layers.push(layer);
			layer.aggregate=this;
			if(this.map){
				this.map.addLayer(layer,false);
			}
			if(this._layers.length==1){
				this.maxExtent = layer.maxExtent;// Taking layer maxExtent as base for aggregate maxExtent
			}else if(this.maxExtent){
				this.maxExtent = this.maxExtent.extendFromBounds(layer.maxExtent);
			}
			return true;
		}
		
		/**
		 * Add several layers.
		 * 
		 * Call addLayer for each layer in layers
		 * 
		 * @param layers a vector of layers
		 */ 
		public function addLayers(layers:Vector.<Layer>):void{
			if(!layers) return;
			var layer:Layer;
			for each (layer in layers){
				this.addLayer(layer);	
			}
		}
		
		override public function destroy():void{
			if(this._layers){
				var layer:Layer;
				for each(layer in this._layers){
					layer.destroy();
				}
			}
			super.destroy();
		}
		
		override public function removeEventListenerFromMap():void {
			if(this._layers){
				var layer:Layer;
				for each(layer in this._layers){
					layer.removeEventListenerFromMap();
				}
			}
			super.removeEventListenerFromMap();
		}
		
		public function removeLayer(layer:Layer):void{
			var index:uint = this._layers.indexOf(layer);
			if(index<0)return;
			layer.aggregate = null;
			if(this.map) this.map.removeLayer(layer);
			this._layers.splice(index,1);
			
			if(this._layers.length>0){
				this.maxExtent = this._layers[0].maxExtent;
				var lgth:Number = this._layers.length;
				var i:int = 1;
				for(i; i<lgth;++i){
					if(!this.maxExtent) this.maxExtent = this._layers[i].maxExtent;
					else this.maxExtent = this.maxExtent.extendFromBounds(this._layers[i].maxExtent);	
				}			
			}
			
		}
		
		public function removeAllLayers():void{
			var layer:Layer;
			var i:uint = this._layers.length;
			for(;i>0;--i){
				this.removeLayer(this._layers[i-1]);
			}
		}
		
		/**
		 * That method is called before a layer is added to the Aggregate. By default, it sets layers's displayInLayerManager property to false
		 */ 
		protected function prepareLayer(layer:Layer):void{
			layer.displayInLayerManager = false;
		}
		
		/**
		 * List of layers contained within this aggregate
		 */
		public function get layers():Vector.<Layer>
		{
			return _layers;
		}
		
		/**
		 * Set the map to aggregated layers
		 * 
		 * @param map The map to which the Aggergate (and its layers) will be attached
		 */ 
		override public function set map(value:Map):void{
			if(this.map){
				this.map.removeEventListener(LayerEvent.LAYER_MOVED_DOWN, makeMyLayersFollowMe);
				this.map.removeEventListener(LayerEvent.LAYER_MOVED_UP, makeMyLayersFollowMe);
			}
			if(this._layers){
				var layer:Layer;
				if(value){
					super.map = value;
					for each(layer in this._layers){
						prepareLayer(layer);
						map.addLayer(layer, false);// Add missing layers to map
					}
				}else{ // Given map is null (removal)
					if(this.map){
						for each(layer in this._layers){
							map.removeLayer(layer); 
						}
						super.map = value;
					}
				}
			}else{
				super.map=value;
			}
			if(this.map){
				this.map.addEventListener(LayerEvent.LAYER_MOVED_DOWN, makeMyLayersFollowMe);
				this.map.addEventListener(LayerEvent.LAYER_MOVED_UP, makeMyLayersFollowMe);
			}
			
			
		}

		/**
		 * @private
		 * 
		 * When an layer is moved (typically in layer manager), we need to ensure that this aggregate and its contained layers are sticking together (in map.layers)
		 */ 
		protected function makeMyLayersFollowMe(event:LayerEvent):void{
			var currentIndex:uint;
			var containedLayerNewIndex:uint;
			var containedLayer:Layer;
			var mapLayersLength:uint;
			
			if(!event)return;
			if(!this.layers || !this.map || (this.layers.length<=0))return;
			if(this.layers.indexOf(event.layer)>=0)return; //If we process contained layers, we will enter in a infinite loop
			
			currentIndex=this.map.layers.indexOf(this);
			if(currentIndex<0)return;
			mapLayersLength = this.map.layers.length;
			containedLayerNewIndex = currentIndex+1;
			for each(containedLayer in this.layers){
				containedLayerNewIndex = Math.min(mapLayersLength-1,containedLayerNewIndex);
				this.map.changeLayerIndex(containedLayer,containedLayerNewIndex);
				++containedLayerNewIndex;
			}
			
		}
		
		override public function set alpha(value:Number):void{
			super.alpha = value;
			
			if(this._stopPropagating) return;
			
			var layer:Layer;
			if(this._layers){
				for each(layer in _layers){
					layer.alpha = value;
				}
			}
		}
		
		/*
		override public function get visible():Boolean{
			if(this._layers){
				var ok:Boolean = false;
				var layer:Layer;
				for each(layer in this._layers){
					ok = ok || layer.visible;
					if(ok) return ok;
				}
			}
			return false;
		}*/
		
		override public function set visible(value:Boolean):void{
			super.visible = value;
			
			if(this._stopPropagating)return;
			
			var layer:Layer;
			if(this._layers){
				for each(layer in this._layers){
					layer.visible = value;
				}
			}
		}
	}
}