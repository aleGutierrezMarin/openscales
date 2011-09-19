package org.openscales.core.measure
{
	import org.openscales.core.Map;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.handler.feature.draw.DrawPolygonHandler;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.layer.VectorLayer;
	
	public class Surface extends DrawPolygonHandler implements IMeasure
	{
		private var _mapClickHandler:ClickHandler = null;
		private var _mapDragHandler:DragHandler = null;
		
		public function Surface(map:Map=null)
		{
			super(map);
			super.active = false;
			this.drawLayer = new VectorLayer("MeasureLayer");
			this.drawLayer.displayInLayerManager = false;
		}
		
		override public function set active(value:Boolean):void {
			if(value == this.active)
				return;
			
			super.active = value;
			if(this.map) {
				if(value) {
					this.map.addLayer(this.drawLayer);
					var controls:Vector.<IHandler> = this.map.controls;
					var control:IHandler;
					for each(control in controls) {
						if(control is ClickHandler && (control as ClickHandler).doubleClickZoomOnMousePosition) {
							_mapClickHandler = (control as ClickHandler);
							_mapClickHandler.doubleClickZoomOnMousePosition = false;
							//break;
						} else if(control is DragHandler && control.active == true) {
							_mapDragHandler = (control as DragHandler);
							_mapDragHandler.active = false;
						}
					}
				} else {
					this.drawFinalPoly();
					this.clearFeature();
					this.map.removeLayer(this.drawLayer);
					if(_mapClickHandler) {
						_mapClickHandler.doubleClickZoomOnMousePosition = true;
						_mapClickHandler = null;
					}
					if(_mapDragHandler) {
						_mapDragHandler.active = true;
						_mapDragHandler = null;
					}
				}
			}
		}
		private function clearFeature():void {
			if(newFeature && _polygonFeature){
				this.drawLayer.removeFeature(_polygonFeature);
				_polygonFeature.destroy();
				_polygonFeature = null;
			}
		}
		/*override protected function drawLine(event:MouseEvent=null):void {
			this.clearFeature();
			super.drawLine(event);
			if(_currentLineStringFeature) {
				//dispatcher event de calcul
			}
		}*/
		
		public function getMeasure():String {
			return "";
		}
		
		public function getUnits():String {
			return "m";
		}
	}
}