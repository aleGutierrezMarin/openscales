package org.openscales.fx.control
{
	import flash.events.Event;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.control.OverviewMapRatio;
	import org.openscales.fx.layer.FxLayer;
	import org.openscales.geometry.basetypes.Size;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;
	
	/**
	 * <p>OverviewMap Flex wrapper.</p>
	 * <p>To use it, declare a &lt;OverviewMap /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxOverviewMapRatio extends Control
	{
		private var _overviewmap:OverviewMapRatio;
		public function FxOverviewMapRatio()
		{
			super();
			//this.width=100;
			//this.height=100;
			_overviewmap = new OverviewMapRatio();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, this.onCreationComplete);
		}
		
		override public function set map(value:Map):void {
			_overviewmap.map = value;
			this.draw();
		}
		override public function get map():Map {
			return _overviewmap.map;
		}
		
		
		override public function draw():void {
			var mapContainer:SpriteVisualElement = new SpriteVisualElement();
			this.addElementAt(mapContainer, 0);
			mapContainer.addChild(this._overviewmap);
			if(this.width && this.height)
				this._overviewmap.size = new Size(this.width,this.height);
		}
		
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
		private function addFxLayer(fxLayer:FxLayer):void {
			_overviewmap.layer = fxLayer.layer;
		}
		
		public function get overviewMap():OverviewMapRatio {
			return this._overviewmap;
		}
		
		public function set ratio(value:String):void
		{
			_overviewmap.ratio = Number(value);
		}
	}
}