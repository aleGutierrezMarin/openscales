package org.openscales.fx.control
{
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.OverviewMap;
	import org.openscales.fx.layer.FxLayer;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.ProjProjection;
	
	import spark.core.SpriteVisualElement;
	
	/**
	 * <p>OverviewMap Flex wrapper.</p>
	 * <p>To use it, declare a &lt;OverviewMap /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxOverviewMap extends Control
	{
		private var _overviewmap:OverviewMap;
		public function FxOverviewMap()
		{
			super();
			this.width=100;
			this.height=100;
			_overviewmap = new OverviewMap();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, this.onCreationComplete);
		}
		
		override public function set map(value:Map):void {
			_overviewmap.map = value;
			this.draw();
		}
		override public function get map():Map {
			return _overviewmap.map;
		}
		
		public function set extentColor(value:uint):void {
			_overviewmap.extentColor = value;
		}
		
		public function set newExtentColor(value:uint):void {
			_overviewmap.newExtentColor = value;
		}
		
		override public function draw():void {
			var mapContainer:SpriteVisualElement = new SpriteVisualElement();
			this.addElementAt(mapContainer, 0);
			mapContainer.addChild(this._overviewmap);
			if(this.width && this.height)
				this._overviewmap.size = new Size(this.width,this.height);
		}
		
		override protected function onCreationComplete(event:FlexEvent):void {
			var i:uint;
			var element:IVisualElement;
			var layerFound:Boolean = false;
			for(i=0; i<this.numElements; i++) {
				element = this.getElementAt(i);
				if (element is FxLayer) {
					if(!layerFound) {
						this._overviewmap.removeAllLayers();
						layerFound = true;
					}
					this.addFxLayer(element as FxLayer);
				}
			}
		}
		
		private function addFxLayer(l:FxLayer):void {
			l.configureLayer();
			_overviewmap.addLayer(l.nativeLayer);
		}
		
		public function get overviewMap():OverviewMap {
			return this._overviewmap;
		}
		
		/**
		 * The projection of the overview map, default value is EPSG:4326
		 */
		public function get projection():ProjProjection
		{
			return this._overviewmap.projection;
		}
		
		/**
		 * @private
		 */
		public function set projection(value:*):void
		{
			this._overviewmap.projection = value;
		}
	}
}