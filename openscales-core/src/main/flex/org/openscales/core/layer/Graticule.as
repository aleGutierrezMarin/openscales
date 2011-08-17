package org.openscales.core.layer
{
	import org.openscales.core.Trace;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	
	/*
	 * Graticule control.
	 * Displays a grid based on geographical coordinates.
	 */
	public class Graticule extends FeatureLayer
	{
		/**
		 * APIProperty: intervals
		 * {Array(Float)} A list of possible graticule widths in degrees.
		 */
		private var _intervals:Array = new Array(45, 30, 20, 10, 5, 2, 1, 0.5, 0.2, 0.1, 0.05, 0.01, 0.005, 0.002, 0.001);
		
		/*
		 * Default constructor.
		 */
		public function Graticule(name:String, style:Style = null) 
		{
			super(name);
			// TODO: gestion d'un nom par défaut en constante? i18n?
			
			// style setup
			if(style){
				this.style = style;
				this.style.rules.push(new Rule());
				this.style.rules[0].symbolizers.push(new LineSymbolizer(new Stroke(0xc9c9c9,1,1,Stroke.LINECAP_BUTT)));
			}
			else this.style = null;
			// TODO: définition d'un style par défaut pour le graticule?
			
			// feature layer initialisation
			this.projSrsCode = "EPSG:4326";
			
		}
		
		override protected function draw():void {
			Trace.useFireBugConsole = true;
			Trace.debug("début draw");
			// calculates which interval to use
			var interval:Number = NaN;
			var extent:Bounds = this.map.extent.reprojectTo("EPSG:4326");
			var xmin:Number = extent.left;
			var xmax:Number = extent.right;
			var ymin:Number = extent.bottom;
			var ymax:Number = extent.top;
			Trace.debug("xmin="+xmin);
			Trace.debug("xmax="+xmax);
			Trace.debug("ymin="+ymin);
			Trace.debug("ymax="+ymax);
			var minMapSize:Number = Math.min(xmax-xmin, ymax-ymin);
			Trace.debug("minMapSize="+minMapSize);
			var j:uint = _intervals.length;
			for (var i:uint = 0; i<j ;i++) {
				Trace.debug("_intervals[i]="+_intervals[i]);
				if (minMapSize/_intervals[i] > 2) {
					interval = _intervals[i]; 
					break;
				}
			}
			Trace.debug("interval="+interval);
			
			// verifies interval has been found
			if (interval) {
				
				//
				// vertical lines
				//
				
				// calculates first x coordinate
				var firstX:Number = interval*Math.floor(xmin/interval);
				Trace.debug("firstX="+firstX);
				
				// loop till xmax is reached
				var currentX:Number = firstX;
				while (currentX<xmax) {	
					Trace.debug("currentX="+currentX);
					var points:Vector.<Number> = new Vector.<Number>();
					points.push(currentX, ymin, currentX, ymax);
					var line:LineString = new LineString(points);
					var lineFeature:LineStringFeature = new LineStringFeature(line,null,this.style);
					this.addFeature(lineFeature);
					currentX = currentX+interval;
				}
				
				//
				// horizontal lines
				//
				
				// calculates first y coordinate
				var firstY:Number = interval*Math.floor(ymin/interval);
				Trace.debug("firstY="+firstY);
				
				// loop till ymax is reached
				var currentY:Number = firstY;
				while (currentY<ymax) {	
					Trace.debug("currentY="+currentY);
					points = new Vector.<Number>();
					points.push(xmin, currentY, xmax, currentY);
					line = new LineString(points);
					lineFeature = new LineStringFeature(line,null,this.style);
					this.addFeature(lineFeature);
					currentY = currentY+interval;
				}
				

			}
		}
		
		override public function redraw(fullRedraw:Boolean = true):void {
			// TODO ne faire le super que si besoin
			
			super.redraw();
		}
		
		/**
		 * Getters and Setters
		 */

		public function get intervals():Array
		{
			return _intervals;
		}
		
		public function set intervals(value:Array):void
		{
			_intervals = value;
		}
	}
}