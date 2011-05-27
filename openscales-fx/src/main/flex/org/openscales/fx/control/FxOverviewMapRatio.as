package org.openscales.fx.control
{
	import flash.events.Event;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.OverviewMapRatio;
	import org.openscales.core.layer.Layer;
	import org.openscales.fx.layer.FxLayer;
	import org.openscales.geometry.basetypes.Size;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;
	
	/**
 	 * Display an overview linked with the map.
	 * The map and the overview resolutions are linked with a ratio.
	 * This ratio will be kept when you zoom on the map.
	 * The overview map is a single layer
	 * 
	 * @author Viry Maxime
	 */
	public class FxOverviewMapRatio extends Control
	{
		/**
		 * @private
		 * ActionScript object of the overviewMapRatio
		 */
		private var _overviewmap:OverviewMapRatio;
		
		// --- Properties --- //
		/**
		 * Ratio between the overview resolution and the map resolution
		 * The ratio is MapResolution/OverviewMapResolution
		 * While setting a new ratio the oveview zoom level will be recomputed
		 * 
		 * @param ratio The curent ratio between the overview map and the map
		 */
		public function set ratio(value:Number):void
		{
			_overviewmap.ratio = value;
		}
		
		/**
		 * @private
		 */
		public function get ratio():Number
		{
			return _overviewmap.ratio;
		}
		
		/**
		 * Layer displayed on the overview map
		 */		
		public function set layer(value:Layer):void{
			
			this._overviewmap.layer = value;	
		}
		
		/**
		 * @private
		 */
		public function get layer():Layer{
			
			return this._overviewmap.layer;
		}
		
		
		/**
		 * FxOverviewMapRatio constructor
		 */
		public function FxOverviewMapRatio()
		{
			super();
			_overviewmap = new OverviewMapRatio();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, this.onCreationComplete);
		}
		
		/**
		 * The map used to compute the ratio
		 * It may be the main map of the application
		 * 
		 * @param value The map linked with the overviewMap
		 */
		override public function set map(value:Map):void {
			_overviewmap.map = value;
			this.draw();
		}
		
		/**
		 * @private
		 * 
		 */
		override public function get map():Map {
			return _overviewmap.map;
		}
		
		
		/**
		 * Draw the overview map
		 */
		override public function draw():void {
			var mapContainer:SpriteVisualElement = new SpriteVisualElement();
			this.addElementAt(mapContainer, 0);
			mapContainer.addChild(this._overviewmap);
			if(this.width && this.height)
				this._overviewmap.size = new Size(this.width,this.height);
		}
		
		/**
		 * The width of the overview map
		 */
		override public function set width(value:Number):void{
			super.width = value;
			this._overviewmap.width = value;
		}
		
		/**
		 * The height of the overview map
		 */
		override public function set height(value:Number):void{
			super.height = value;
			this._overviewmap.height = value;
		}
				
		
		/**
		 * The Flex side of the control has been created, so activate the overviewMap
		 */
		override protected function onCreationComplete(event:Event):void {
			var i:uint;
			var element:IVisualElement;
			for(i=0; i<this.numElements; i++) {
				element = this.getElementAt(i);
				if (element is FxLayer) {
					this.addFxLayer(element as FxLayer);
				}
			}
		}
		
		/**
		 * Add a layer to the overviewMap
		 * Currently you can only set one layer in the overviewMap
		 * 
		 * @param fxLayer The flex layer to add to the overviewMap
		 */
		private function addFxLayer(fxLayer:FxLayer):void {
			_overviewmap.layer = fxLayer.layer;
		}
		
		/**
		 * @private
		 */
		private function get overviewMap():OverviewMapRatio {
			return this._overviewmap;
		}
		
		
		
	}
}