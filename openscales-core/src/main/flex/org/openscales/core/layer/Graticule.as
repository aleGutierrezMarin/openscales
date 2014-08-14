package org.openscales.core.layer
{
	import org.openscales.core.Map;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LabelFeature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.proj4as.ProjProjection;
	
	use namespace os_internal;
	
	/**
	 * Graticule control.
	 * Displays a grid on the map, based on geographical coordinates.
	 * The possible intervals are defined by default, but can be overrided by the developper.
	 * The graticule layer appears in the layer switcher.
	 * The style property should contain rules with TextSymbolizer and LineSymbolizer
	 * @author xlaprete
	 */
	public class Graticule extends VectorLayer
	{
		private var _latitudeLabelsAlign:String = "left";
		
		private var _longitudeLabelsAlign:String = "bottom";
		
		private var _longitudeLabelsPadding:Number = 3;
		
		private var _latitudeLabelsPadding:Number = 3;
		
		private var _labelFormatter:IGraticuleLabelFormatter = new DefaultGraticuleLabelFormatter();
		
		/**
		 * @private
		 * Array of possible graticule widths in degrees, from biggest to smallest.
		 * 
		 * @default [45, 30, 20, 10, 5, 2, 1, 0.5, 0.2, 0.1, 0.05, 0.01, 0.005, 0.002, 0.001]
		 */
		private var _intervals:Array = new Array(45, 30, 20, 10, 5, 2, 1, 0.5, 0.2, 0.1, 0.05, 0.01, 0.005, 0.002, 0.001);
		
		/**
		 * @private
		 * Minimum number of lines to display for the graticule.
		 * 
		 * @default 3
		 */
		private var _minNumberOfLines:uint = 3;
		
		/**
		 * Default constructor.
		 * @param name Name of the graticule layer.
		 * @param style Style of the graticule layer.
		 */
		public function Graticule(name:String, style:Style = null) 
		{
			// default init
			super(name);
			
			// style setup
			if(style){
				this.style = style;
			} else {
				this.style = Style.getDefaultGraticuleStyle();
			}
			
			// puts layer in geographical coordinates
			this._projection = ProjProjection.getProjProjection(Geometry.DEFAULT_SRS_CODE);
			this.setMaxExtent(new Bounds(-180,-90,180,90,Geometry.DEFAULT_SRS_CODE));
			
			// hides layer in LayerManager
			this.displayInLayerManager = false;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set map(map:Map):void {
			if (this.map != null) {
				this.map.removeEventListener(LayerEvent.LAYER_ADDED, this.putGraticuleOnTop);
			}
			super.map = map;
			if (this.map != null) {
				this.map.addEventListener(LayerEvent.LAYER_ADDED, this.putGraticuleOnTop);
			}
		}
		
		/**
		 * Method called when a layer is added, so that graticule is always on top.
		 */
		public function putGraticuleOnTop(event:LayerEvent):void {
			this.map.changeLayerIndex(this, this.map.layers.length-1);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function draw():void {
			// remove old features
			if(this.features)
				this.removeFeatures(this.features);
			
			// A variable to stock every label features
			var labelFeatures:Vector.<Feature> = new Vector.<Feature>();
			
			// gets bounds in geographical coordinates
			var intersection:Bounds = this.map.maxExtent.getIntersection(this.map.extent);
			intersection = intersection.reprojectTo(this.projection);
			var xmin:Number=intersection.left;
			var xmax:Number=intersection.right;
			var ymin:Number=intersection.bottom;
			var ymax:Number=intersection.top;
			
			// calculates which interval to use
			var interval:Number = getBestInterval(xmin, xmax, ymin, ymax);
			
			// verifies interval has been found
			if (interval) {
				
				// offset for labels
				var offset:Number = interval/10;
				
				// location relative to alignement
				var alignValue:Number;
				
				//
				// draw vertical lines
				//
				
				// calculates first x coordinate
				var firstX:Number = getFirstCoordinateForGraticule(xmin, interval);
				
				// loop till xmax is reached
				var currentX:Number = firstX;
				while (currentX<xmax) {	
					// lines
					var points:Vector.<Number> = new Vector.<Number>();
					points.push(currentX, ymin, currentX, ymax);
					var line:LineString = new LineString(points);
					var lineFeature:LineStringFeature = new LineStringFeature(line,null,this.style);
					this.addFeature(lineFeature);
					// labels
					var degreeLabel:String = _labelFormatter.format(currentX,interval,"X");
					
					
					if(_longitudeLabelsAlign == "top") alignValue = ymax-_longitudeLabelsPadding*offset;
					else if(_longitudeLabelsAlign == "center") alignValue = (ymin+ymax)/2 + _longitudeLabelsPadding*offset;
					else alignValue = ymin + _longitudeLabelsPadding*offset;
					
					var labelFeature:LabelFeature = LabelFeature.createLabelFeature(new Location(currentX+2*offset, alignValue));
					labelFeature.text = degreeLabel;
					labelFeature.style = style;
					// Differing label feature addition to the layer
					labelFeatures.push(labelFeature);
					// iterates
					currentX = currentX+interval;
				}
				
				//
				// draw horizontal lines
				//
				
				// calculates first y coordinate
				var firstY:Number = getFirstCoordinateForGraticule(ymin, interval);
				
				// loop till ymax is reached
				var currentY:Number = firstY;
				while (currentY<ymax) {	
					// lines
					points = new Vector.<Number>();
					points.push(xmin, currentY, xmax, currentY);
					line = new LineString(points);
					lineFeature = new LineStringFeature(line,null,this.style);
					this.addFeature(lineFeature);
					// labels
					degreeLabel = _labelFormatter.format(currentY,interval,"Y");
					
					if(_latitudeLabelsAlign == "right") alignValue = xmax-_latitudeLabelsPadding*offset
					else if(_latitudeLabelsAlign == "center") alignValue = (xmin+xmax)/2 + _latitudeLabelsPadding*offset;
					else alignValue = xmin+_latitudeLabelsPadding*offset;
					
					labelFeature = LabelFeature.createLabelFeature(new Location(alignValue, currentY+offset));
					labelFeature.text = degreeLabel;
					labelFeature.style = style;
					// Differing label feature addition to the layer
					labelFeatures.push(labelFeature);
					// iterates
					currentY = currentY+interval;
				}
				// Now we are sur that labels will be on top of lines
				addFeatures(labelFeatures);
			}
		}
		
		/**
		 * Gets best interval of the graticule for the map.
		 * There must be at least 2 lines in each direction.
		 * @param xmin x coordinate on the left of the map.
		 * @param xmax x coordinate on the right of the map.
		 * @param ymin y coordinate on the bottom of the map.
		 * @param ymax y coordinate on the top of the map.
		 * @return The best interval of the graticule for the map.
		 */
		os_internal function getBestInterval(xmin:Number, xmax:Number, ymin:Number, ymax:Number):Number {
			var interval:Number = NaN;
			var minMapSize:Number = Math.min(xmax-xmin, ymax-ymin);
			var j:uint = _intervals.length;
			for (var i:uint = 0; i<j ;i++) {
				if (minMapSize/_intervals[i] > _minNumberOfLines) {
					interval = _intervals[i]; 
					break;
				}
			}
			return interval;
		}
		
		/**
		 * Gets first coordinate for the graticule line.
		 * @param firstCoordinateOfMap x coordinate on the left of the map or y coordinate on the bottom of the map.
		 * @param interval Interval used for the graticule.
		 * @return The first coordinate to use for the graticule line.
		 */
		os_internal function getFirstCoordinateForGraticule(firstCoordinateOfMap:Number, interval:Number):Number {
			var firstCoordinate:Number = interval*Math.floor(firstCoordinateOfMap/interval)+interval;
			return firstCoordinate;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function setProjection(value:Object):void {
			// SRS code cannot be overriden. Graticule is always built in EPSG:4326
			// and then reprojected to the projection of the map.
		}
		
		/**
		 * The alignement for latitude labels. Can be top, center or bottom (default is bottom)
		 */
		public function get longitudeLabelsAlign():String
		{
			return _longitudeLabelsAlign;
		}
		
		/**
		 * @private
		 */
		public function set longitudeLabelsAlign(value:String):void
		{
			_longitudeLabelsAlign = value;
		}
		
		/**
		 * The alignement for longitude labels. Can be left, center or right (default is left)
		 */
		public function get latitudeLabelsAlign():String
		{
			return _latitudeLabelsAlign;
		}
		
		/**
		 * @private
		 */
		public function set latitudeLabelsAlign(value:String):void
		{
			_latitudeLabelsAlign = value;
		}

		
		/**
		 * Array of possible graticule widths in degrees, from biggest to smallest.
		 */
		public function get intervals():Array
		{
			return _intervals;
		}
		
		/**
		 * @private
		 */
		public function set intervals(value:Array):void
		{
			_intervals = value;
		}
		
		/**
		 * Minimum number of lines to display for the graticule.
		 * 
		 * @default 3
		 */
		public function get minNumberOfLines():uint
		{
			return _minNumberOfLines;
		}
		
		/**
		 * @private
		 */
		public function set minNumberOfLines(value:uint):void
		{
			_minNumberOfLines = value;
		}

		/**
		 * Padding coef added to longitude label location (default is 3)
		 */
		public function get longitudeLabelsPadding():Number
		{
			return _longitudeLabelsPadding;
		}

		/**
		 * @private
		 */
		public function set longitudeLabelsPadding(value:Number):void
		{
			_longitudeLabelsPadding = value;
		}

		/**
		 *  Padding coef added to latitude label location (default is 3)
		 */
		public function get latitudeLabelsPadding():Number
		{
			return _latitudeLabelsPadding;
		}

		/**
		 * @private
		 */
		public function set latitudeLabelsPadding(value:Number):void
		{
			_latitudeLabelsPadding = value;
		}

		/**
		 * A formmatter for the labels (default is DefaultGraticuleLabelFormatter). Do not concern style, only format.
		 */
		public function get labelFormatter():IGraticuleLabelFormatter
		{
			return _labelFormatter;
		}

		/**
		 * @private
		 */
		public function set labelFormatter(value:IGraticuleLabelFormatter):void
		{
			_labelFormatter = value;
		}


	}
}