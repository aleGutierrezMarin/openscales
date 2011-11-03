package org.openscales.core.layer
{	
	import org.openscales.core.Map;

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
			layer.displayInLayerManager = false;
			layer.visible = this.visible;
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
			super.map = map;
			if(this._layers){
				var layer:Layer;
				for each(layer in this._layers){
					map.addLayer(layer, false);// Add missing layers to map
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

	}
}