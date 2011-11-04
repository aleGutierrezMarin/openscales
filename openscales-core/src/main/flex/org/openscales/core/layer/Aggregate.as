package org.openscales.core.layer
{	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.geometry.basetypes.Bounds;

	/**
	 * The Aggregate class defines a Layer container. 
	 * 
	 * <p>
	 * 	It extends the Layer class itslef. Thus, it inherits every methods and attributes of that class and also it can be added to a Map.
	 * </p> 
	 * <p>Adding an Aggregate to a Map results in giving a reference to the map to each contained Layer. The Map has only a reference to the Aggregate. Consequently, the LayerSwitcher will display the Aggregate but the Map will display every contained Layer.</p>
	 */ 
	public class Aggregate extends Layer
	{
		private var _layers:Vector.<Layer>;
		
		/**
		 * Constructor
		 */ 
		public function Aggregate(name:String){
			super(name);
			this._layers = new Vector.<Layer>();
		}
		
		
		public function addLayer(layer:Layer):Boolean{
			if(!layer) return false;
			if(layer is Aggregate) return false;
			if(_layers.indexOf(layer)>0) return false;
			prepareLayer(layer);			
			this._layers.push(layer);
			if(this.map)
			{
				return this.map.addLayer(layer,false);
			}
			return true;
		}
		
		public function addLayers(layers:Vector.<Layer>):void{
			if(!layers) return;
			var layer:Layer;
			for each (layer in layers){
				this.addLayer(layer);	
			}
		}
		
		override public function isAvailableForBounds(bounds:Bounds, resolution:Resolution):Boolean{
			if(this._layers){
				var ok:Boolean = false;
				var layer:Layer;
				for each(layer in this._layers){
					ok = ok || layer.isAvailableForBounds(bounds,resolution);
					if(ok) return ok;
				}
			}
			return false;
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
		
		protected function prepareLayer(layer:Layer):void{
			layer.displayInLayerManager = false;
			layer.visible = this.visible;
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
			if(this._layers){
				var layer:Layer;
				if(value){
					super.map = value;
					for each(layer in this._layers){
						prepareLayer(layer);
						map.addLayer(layer, false);// Add missing layers to map
					}
				}else{//Map is null (removal)
					if(this.map){
						for each(layer in this._layers){
							map.removeLayer(layer); 
						}
						super.map = value;
					}
				}
			}
			
		}
		
		override public function get available():Boolean{
			if(this._layers){
				var ok:Boolean = false;
				var layer:Layer;
				for each(layer in this._layers){
					ok = ok || layer.available;
					if(ok) return ok;
				}
			}
			return false;
		}

		override public function set alpha(value:Number):void{
			super.alpha = value;
			var layer:Layer;
			if(this._layers){
				for each(layer in _layers){
					layer.alpha = value;
				}
			}
		}
		
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
		}
		
		override public function set visible(value:Boolean):void{
			super.visible = value;
			var layer:Layer;
			if(this._layers){
				for each(layer in this._layers){
					layer.visible = value;
				}
			}
		}
	}
}