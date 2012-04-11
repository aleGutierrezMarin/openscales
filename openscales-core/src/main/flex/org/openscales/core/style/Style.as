package org.openscales.core.style {
	
	import flash.geom.Point;
	import flash.sampler.NewObjectSample;
	import flash.text.TextFormat;
	
	import org.openscales.core.filter.ElseFilter;
	import org.openscales.core.filter.GeometryTypeFilter;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.font.Font;
	import org.openscales.core.style.halo.Halo;
	import org.openscales.core.style.marker.ArrowMarker;
	import org.openscales.core.style.marker.CustomMarker;
	import org.openscales.core.style.marker.WellKnownMarker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.ArrowSymbolizer;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.style.symbolizer.TextSymbolizer;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Polygon;
	
	/**
	 * Style describe graphical attributes used to render vectors.
	 */
	public class Style {
		
		private var _name:String = "Default";
		
		/**
		 * The list of rules of the style
		 */
		private var _rules:Vector.<Rule> = new Vector.<Rule>();
		
		private var _fillColor:uint;
		private var _fillOpacity:Number;
		private var _strokeColor:uint;
		private var _strokeOpacity:Number;
		private var _strokeWidth:Number;
		private var _strokeLinecap:String;
		private var _pointRadius:Number;
		private var _hoverFillColor:uint;
		private var _hoverFillOpacity:Number;
		private var _hoverStrokeColor:uint;
		private var _hoverStrokeOpacity:Number;
		private var _hoverStrokeWidth:Number;
		private var _hoverPointRadius:Number;
		private var _textFormat:TextFormat;
		
		private var _isFilled:Boolean;
		private var _isStroked:Boolean;
		private var _isSelectedStyle:Boolean = false;
		

		public static function getDefaultSelectedColor():uint {
			return 0xF1960A;
		}
		
		/*Points Styles*/
		
		/**
		 * Returns the default style for a PointFeature
		 */
		public static function getDefaultPointStyle():Style {
			
			var style:Style = new Style();
			style.name = "Default point style";
			style.rules.push(getPointRule());
			return style;
		}
		
		/**
		 * Returns the default style for a PointFeature when the feature is selected.
		 */
		public static function getDefaultSelectedPointStyle():Style {
			
			var style:Style = new Style();
			style.name = "Default selected point style";
			style.rules.push(getSelectedPointRule());
			return style;
		}
		
		/**
		 * Returns the rule to apply for the default PointFeature style
		 */
		protected static function getPointRule():Rule{
			
			
			var rule:Rule = new Rule();
			rule.name = "Default rule";
			var symbolizer:PointSymbolizer = new PointSymbolizer(new CustomMarker("http://openscales.org/img/pictos/openscalesDefaultPicto.png"));
			rule.symbolizers.push(symbolizer);
			
			return rule;
		}
		
		/**
		 * Returns the rule to apply for the default selected PointFeature style
		 */
		protected static function getSelectedPointRule():Rule{
			
			var fill:SolidFill = new SolidFill(0xF1960A, 0.5);
			var stroke:Stroke = new Stroke(0xF1960A, 2);
			
			var symbolizer:Symbolizer = new PointSymbolizer(new WellKnownMarker(WellKnownMarker.WKN_SQUARE, fill, stroke, 8));
			
			var rule:Rule = new Rule();
			rule.name = "Default selected point rule";
			rule.symbolizers.push(symbolizer);
			
			return rule;
		}
		
		/**
		 * This method allows to define a point style with custom parameters : marker and rotation
		 */
		public static function getDefinedPointStyle(marker:String, rotation:Number):Style
		{
			var fill:SolidFill = new SolidFill(0xF2620F, 0.7);
			var stroke:Stroke = new Stroke(0xA6430A, 1);
			var mark:WellKnownMarker = new WellKnownMarker(marker, fill, stroke, 6, 1, rotation);
			
			var rule:Rule = new Rule();
			rule.symbolizers.push(new PointSymbolizer(mark));
			
			var style:Style = new Style();
			style.name = "Defined point style";
			style.rules.push(rule);
			
			return style;
		}
		
		/*Line Styles*/
		
		/**
		 * Returns the default style for a LineStringFeature
		 */
		public static function getDefaultLineStyle():Style {
			
			var style:Style = new Style();
			style.name = "Default line style";
			style.rules.push(getLineRule());
			return style;
		}
		
		/**
		 * Returns the default style for a arrowed LineStringFeature
		 */
		public static function getDefaultArrowStyle():Style {
			
			var style:Style = new Style();
			style.name = "Default arrow style";
			style.rules.push(getLineRule());
			
			var am:ArrowMarker = new ArrowMarker(ArrowMarker.AM_NARROW_TRIANGLE,new SolidFill(0x999999,0.5),new Stroke(0xFF0000,2),12)
			style.rules[0].symbolizers.push(new ArrowSymbolizer(new Stroke(0x000000,2),am,am));
			return style;
		}
		
		
		/**
		 * Returns the default style for a LineStringFeature when the feature is selected
		 */
		public static function getDefaultSelectedLineStyle():Style {
			
			var style:Style = new Style();
			style.name = "Default selected line style";
			style.rules.push(getSelectedLineRule());
			return style;
		}
		
		/**
		 * Returns the default style for a LineStringFeature
		 */
		public static function getDefaultLabelStyle():Style {
			return Style.getDefinedLabelStyle(null,12,0xFFFFFF,false,false);
		}
		
		/**
		 * Returns the rule to apply for the default LineStringFeature style
		 */
		protected static function getLineRule():Rule{
			
			var rule:Rule = new Rule();
			rule.name = "Default rule";
			rule.symbolizers.push(new LineSymbolizer(new Stroke(0x3F9FCD, 3)));
			
			return rule;
		}
		
		/**
		 * Returns the rule to apply for the default arrow LineStringFeature style
		 */
		protected static function getArrowRule():Rule{
			
			var rule:Rule = new Rule();
			rule.name = "Default rule";
			var am:ArrowMarker = new ArrowMarker(ArrowMarker.AM_THIN	,new SolidFill(0x3F9FCD,0.5),new Stroke(0x3F9FCD,3),12)
			rule.symbolizers.push(new ArrowSymbolizer(new Stroke(0x3F9FCD, 3), am, am));
			
			return rule;
		}
		
		/**
		 * Returns the rule to apply for the default selected LineStringFeature style
		 */
		protected static function getSelectedLineRule():Rule{
			var color:uint = 0xF1960A;
			var borderThin:int = 3;
			var rule:Rule = new Rule();
			
			rule.name = "Default selected line rule";
			rule.symbolizers.push(new LineSymbolizer(new Stroke(color, borderThin)));
			
			return rule;
		}
		
		/**
		 * This method allows to define a style with custom parameters : color, width, whiteSize and dottedSize
		 */
		public static function getDefinedLineStyle(color:uint, width:Number, opacity:Number, whiteSize:uint, dottedSize:uint):Style
		{
			var stroke:Stroke = new Stroke(color,width,opacity,Stroke.LINECAP_ROUND,Stroke.LINEJOIN_ROUND,whiteSize,dottedSize);
			var symbolizer:LineSymbolizer = new LineSymbolizer(stroke);
			
			var rule:Rule = new Rule();
			rule.symbolizers.push(symbolizer);
			
			var style:Style = new Style();
			style.name = "Defined line style";
			style.rules.push(rule);
			
			return style;
		}
		
		/*Surface Styles*/
		
		/**
		 * Returns the default style for a PolygonFeature
		 */
		public static function getDefaultPolygonStyle():Style {
			var style:Style = new Style();
			style.name = "Surface Style";
			style.rules.push(getDefaultPolygonRule());
			return style;
		}
		
		/**
		 * Returns the default style for a PolygonFeature when the feature is selected
		 */
		public static function getDefaultSelectedPolygonStyle():Style {
			
			var style:Style = new Style();
			style.name = "Default selected polygon style";
			style.rules.push(getDefaultSelectedPolygonRule());
			return style;
		}
		
		/**
		 * Returns the rule to apply for the default PolygonFeature style
		 */
		protected static function getDefaultPolygonRule():Rule{ 
			
			var fill1:SolidFill = new SolidFill();
			fill1.color = 0x0F6BFF;
			fill1.opacity = 0.4;
			
			var stroke1:Stroke = new Stroke();
			stroke1.width = 2;
			stroke1.color = 0x3F9FCD;
			stroke1.opacity = 0.7;
			
			var ps1:PolygonSymbolizer = new PolygonSymbolizer(fill1, stroke1);
			
			var rule:Rule = new Rule();
			rule.name = "Default surface rule";
			rule.symbolizers.push(ps1);
			
			return rule; 
		}
		
		/**
		 * Returns the rule to apply for the default selected PolygonFeature style
		 */
		protected static function getDefaultSelectedPolygonRule():Rule{
			var color:uint = 0xF1960A;
			var opacity:Number = 0.5;
			var borderThin:int = 2;
			var rule:Rule = new Rule();
			
			rule.name = "Default selected polygon rule";
			rule.symbolizers.push(new PolygonSymbolizer(new SolidFill(color, opacity), new Stroke(color, borderThin)));
			
			return rule;
		}
		
		/**
		 * This method allows to define a style with custom color and opacity parameters
		 */
		public static function getDefinedPolygonStyle(color:uint, opacity:Number):Style
		{
			var fill:SolidFill = new SolidFill(color, opacity);
			var stroke:Stroke = new Stroke(0xE7FF33, 3);
			
			var rule:Rule = new Rule();
			rule.symbolizers.push(new PolygonSymbolizer(fill, stroke));
			
			var style:Style = new Style();
			style.name = "Defined surface style";
			style.rules.push(rule);
			
			return style;
		}
		
		/*Circle Styles*/
		/**
		 * Returns the default style for a PointFeature drawn with a circle
		 */
		public static function getDefaultCircleStyle():Style {
			
			var fill:SolidFill = new SolidFill(0xFF2819, 0.7);
			var stroke:Stroke = new Stroke(0xFF2819, 1);
			
			var mark:WellKnownMarker = new WellKnownMarker(WellKnownMarker.WKN_CIRCLE, fill, stroke);
			
			var symbolizer:PointSymbolizer = new PointSymbolizer();
			symbolizer.graphic = mark;
			
			var rule:Rule = new Rule();
			rule.name = "Default rule";
			rule.symbolizers.push(symbolizer);
			
			var style:Style = new Style();
			style.name = "Default circle style";
			style.rules.push(rule);
			return style;
		}
		
		/*Graticule Styles*/
		public static function getDefaultGraticuleStyle():Style {
			var style:Style = new Style();
			style.name = "Default graticule style";
			style.rules.push(getGraticuleRule());
			return style;
		}
		
		public static function getDefaultGraticuleLabelStyle():Style{
			
			var style:Style = new Style();
			style.name = "Default graticule label style";
			var ts:TextSymbolizer = new TextSymbolizer();
			ts.font = new Font();
			ts.font.family = "Arial";
			ts.font.size = 12;
			ts.font.color = 0xFFFFFF;
			ts.font.weight = Font.BOLD;
			ts.halo = new Halo(0x000000);
			style.rules.push(new Rule());
			style.rules[0].symbolizers[0] = ts;
			return style;
		}
		
		protected static function getGraticuleRule():Rule{
			
			var rule:Rule = new Rule();
			rule.name = "Default graticule rule";
			rule.symbolizers.push(new LineSymbolizer(new Stroke(0x000000, 3)));
			rule.symbolizers.push(new LineSymbolizer(new Stroke(0xFFFFFF, 1)));
			
			return rule;
		}
		
		/*Label Styles*/
		public static function getDefinedLabelStyle(font:String, size:Number, color:uint, bold:Boolean, italic:Boolean):Style{
			
			var style:Style = new Style();
			style.name = "Defined label style";
			var rule:Rule = new Rule();
			rule.name = "Default rule";
			var f:Font = new Font(size,color,1,font,(italic?Font.ITALIC:Font.NORMAL),(bold?Font.BOLD:Font.NORMAL));
			var h:Halo = new Halo((0xFFFFFF-color));
			rule.symbolizers.push(new TextSymbolizer(null,f,h));
			style.rules.push(rule);
			style._textFormat = new TextFormat(font,size,color,bold,italic);
			return style;
		}
		
		public static function getNegativeLabelStyle(style:Style):Style{
			var s:Style = style.clone();
			if(s.rules[0] && s.rules[0].symbolizers[0] && s.rules[0].symbolizers[0] is TextSymbolizer) {
				var ts:TextSymbolizer = s.rules[0].symbolizers[0] as TextSymbolizer;
				if(ts.halo)
					ts.halo.color = 0xFFFFFF-ts.halo.color;
				if(ts.font)
					ts.font.color = 0xFFFFFF-ts.font.color;
			}
			return s;
		}
		
		/*Default Styles*/
		public static function getDefaultStyle():Style{
			
			var style:Style = new Style();
			style.name = "OpenScales default style";
			
			// Style for Polygon and Multipolygon
			var polygonRule:Rule = getDefaultPolygonRule();
			polygonRule.filter = new GeometryTypeFilter(new <Class>[Polygon,MultiPolygon]);
			style.rules.push(polygonRule);
			
			// Style for LineString and MultilineString
			var lineRule:Rule = getLineRule();
			lineRule.filter = new GeometryTypeFilter(new <Class>[LineString,MultiLineString]);
			style.rules.push(lineRule);
			
			// Default rule for other types
			var pointRule:Rule = getPointRule();
			pointRule.filter =  new GeometryTypeFilter(new <Class>[Point,MultiPoint]);
			style.rules.push(pointRule);
			
			return style;			
		}
		
		/**
		 * <p>Class constructor.</p>
		 *
		 * <p>It defines default values for the attributes.</p>
		 */
		public function Style() {
			//Default values
			_fillColor = 0x00ff00;
			_fillOpacity = 0.4;
			_strokeColor = 0x00ff00;
			_strokeOpacity = 1;
			_strokeWidth = 2;
			_strokeLinecap = "round";
			_pointRadius = 6;
			_hoverFillColor = 0xffffff;
			_hoverFillOpacity = 0.2;
			_hoverStrokeColor = 0xff0000;
			_hoverStrokeOpacity = 1;
			_hoverStrokeWidth = 0.2;
			_hoverPointRadius = 1;
			_isFilled = true;
			_isStroked = true;
			_textFormat = new TextFormat("Arial",12,0x000000,false,false);
		}
		
		public function clone():Style {
			var clonedStyle:Style = new Style();
			clonedStyle._fillColor = this._fillColor;
			clonedStyle._fillOpacity = this._fillOpacity;
			clonedStyle._strokeColor = this._strokeColor;
			clonedStyle._strokeOpacity = this._strokeOpacity;
			clonedStyle._strokeWidth = this._strokeWidth;
			clonedStyle._strokeLinecap = this._strokeLinecap;
			clonedStyle._pointRadius = this._pointRadius;
			clonedStyle._hoverFillColor = this._hoverFillColor;
			clonedStyle._hoverFillOpacity = this._hoverFillOpacity;
			clonedStyle._hoverStrokeColor = this._hoverStrokeColor;
			clonedStyle._hoverStrokeOpacity = this._hoverStrokeOpacity;
			clonedStyle._hoverStrokeWidth = this._hoverStrokeWidth;
			clonedStyle._hoverPointRadius = this._hoverPointRadius;
			clonedStyle._isFilled = this._isFilled;
			clonedStyle._isStroked = this._isStroked;
			
			if(this._rules != null){
				var lenghtRules:uint = this._rules.length;
				var rulesClone:Vector.<Rule> = new Vector.<Rule>();
				for(var i:uint=0; i < lenghtRules; i++){
					rulesClone[i] = this._rules[i].clone();
				}
				clonedStyle.rules = rulesClone;
			}
			clonedStyle._name = this._name+ new Date().time;
			
			return clonedStyle;
		}
		
		 /* Getters & setters */ /**
		 * A name for the style
		 */
		public function get name():String {
			
			return this._name;
		}
		
		public function set name(value:String):void {
			
			this._name = value;
		}
		
		/**
		 * The list of the rules defining the style
		 */
		public function get rules():Vector.<Rule> {
			
			return this._rules;
		}
		
		public function set rules(value:Vector.<Rule>):void {
			this._rules = value;
		}
		
		public function get textFormat():TextFormat{
			return this._textFormat;
		}
		
		public function get isSelectedStyle():Boolean
		{
			return _isSelectedStyle;
		}
		
		public function set isSelectedStyle(value:Boolean):void
		{
			_isSelectedStyle = value;
		}
	}
}
