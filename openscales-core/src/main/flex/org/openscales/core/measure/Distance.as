package org.openscales.core.measure
{
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.MeasureEvent;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.handler.feature.draw.DrawPathHandler;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.MouseHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.utils.Util;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;
	
	public class Distance extends DrawPathHandler implements IMeasure
	{
		
		private var _supportedUnitSystem:Object = {
			'geographic': ["dd"],
			'english': ["mi", "ft", "in"],
			'metric': ["km", "m"]
			
		};
		
		private var _accuracies:HashMap=null;
		
		private var _displaySystem:String = "m";
		
		private var _result:String = "";
		private var _lastUnit:String = null;
		
		/**
		 * Constructor
		 */
		public function Distance(map:Map=null)
		{
			super(map);
			var layer:VectorLayer = new VectorLayer("MeasureLayer");
			layer.editable = true;
			layer.displayInLayerManager = false;
			this.drawLayer = layer;
			
			this._accuracies = new HashMap();
			this._accuracies.put("dd",2);
			this._accuracies.put("rad",4);
			this._accuracies.put("dms",2);
			
			this._accuracies.put("mi",3);
			this._accuracies.put("ft",2);
			this._accuracies.put("in",1);
			
			this._accuracies.put("km",3);
			this._accuracies.put("m",0);
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
					this.drawFinalPath();
					this.clearFeature();
					this.map.removeLayer(this.drawLayer);
				}
			}
		}
		private function clearFeature():void {
			if(newFeature && _currentLineStringFeature){
				this.drawLayer.removeFeature(_currentLineStringFeature);
				_currentLineStringFeature.destroy();
				_currentLineStringFeature = null;
			}
		}
		override protected function drawLine(event:MouseEvent=null):void {
			this.clearFeature();
			super.drawLine(event);
			var mEvent:MeasureEvent = null;
			if(_currentLineStringFeature && (_currentLineStringFeature.geometry as MultiPoint).components.length>1) {
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
			
			var tmpDist:Number = 0;
			
			if(_result!="")
				return _result;
			
			if(_currentLineStringFeature && (_currentLineStringFeature.geometry as MultiPoint).components.length>1) {
				tmpDist = (_currentLineStringFeature.geometry as LineString).length;
				
				
				
				this._accuracies.put("dd",2);
				this._accuracies.put("gon",2);
				this._accuracies.put("mi",3);
				this._accuracies.put("ft",2);
				this._accuracies.put("in",1);

				
				
				tmpDist *= Unit.getInchesPerUnit(ProjProjection.getProjProjection(drawLayer.projection).projParams.units);
				switch (_displaySystem.toLowerCase()) {					
					case "m":
						tmpDist/=Unit.getInchesPerUnit(Unit.METER);
						_result= this.trunc(tmpDist,_accuracies.getValue("m"));
						_lastUnit = "m";
						break;
					
					case "km":
						tmpDist/=Unit.getInchesPerUnit(Unit.KILOMETER);
						_result= this.trunc(tmpDist,_accuracies.getValue("km"));
						_lastUnit = "km";
						break;
					
					case "dd":
						tmpDist/=Unit.getInchesPerUnit(Unit.DEGREE);
						_lastUnit = "°";
						_result= this.trunc(tmpDist,_accuracies.getValue("dd"));
						break;
					
					case "dms":
						tmpDist/=Unit.getInchesPerUnit(Unit.DEGREE);
						_lastUnit = "";
						var acc:Number=this._accuracies.getValue("dms");
						if(!acc){
							acc=2;
						}
						_result= Util.degToDMS(tmpDist,null,acc);
						break;
					
					case "ft":
						tmpDist/=Unit.getInchesPerUnit(Unit.FOOT);
						_lastUnit = "ft";
						_result= this.trunc(tmpDist,_accuracies.getValue("ft"));
						break;
					
					case "in":
						tmpDist/=Unit.getInchesPerUnit(Unit.INCH);
						_lastUnit = "in";
						_result= this.trunc(tmpDist,_accuracies.getValue("in"));
						break;
					
					case "mi":
						tmpDist/=Unit.getInchesPerUnit(Unit.MILE);
						_lastUnit = "mi";
						_result= this.trunc(tmpDist,_accuracies.getValue("mi"));
						break;
					
					default:
						_lastUnit = null;
						_result="0";
						break;
				}
			} else {
				tmpDist = NaN;
				_result ="NaN";
				_lastUnit = null;
			}
			return _result;
		}
		
		private function trunc(val:Number,unit:Number):String{
			var acc:Number=this._accuracies.getValue(unit);
			if(!acc){
				acc=2;
			}
			return Util.truncate(val,acc);
		}
		
		public function getUnits():String {
			if(!_lastUnit)
				this.getMeasure();
			return _lastUnit;
		}

		public function get displaySystem():String
		{
			return _displaySystem;
		}

		public function set displaySystem(value:String):void
		{
			_displaySystem = value;
		}

		public function get accuracies():HashMap
		{
			return _accuracies;
		}

		public function set accuracies(value:HashMap):void
		{
			_accuracies = value;
		}

		
	}
}