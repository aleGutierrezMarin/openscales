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
		private var _result:String = "";
		private var _lastUnit:String = null;
		
		private var _displaySystem:String = "metric";

		public function get displaySystem():String
		{
			return _displaySystem;
		}

		public function set displaySystem(value:String):void
		{
			if(this._supportedUnitSystem){
				for (var name:String in _supportedUnitSystem) 
				{ 
					if(name == value){
						_displaySystem = value;
					}
				} 
				
			}
		}
		
		private var _accuracies:HashMap = null;

		public function get accuracies():HashMap
		{
			return _accuracies;
		}

		public function set accuracies(value:HashMap):void
		{
			_accuracies = value;
		}

		
		private var _supportedUnitSystem:Object = {
			'metric': ["km"]
		};
		
		public function Surface(map:Map=null)
		{
			super(map);
			super.active = false;
			var layer:VectorLayer = new VectorLayer("MeasureLayer");
			layer.editable = true;
			layer.displayInLayerManager = false;
			this.drawLayer = layer;
			
			this._accuracies = new HashMap();
			this._accuracies.put("km",3);
		}
		
		override public function set active(value:Boolean):void {
			if(value == this.active)
				return;
			
			super.active = value;
			if(this.map) {
				if(value) {
					this.drawLayer.projection = map.projection;
					this.drawLayer.minResolution = this.map.minResolution;
					this.drawLayer.maxResolution = this.map.maxResolution;
					this.map.addLayer(this.drawLayer);
				} else {
					this.drawFinalPoly();
					this.clearFeature();
					this.map.removeLayer(this.drawLayer);
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
						var inPerMapUnit:Number = Unit.getInchesPerUnit(ProjProjection.getProjProjection(drawLayer.projection).projParams.units);
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
				
				((this._polygonFeature.geometry as Polygon).componentByIndex(0) as LinearRing).units = ProjProjection.getProjProjection(drawLayer.projection).projParams.units;
				
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