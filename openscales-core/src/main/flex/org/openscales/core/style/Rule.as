package org.openscales.core.style {
	import flash.display.DisplayObject;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import org.openscales.core.filter.Comparison;
	import org.openscales.core.filter.IFilter;
	import org.openscales.core.style.graphic.ExternalGraphic;
	import org.openscales.core.style.graphic.IGraphic;
	import org.openscales.core.style.graphic.Mark;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.style.symbolizer.TextSymbolizer;
	import org.openscales.geometry.basetypes.Pixel;

	/**
	 * Rule based style, in order to use different styles based on parameters like current scale
	 */
	public class Rule extends EventDispatcher {
		
		private namespace sldns="http://www.opengis.net/sld";
		private namespace ogcns="http://www.opengis.net/ogc";

		public static const LEGEND_LINE:String = "Line";

		public static const LEGEND_POINT:String = "Point";

		public static const LEGEND_POLYGON:String = "Polygon";
		
		public static const LEGEND_CIRCLE:String = "Circle";

		private var _name:String = "";

		private var _title:String = "";

		private var _abstract:String = "";

		private var _minScaleDenominator:Number = NaN;

		private var _maxScaleDenominator:Number = NaN;

		private var _filter:IFilter = null;

		private var _symbolizers:Vector.<Symbolizer> = new Vector.<Symbolizer>();
		
		private var _maxWidth:Number = -1;
		private var _maxHeight:Number = -1;

		public function Rule() {
		}

		/**
		 * Name of the Rule
		 */
		public function get name():String {

			return this._name;
		}

		public function set name(value:String):void {

			this._name = value;
		}

		/**
		 * Human readable short description (a few words and less than one line preferably)
		 */
		public function get title():String {

			return this._title;
		}

		public function set title(value:String):void {

			this._title = value;
		}

		/**
		 * Human readable description that may be several paragraph long
		 */
		public function get abstract():String {

			return this._abstract;
		}

		public function set abstract(value:String):void {

			this._abstract = value;
		}

		/**
		 * The minimum scale at which the rule is active
		 */
		public function get minScaleDenominator():Number {

			return this._minScaleDenominator;
		}

		public function set minScaleDenominator(value:Number):void {

			this._minScaleDenominator = value;
		}

		/**
		 * The maximum scale at which the rule is active
		 */
		public function get maxScaleDenominator():Number {

			return this._maxScaleDenominator;
		}

		public function set maxScaleDenominator(value:Number):void {

			this._maxScaleDenominator = value;
		}

		/**
		 * A filter used to determine if the rule is active for given feature
		 */
		public function get filter():IFilter {

			return this._filter;
		}

		public function set filter(value:IFilter):void {

			this._filter = value;
		}

		/**
		 * The list of symbolizers defining the ruless
		 */
		public function get symbolizers():Vector.<Symbolizer> {

			return this._symbolizers;
		}

		public function set symbolizers(value:Vector.<Symbolizer>):void {

			this._symbolizers = value;
		}
		
		public function clone():Rule{
			
			var rule:Rule = new Rule();
			rule._abstract = this._abstract;
			if(this.filter != null){
			  rule._filter = this._filter.clone();
			}
			rule._maxScaleDenominator = this._maxScaleDenominator;
			rule._minScaleDenominator = this._minScaleDenominator;
			rule._name = this._name;
			if(this._symbolizers != null){
			  var length:uint = this._symbolizers.length;
			  var symbolizersClone:Vector.<Symbolizer> = new Vector.<Symbolizer>();
			  for(var i:uint=0; i<length;i++){
				symbolizersClone[i] = this._symbolizers[i].clone();
			  }
			  rule._symbolizers = symbolizersClone;
		    }
			rule._title = this._title;
			return rule;
		}

		// TODO: Externalise all the legend rendering stuff to a renderer class
		/**
		 * Renders the legend for the rule on given DisplayObject
		 */
		public function getLegendGraphic(type:String, maxWidth:Number = -1, maxHeight:Number = -1):DisplayObject {

			var result:Sprite = new Sprite();
			this._maxWidth = maxWidth;
			this._maxHeight = maxHeight;

			var drawMethod:Function;
			switch (type) {

				case LEGEND_POINT:  {

					drawMethod = this.drawPoint;
					break;
				}
				case LEGEND_LINE:  {

					drawMethod = this.drawLine;
					break;
				}
				case LEGEND_CIRCLE:
					drawMethod = this.drawCircle;
					break;
				default:  {

					drawMethod = this.drawPolygon;
				}

			}

			for each (var symbolizer:Symbolizer in this.symbolizers) {
				var layer:Sprite = new Sprite();
				result.addChild(layer);
				symbolizer.configureGraphics(layer.graphics, null);
				drawMethod.apply(this, [symbolizer, layer]);
			}

			return result;
		}
		
		public function get sld():String {
			// gen sld
			var res:String = "<sld:Rule>\n";
			
			if(this.title)
				res+="<sld:Title>"+this.title+"</sld:Title>\n";
			if(this.abstract)
				res+="<sld:Abstract>"+this.abstract+"</sld:Abstract>\n";
			else
				res+="<sld:Abstract></sld:Abstract>\n";
			if(this.name)
				res+="<sld:Name>"+this.name+"</sld:Name>\n";
			
			if(!isNaN(this.minScaleDenominator)) {
				res+="<sld:MinScaleDenominator>"+this.minScaleDenominator+"</sld:MinScaleDenominator>\n";
			}
			if(!isNaN(this.maxScaleDenominator)) {
				res+="<sld:MaxScaleDenominator>"+this.maxScaleDenominator+"</sld:MaxScaleDenominator>\n";
			}
			var tmp:String;
			for each (var symbolizer:Symbolizer in this.symbolizers) {
				tmp = symbolizer.sld;
				if(tmp)
					res+=tmp;
			}
			if(this.filter) {
				tmp = this.filter.sld;
				if(tmp)
					res+=tmp;
			}
			res+="</sld:Rule>\n";
			return res;
		}
		
		public function set sld(sldRule:String):void {
			use namespace sldns;
			use namespace ogcns;
			var dataXML:XML = new XML(sldRule);
			this.title = null;
			this.name = null;
			this.abstract = null;
			this.minScaleDenominator = NaN;
			this.maxScaleDenominator = NaN;
			if(!this.symbolizers)
				this.symbolizers = new Vector.<Symbolizer>();
			while(this.symbolizers.length>0) {
				this.symbolizers.pop();
			}
			if(this._filter)
				this._filter = null;
			
			//title
			if(dataXML.Title[0])
				this.title = dataXML.Title[0];
			//name
			if(dataXML.Name[0])
				this.name = dataXML.Name[0];
			//astract
			if(dataXML.Abstract[0])
				this.abstract = dataXML.Abstract[0];
			//minScaleDenominator
			if(dataXML.MinScaleDenominator[0])
				this.minScaleDenominator = Number(dataXML.MinScaleDenominator[0]);
			//maxScaleDenominator
			if(dataXML.MaxScaleDenominator[0])
				this.maxScaleDenominator = Number(dataXML.MaxScaleDenominator[0]);
			var childs:XMLList = dataXML.children();
			var symb:Symbolizer = null;
			for each(dataXML in childs) {
				switch (dataXML.localName()) {
					case "PolygonSymbolizer":
						symb = new PolygonSymbolizer();
						break;
					case "PointSymbolizer":
						symb = new PointSymbolizer();
						break;
					case "LineSymbolizer":
						symb = new LineSymbolizer();
						break;
					case "TextSymbolizer":
						symb = new TextSymbolizer();
						break;
					case "Filter":
						if(this._filter)
							continue;
						var filter:XMLList = dataXML.children();
						var node:XML;
						if(filter.length()==0)
							continue;
						node = filter[0];
						switch (node.localName()) {
							case "PropertyIsEqualTo":
							case "PropertyIsNotEqualTo":
							case "PropertyIsLessThan":
							case "PropertyIsGreaterThan":
							case "PropertyIsLessThanOrEqualTo":
							case "PropertyIsGreaterThanOrEqualTo":
							case "PropertyIsLike":
							case "PropertyIsNull":
							case "PropertyIsBetween":
								this._filter = new Comparison(null,null);
								break;
						}
						if(this._filter)
							this._filter.sld = dataXML;
						break;
					//TODO other filters
				}
				if(symb) {
					symb.sld = dataXML.toString();
					this.symbolizers.push(symb);
					symb = null;
				}
			}
		}

		private function drawLine(symbolizer:Symbolizer, canvas:Sprite):void {
			
			var delta:Number = -1;
			
			if (symbolizer && (symbolizer as LineSymbolizer).stroke)
			{
				delta = Math.round((symbolizer as LineSymbolizer).stroke.width);
				
				if (delta > 19) {
					delta = 19;
				}
				
				canvas.graphics.lineStyle(delta, (symbolizer as LineSymbolizer).stroke.color, 
					(symbolizer as LineSymbolizer).stroke.opacity, false, 
					LineScaleMode.NORMAL, (symbolizer as LineSymbolizer).stroke.linecap, 
					(symbolizer as LineSymbolizer).stroke.linejoin);
			}
			
			var res:Number = 0;
			if (delta >= 1)
				res = Math.round(delta) / 2;
			
			canvas.graphics.moveTo(5 + res, 25 - res);
			canvas.graphics.curveTo(5 + res, 15, 15, 15);
			canvas.graphics.curveTo(25 - res, 15, 25 - res, 5 + res);
			if(_maxWidth > 0){
				canvas.width = _maxWidth;
			}
			if(_maxHeight > 0){
				canvas.height = _maxHeight;
			}
			
		}

		private function drawPoint(symbolizer:Symbolizer, canvas:Sprite):void {
			var _do:DisplayObject;
			if (symbolizer is PointSymbolizer) {

				var pointSymbolizer:PointSymbolizer = (symbolizer as PointSymbolizer);
				if (pointSymbolizer.graphic) {
					if (pointSymbolizer.graphic) {
						canvas.alpha = pointSymbolizer.graphic.opacity;
						var size:Number = pointSymbolizer.graphic.getSizeValue();
						for each(var mark:Object in pointSymbolizer.graphic.graphics) {
							if(mark is Mark) {
								var layer:Sprite = new Sprite();
								canvas.addChild(layer);
								this.drawMark(mark as Mark, layer, size);
							}
							else if(mark is ExternalGraphic) {
								_do = (mark as ExternalGraphic).getDisplayObject(null,size,false);
								_do.x+=15;
								_do.y+=15;
								canvas.addChild(_do);
							}
						}
						if(_maxWidth > 0 && _maxWidth < canvas.width){
							canvas.width = _maxWidth;
						}
						if(_maxHeight > 0 && _maxHeight < canvas.height){
							canvas.height = _maxHeight;
						}
								
					}
				}
			} else if(symbolizer is TextSymbolizer) {
				var ts:TextSymbolizer = symbolizer as TextSymbolizer;
				var tempSize:Number = ts.font.size;
				ts.font.size = 3;
				_do = ts.getTextField("Text",new Pixel(0,0));
				_do.x= 0;//10 - _do.width / 2;
				_do.y= 0;//10;
				canvas.addChild(_do);
				if(_maxWidth > 0){
					canvas.width = _maxWidth;
				}
				if(_maxHeight > 0){
					canvas.height = _maxHeight;
				}
				ts.font.size = tempSize;
			}
		}

		protected function drawMark(mark:Mark, shape:Sprite, size:Number):void {
			
			var strokeWidth:Number = 0;
			
			if (size > 20)
				size = 20;
			
			if (mark && mark.stroke) 
			{
				strokeWidth = mark.stroke.width;
				if (strokeWidth > 10) 
				{
					strokeWidth = 10;
				}
			}
			
			if (strokeWidth + size > 20)
			{
				size = size - ((strokeWidth + size) - 20);
			}
			
			if(mark.fill)
				mark.fill.configureGraphics(shape.graphics, null);
			if(mark.stroke)
				shape.graphics.lineStyle(strokeWidth, mark.stroke.color, 
					mark.stroke.opacity, false, 
					LineScaleMode.NORMAL, mark.stroke.linecap, 
					mark.stroke.linejoin);
			
			
			
			mark.drawMark(shape,size);
			shape.x+=15;
			shape.y+=15;
		}

		private function drawPolygon(symbolizer:Symbolizer, canvas:Sprite):void {
			
			var delta:Number = -1;
			
			if (symbolizer && (symbolizer as PolygonSymbolizer).stroke)
			{
				delta = Math.round((symbolizer as PolygonSymbolizer).stroke.width);
				
				if (delta > 10) {
					delta = 10;
				}
				
				canvas.graphics.lineStyle(delta, (symbolizer as PolygonSymbolizer).stroke.color, 
					(symbolizer as PolygonSymbolizer).stroke.opacity, false, 
					LineScaleMode.NORMAL, (symbolizer as PolygonSymbolizer).stroke.linecap, 
					(symbolizer as PolygonSymbolizer).stroke.linejoin);
			}

			var res:Number = 0;
			if (delta >= 1)
				res = Math.round(delta) / 2;
			
			canvas.graphics.moveTo(5 + res, 5 + res);
			canvas.graphics.lineTo(25 - res, 5 + res);
			canvas.graphics.lineTo(25 - res, 25 - res);
			canvas.graphics.lineTo(5 + res, 25 - res);
			canvas.graphics.lineTo(5 + res, 5 + res);
			if(_maxWidth > 0){
				canvas.width = _maxWidth;
			}
			if(_maxHeight > 0){
				canvas.height = _maxHeight;
			}
			
		}
		
		private function drawCircle(symbolizer:Symbolizer,canvas:Sprite):void{
			var delta:Number = -1;
			
			if (symbolizer && (symbolizer as PolygonSymbolizer).stroke)
			{
				delta = Math.round((symbolizer as PolygonSymbolizer).stroke.width);
				
				if (delta > 10) {
					delta = 10;
				}
				
				canvas.graphics.lineStyle(delta, (symbolizer as PolygonSymbolizer).stroke.color, 
					(symbolizer as PolygonSymbolizer).stroke.opacity, false, 
					LineScaleMode.NORMAL, (symbolizer as PolygonSymbolizer).stroke.linecap, 
					(symbolizer as PolygonSymbolizer).stroke.linejoin);
			}
			
			var res:Number = 0;
			if (delta >= 1)
				res = Math.round(delta) / 2;
			
			canvas.graphics.moveTo(5 + res, 15);
			canvas.graphics.curveTo(5+res+1, 5+res+1, 15, 5+res);
			canvas.graphics.curveTo(25-res-1, 5+res+1, 25-res, 15);
			canvas.graphics.curveTo(25-res-1, 25-res-1, 15, 25-res);
			canvas.graphics.curveTo(5+res+1, 25-res-1, 5+res, 15);
			
			if(_maxWidth > 0){
				canvas.width = _maxWidth;
			}
			if(_maxHeight > 0){
				canvas.height = _maxHeight;
			}
		}
	}
}