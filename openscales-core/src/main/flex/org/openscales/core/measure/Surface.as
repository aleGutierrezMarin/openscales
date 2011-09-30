package org.openscales.core.measure
{
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.MeasureEvent;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.handler.feature.draw.DrawPolygonHandler;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.MouseHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.utils.Util;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;
	
	public class Surface extends DrawPolygonHandler implements IMeasure
	{
		private var _mapClickHandler:ClickHandler = null;
		private var _mapDragHandler:DragHandler = null;
		private var _mapMouseHandler:MouseHandler = null;
		
		private var _result:String = "";
		private var _lastUnit:String = null;
		
		private var _displaySystem:String = "metric";
		
		private var _accuracies:HashMap = null;
		
		private var _supportedUnitSystem:Object = {
			'metric': ["km"]
		};
		
		public function Surface(map:Map=null)
		{
			super(map);
			super.active = false;
			this.drawLayer = new VectorLayer("MeasureLayer");
			this.drawLayer.displayInLayerManager = false;
			
			this._accuracies = new HashMap();
			this._accuracies.put("km",3);
		}
		
		override public function set active(value:Boolean):void {
			if(value == this.active)
				return;
			
			super.active = value;
			if(this.map) {
				if(value) {
					this.drawLayer.minResolution = this.map.minResolution;
					this.drawLayer.maxResolution = this.map.maxResolution;
					this.map.addLayer(this.drawLayer);
					var controls:Vector.<IHandler> = this.map.controls;
					var control:IHandler;
					for each(control in controls) {
						if(control is ClickHandler && (control as ClickHandler).doubleClickZoomOnMousePosition) {
							_mapClickHandler = (control as ClickHandler);
							_mapClickHandler.doubleClickZoomOnMousePosition = false;
							//break;
						}else if(control is MouseHandler && (control as MouseHandler).clickHandler.doubleClickZoomOnMousePosition) {
							this._mapMouseHandler = (control as MouseHandler);
							this._mapMouseHandler.clickHandler.doubleClickZoomOnMousePosition=false;
							this._mapMouseHandler.dragHandler.active=false;
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
					if(this._mapMouseHandler){
						this._mapMouseHandler.clickHandler.doubleClickZoomOnMousePosition=true;
						this._mapMouseHandler.dragHandler.active=true;
						this._mapMouseHandler=null;
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
		
		override protected function mouseClick(event:MouseEvent):void {
			this.clearFeature();
			super.mouseClick(event);
			
			var mEvent:MeasureEvent = null;
			if(_polygonFeature && (this._polygonFeature.geometry as Polygon).componentsLength == 1
			&& ((this._polygonFeature.geometry as Polygon).componentByIndex(0) as LinearRing).componentsLength>2) {
				//dispatcher event de calcul
				mEvent = new MeasureEvent(MeasureEvent.MEASURE_AVAILABLE,this);//,null,null);
				
			} else {
				mEvent = new MeasureEvent(MeasureEvent.MEASURE_UNAVAILABLE,this);//,null,null);
			}
			_result = "";
			_lastUnit = null;
			
			this.map.dispatchEvent(mEvent);
		}
		
		public function getMeasure():String {
			var area:Number = 0;
			area = this.getArea();
			
			switch (_displaySystem.toLowerCase()) {
				case "metric":
					var inPerDisplayUnit:Number = Unit.getInchesPerUnit("km");
					if(inPerDisplayUnit) {
						var inPerMapUnit:Number = Unit.getInchesPerUnit(ProjProjection.getProjProjection(drawLayer.projSrsCode).projParams.units);
						area *= Math.pow((inPerMapUnit / inPerDisplayUnit), 2);
						_lastUnit = "km²";
						this._result= Util.truncate(area,_accuracies.getValue("km"));
					}
					break;
				default:
					_lastUnit = null;
					_result="0";
					break;
			}
			return this._result;
		}
		
		private function getArea():Number{
			var area:Number = 0;
			
			if(_polygonFeature && (this._polygonFeature.geometry as Polygon).componentsLength == 1
			&& ((this._polygonFeature.geometry as Polygon).componentByIndex(0) as LinearRing).componentsLength>2){
				
				((this._polygonFeature.geometry as Polygon).componentByIndex(0) as LinearRing).units = ProjProjection.getProjProjection(drawLayer.projSrsCode).projParams.units;
				
				area = ((this._polygonFeature.geometry as Polygon).componentByIndex(0) as LinearRing).area;
				area = Math.abs(area);
				
			}
			
			
			return area;
		}
		
		public function getUnits():String {
			if(!_lastUnit)
				this.getMeasure();
			return _lastUnit;
		}
	}
}