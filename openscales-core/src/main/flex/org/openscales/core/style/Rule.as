package org.openscales.core.style {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import org.openscales.core.filter.IFilter;
	import org.openscales.core.style.graphic.ExternalGraphic;
	import org.openscales.core.style.graphic.IGraphic;
	import org.openscales.core.style.graphic.Mark;
	import org.openscales.core.style.marker.WellKnownMarker;
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

		public static const LEGEND_LINE:String = "Line";

		public static const LEGEND_POINT:String = "Point";

		public static const LEGEND_POLYGON:String = "Polygon";

		private var _name:String = "";

		private var _title:String = "";

		private var _abstract:String = "";

		private var _minScaleDenominator:Number = NaN;

		private var _maxScaleDenominator:Number = NaN;

		private var _filter:IFilter = null;

		private var _symbolizers:Vector.<Symbolizer> = new Vector.<Symbolizer>();

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
		public function getLegendGraphic(type:String):DisplayObject {

			var result:Sprite = new Sprite();

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
					res+=tmp+"\n";
			}
			if(this.filter) {
				tmp = this.filter.sld;
				if(tmp)
					res+=tmp+"\n";
			}
			res+="</sld:Rule>";
			return res;
		}
		
		public function set sld(sldRule:String):void {
			use namespace sldns;
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
					//TODO filters
				}
				if(symb) {
					symb.sld = dataXML.toString();
					this.symbolizers.push(symb);
					symb = null;
				}
			}
		}

		private function drawLine(symbolizer:Symbolizer, canvas:Sprite):void {
			canvas.graphics.moveTo(5, 25);
			canvas.graphics.curveTo(5, 15, 15, 15);
			canvas.graphics.curveTo(25, 15, 25, 5);
		}

		private function drawPoint(symbolizer:Symbolizer, canvas:Sprite):void {

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
								var _do:DisplayObject = (mark as ExternalGraphic).getDisplayObject(null,size,false);
								_do.x+=15;
								_do.y+=15;
								canvas.addChild(_do);
							}
						}
								
					}
				}
			} else if(symbolizer is TextSymbolizer) {
				var ts:TextSymbolizer = symbolizer as TextSymbolizer;
				canvas.addChild(ts.getTextField("Text",new Pixel(15,15)));
			}
		}

		protected function drawMark(mark:Mark, shape:Sprite, size:Number):void {
			if(mark.fill)
				mark.fill.configureGraphics(shape.graphics, null);
			if(mark.stroke)
				mark.stroke.configureGraphics(shape.graphics);
			mark.drawMark(shape,size);
			shape.x+=15;
			shape.y+=15;
		}

		private function drawPolygon(symbolizer:Symbolizer, canvas:Sprite):void {
			canvas.graphics.moveTo(5, 5);
			canvas.graphics.lineTo(25, 5);
			canvas.graphics.lineTo(25, 25);
			canvas.graphics.lineTo(5, 25);
			canvas.graphics.lineTo(5, 5);
		}
	}
}