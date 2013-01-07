package org.openscales.core.format
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LabelFeature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.request.DataRequest;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.Fill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.font.Font;
	import org.openscales.core.style.graphic.ExternalGraphic;
	import org.openscales.core.style.graphic.Graphic;
	import org.openscales.core.style.graphic.IGraphic;
	import org.openscales.core.style.graphic.Mark;
	import org.openscales.core.style.halo.Halo;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.ArrowSymbolizer;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.style.symbolizer.TextSymbolizer;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;
	
	//use namespace os_internal;
	
	/**
	 * Read KML 2.0 and 2.2 file format.
	 */
	
	public class KMLFormat extends Format
	{
		[Embed(source="/assets/images/marker-blue.png")]
		private var _defaultImage:Class;
		
		//private namespace opengis="http://www.opengis.net/kml/2.2";
		//private namespace google="http://earth.google.com/kml/2.0";
		private var _proxy:String;
		private var _kmlns:Namespace = new Namespace("http://earth.google.com/kml/2.0");
                private var _internalns:Namespace = null;
		private var _externalImages:Object = {};
		private var _images:Object = {};
		
		// features
		private var iconsfeatures:Vector.<Feature> = new Vector.<Feature>();
		private var linesfeatures:Vector.<Feature> = new Vector.<Feature>();
		private var labelfeatures:Vector.<Feature> = new Vector.<Feature>();
		private var polygonsfeatures:Vector.<Feature> = new Vector.<Feature>();
		// styles
		private var _styleList:HashMap = new HashMap();
		
		private var _userDefinedStyle:Style = null;
		
		//items to exclude from extendedData
		private var _excludeFromExtendedData:Array = new Array("id", "name", "description", "popupContentHTML", "label");
		
		public function KMLFormat() {}
		
		/**
		 * Getters and Setters
		 */ 
		public function get proxy():String
		{
			return _proxy;
		}
		
		public function get excludeFromExtendedData():Array
		{
			return _excludeFromExtendedData;
		}
		
		public function set proxy(value:String):void
		{
			_proxy = value;
		}
		
		
		public function get userDefinedStyle():Style
		{
			return _userDefinedStyle;
		}
		
		public function set userDefinedStyle(value:Style):void
		{
			_userDefinedStyle = value;
		}
		
		/**
		 * @private
		 * Polygon styles read from KML (hashmap with style's id as key)
		 */ 
		os_internal function get polygonStyles():Object
		{
			return null;
		}
		
		/**
		 * @private
		 * Point styles read from KML (hashmap with style's id as key)
		 */ 
		os_internal function get pointStyles():Object
		{
			return null;
		}
		
		/**
		 * @private
		 * Line styles read from KML (hashmap with style's id as key)
		 */ 
		os_internal function get lineStyles():Object
		{
			return null;
		}
		
		/**
		 * @private
		 */ 
		os_internal function set polygonStyles(value:Object):void
		{
			
		}
		
		/**
		 * @private
		 */ 
		os_internal function set pointStyles(value:Object):void
		{
			
		}
		
		/**
		 * @private
		 */ 
		os_internal function set lineStyles(value:Object):void
		{
			
		}
		
		/**
		 * Read name
		 *
		 * @param data data to read/parse
		 * @return name of KML layer
		 */
		public function readName(data:Object):String {
			var dataXML:XML = data as XML;
			if(!dataXML)
				return null;
			
			//use namespace google;
			//use namespace opengis;
			
			var name:String = "";
			if (dataXML && dataXML.*::name[0])
                                name = dataXML.*::name[0].toString();
                        else {
                                if (dataXML && dataXML.*::Document[0])
                                {
                                        var document:XML = dataXML.*::Document[0];
                                        if (document.*::name[0])
                                                name = dataXML.*::Document[0].*::name[0].toString();
                                }
                        }
			
			return name;
			
		}
			
		/**
		 * Read data
		 *
		 * @param data data to read/parse
		 * @return array of features (polygons, lines and points)
		 * @call loadStyles (only if the user does not set a style)
		 * @call loadPlacemarks (to extract the geometries)
		 */
		override public function read(data:Object):Object {
			var dataXML:XML = data as XML;
			
			//use namespace google;
			//use namespace opengis;
			
			if(!this.userDefinedStyle)
			{
				var styles:XMLList = dataXML..*::Style;
				loadStyles(styles.copy());
			}
			
			var placemarks:XMLList = dataXML..*::Placemark;
			return readPlacemarks(placemarks);
	
		}
		
		/**
		 * return the RGB color of a kml:color
		 */
		private function KMLColorsToRGB(data:String):Number {
			var color:String = data.substr(6,2);
			color = color+data.substr(4,2);
			color = color+data.substr(2,2);
			return parseInt(color,16);
		}
		
		/**
		 * Return the alpha part of a kml:color
		 */
		private function KMLColorsToAlpha(data:String):Number {
			return parseInt(data.substr(0,2),16)/255;
		}
		
		/**
		 * load styles
		 * This function is called only if the user does not set the userDefinedStyle attribute
		 * @calls KMLColorsToRGB
		 * @calls KMLColorsToAlpha
		 */
		public function loadStyles(styles:XMLList):void {
			
			//use namespace google;
			//use namespace opengis;
			//var styleMap:HashMap = null;
			for each(var style:XML in styles) {
				
				var id:String = "";
				if(style.@*::id=="")
					continue;
				id = "#"+style.@*::id.toString();

				_styleList.put(id, getStyle(style));		
			}
		}
		
		public function getStyle(style:XML):Style 
		{
			if(style == null)
				return null;
			
			var _style:Style = new Style();
			
			// Read the style id
			if (style.@*::id.length() > 0)
			{
				_style.name = style.@*::id;
			}else
			{
				return null;
			}
			var currentRule:Rule = new Rule();
			_style.rules.push(currentRule);
			
			var styleList:XMLList = style.children();
			var numberOfStyles:uint = styleList.length();
			var i:uint;
			var outLineSymbolizer:LineSymbolizer;
			
			for(i = 0; i < numberOfStyles; i++)
			{
				if(styleList[i].localName() == "IconStyle") 
				{
					var iconStyle:XMLList = styleList[i]..*::Icon;
					var href:XMLList = null;
					if(iconStyle.length() > 0)
					{
						href = iconStyle[0]..*::href;		
					}
					if (href)
					{
						var xOffSet:Number = 0.5;
						var xUnit:String = "fraction";
						var yOffSet:Number = 0.5;
						var yUnit:String = "fraction";
						var hotSpot:XMLList = styleList[i]..*::hotSpot;
						if (hotSpot.length() > 0)
						{
							if (hotSpot[0].@*::x.length() > 0)
								xOffSet = hotSpot[0].@*::x;
							if (hotSpot[0].@*::xunits.length() > 0)
								xUnit = hotSpot[0].@*::xunits;
							if (hotSpot[0].@*::y.length() > 0)
								yOffSet = hotSpot[0].@*::y;
							if (hotSpot[0].@*::yunits.length() > 0)
								yUnit = hotSpot[0].@*::yunits;
						}
						var psym:PointSymbolizer = new PointSymbolizer(new Graphic());
						var link:String = href.toString();
						var extGraph:ExternalGraphic = new ExternalGraphic(link);
						if(link.indexOf(".jpg",link.length-5) || link.indexOf(".jpeg",link.length-6))
							extGraph.format = "image/jpg";
						extGraph.xOffset = xOffSet;
						extGraph.xUnit = xUnit;
						extGraph.yOffset = yOffSet;
						extGraph.yUnit = yUnit;
						psym.graphic.graphics.push(extGraph);
						currentRule.symbolizers.push(psym);
					}
					else
					{
						var iconColor:Number;
						var iconAlpha:Number = 1;
						var iconRotation:Number = 0;
						var colorStyle:XMLList = styleList[i]..*::color;
						if(colorStyle.length() > 0) 
						{
							iconColor = KMLColorsToRGB(colorStyle[0].toString());
							iconAlpha = KMLColorsToAlpha(colorStyle[0].toString());
						}
						var iconFill:SolidFill = new SolidFill();
						iconFill.color = iconColor;
						var scaleStyle:XMLList = styleList[i]..*::scale;
						/*if(scaleStyle.length() > 0)
							obj["scale"] = Number(scaleStyle[0].toString());
						*/
						var headingStyle:XMLList = styleList[i]..*::heading;
						if(headingStyle.length() > 0) //0 to 360°
							iconRotation = Number(headingStyle[0].toString());
						// TODO implement offset support + rotation effect
						var psym2:PointSymbolizer = new PointSymbolizer();
						psym2.graphic.size = 6;
						psym2.graphic.opacity = iconAlpha;
						psym2.graphic.rotation = iconRotation;
						psym2.graphic.graphics.push(new Mark(Mark.WKN_SQUARE,iconFill));
						currentRule.symbolizers.push(psym2);
					}
				}
				else if(styleList[i].localName() == "LineStyle") 
				{
					var Lcolor:Number = 0x96A621;
					var Lalpha:Number = 1;
					var Lwidth:Number = 1;
					
					var lineColor:XMLList = styleList[i]..*::color;
					if(lineColor.length() > 0) 
					{
						Lcolor = KMLColorsToRGB(lineColor[0].toString());
						Lalpha = KMLColorsToAlpha(lineColor[0].toString());
					}
					
					var lineWidth:XMLList = styleList[i]..*::width;
					if(lineWidth.length() > 0) 
					{
						Lwidth = parseInt(lineWidth[0].toString());
					}
					
					
					var extensionLine:XMLList = styleList[i]..*::ListStyleSimpleExtensionGroup;
					var leftArrowMarker:String;
					var rightArrowMarker:String;
					var isArrow:Boolean = false;
					if (extensionLine.length() > 0)
					{
						leftArrowMarker = extensionLine[0].@*::leftArrow;
						rightArrowMarker = extensionLine[0].@*::rightArrow;
						isArrow = true;
					}
					
					if (isArrow)
					{
						
						var leftMarker:Graphic;
						var rightMarker:Graphic;
						var mark:Mark;
						if (leftArrowMarker != "none")
						{
							leftMarker = new Graphic();
							mark = new Mark();
							mark.wellKnownGraphicName = leftArrowMarker;
							mark.stroke = new Stroke(Lcolor, Lwidth, Lalpha);
							leftMarker.graphics.push(mark);
							if (Lwidth < 3) {
								leftMarker.size = 12;
							}
							else
								leftMarker.size = 4*Lwidth;
						}
						
						if (rightArrowMarker != "none")
						{
							rightMarker = new Graphic();
							mark = new Mark();
							mark.wellKnownGraphicName = leftArrowMarker;
							mark.stroke = new Stroke(Lcolor, Lwidth, Lalpha);
							rightMarker.graphics.push(mark);
							if (Lwidth < 3) {
								rightMarker.size = 12;
							}
							else
								rightMarker.size = 4*Lwidth;
						}
						currentRule.symbolizers.push(new ArrowSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha), leftMarker, rightMarker));
						outLineSymbolizer = new LineSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha));
					}else{
						currentRule.symbolizers.push(new LineSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha)));
						outLineSymbolizer = new LineSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha));
					}
				}
				else if(styleList[i].localName() == "LabelStyle") 
				{
					var ts:TextSymbolizer = new TextSymbolizer();
					ts.font = new Font();
					ts.halo = new Halo();
					ts.halo.radius = 0;

					var _Lwidth:Number = 1;
					
					var subNode:XMLList = styleList[i]..*::color;
					if(subNode.length() > 0) 
					{
						ts.font.color = KMLColorsToRGB(subNode[0].toString());
						ts.font.opacity = KMLColorsToAlpha(subNode[0].toString());
					}
					subNode = styleList[i]..*::scale;
					if(subNode.length() > 0 && !isNaN(Number(subNode[0].toString()))) 
					{
						ts.font.size = Number(subNode[0].toString())*10;
					}
					
					var extensionLabel:XMLList = styleList[i]..*::LabelStyleSimpleExtensionGroup;
					var tmpString:String;
					if (extensionLabel.length() > 0)
					{
						tmpString = extensionLabel[0].@*::propertyName;
						if(tmpString && tmpString!="")
							ts.propertyName = tmpString;
						
						tmpString = extensionLabel[0].@*::fontFamily;
						if(tmpString && tmpString!="")
							ts.font.family = tmpString;
						
						tmpString = extensionLabel[0].@*::bold;
						if(tmpString && tmpString!="")
							ts.font.weight = tmpString;
						
						tmpString = extensionLabel[0].@*::italic;
						if(tmpString && tmpString!="")
							ts.font.style = tmpString;
						
						tmpString = extensionLabel[0].@*::haloColor;
						if(tmpString && tmpString!="")
							ts.halo.color = Number(tmpString);
						
						tmpString = extensionLabel[0].@*::haloRadius;
						if(tmpString && tmpString!="")
							ts.halo.radius = Number(tmpString);
						
						tmpString = extensionLabel[0].@*::haloOpacity;
						if(tmpString && tmpString!="")
							ts.halo.opacity = Number(tmpString);
					}
					currentRule.symbolizers.push(ts);
					outLineSymbolizer = null;
				}
				else if(styleList[i].localName() == "PolyStyle") 
				{
					var pColor:Number;
					var pAlpha:Number;
					var pFill:SolidFill;
					var pStroke:Stroke;
					
					var polyColor:XMLList = styleList[i]..*::color;
					if(polyColor.length() > 0) 
					{
						//the style of the polygon itself
						pColor = KMLColorsToRGB(polyColor[0].toString());
						pAlpha = KMLColorsToAlpha(polyColor[0].toString());
						pFill = new SolidFill();
						pFill.color = pColor;
						pFill.opacity = pAlpha;
					}
					
					var pPs1:PolygonSymbolizer;
					var polyFill:XMLList = styleList[i]..*::fill;
					//if the polygon shouldn't be filled
					if(polyFill.length() && polyFill[0].toString() == "0") {
						pFill = null;
					}
					
					var polyOutline:XMLList = styleList[i]..*::outline;
					//the style of the outline (the contour of the polygon)
					if(polyOutline.length() == 0 || polyOutline[0].toString() == "1") 
					{
						if (outLineSymbolizer)
						{
							pStroke= outLineSymbolizer.stroke;
						}
					}
					pPs1 = new PolygonSymbolizer(pFill, pStroke);
					currentRule.symbolizers.push(pPs1);
				}	
			}
			return _style;
		}
		
		/**
		 * Reads a list of <code>Placemark</code>s KML tags and creates <code>Feature</code>s
		 * 
		 * @param placemarks A list of <code>Placemark</code>s KML tags
		 * @return A vector of <code>Feature</code>s
		 */
		public function readPlacemarks(placemarks:XMLList):Vector.<Feature> 
		{
			//use namespace google;
			//use namespace opengis;
			
			for each(var placemark:XML in placemarks) {
				var coordinates:Array;
				var point:Point;
				var htmlContent:String = "";
				var attributes:Object = new Object();
				var localStyle:Style;
				var localStyles:XMLList = placemark..*::Style;
				var attributeName:String = "";
				
				this._internalns = placemark.namespace() ? placemark.namespace() : this._kmlns;
				
				//there can be a Style defined inside the Placemark element
				//in this case, there is no styleUrl element and the Style element doesn't have an ID
				if(localStyles.length()== 1) 
				{
					localStyle = this.getStyle(localStyles[0]);
				}
				if(placemark.name != undefined) 
				{
					attributes["name"] = placemark.*::name.text();
					htmlContent = htmlContent + "<b>" + placemark.*::name.text() + "</b><br />";   
				}
				if(placemark.description != undefined) 
				{
					attributes["description"] = placemark.*::description.text();
					htmlContent = htmlContent + placemark.*::description.text() + "<br />";
				}
				
				if(placemark.id != undefined) 
				{
					attributes["id"] = placemark.*::id.text();
					htmlContent = htmlContent + placemark.*::description.text() + "<br />";
				}
				
				for each(var extendedData:XML in placemark.ExtendedData.Data) 
				{	
					if(extendedData.*::displayName.text() != undefined) {
						attributeName = extendedData.*::displayName.text();
						if(excludeFromExtendedData.indexOf(attributeName) < 0) {
							attributes[attributeName] = extendedData.value.text();
						}
					} else {
						attributeName = extendedData.@*::name;
						if(excludeFromExtendedData.indexOf(attributeName) < 0) {
							attributes[attributeName] = extendedData.value.text();
						}
					}
					
					htmlContent = htmlContent + "<b>" + attributeName + "</b> : " + extendedData.value.text() + "<br />";
				}
				
				for each(var simpleExtendedData:XML in placemark.*::ExtendedData.*::SchemaData.*::SimpleData) 
				{	
					attributeName = simpleExtendedData.@*::name;
					if(excludeFromExtendedData.indexOf(attributeName) < 0) {
						attributes[attributeName] = simpleExtendedData.text();
					}
					
					htmlContent = htmlContent + "<b>" + attributeName + "</b> : " + simpleExtendedData.text() + "<br />";
				}
				attributes["popupContentHTML"] = htmlContent;	
				var _id:String;
				
				var localns:Namespace = this._internalns;
				
				// LineStrings
				if(placemark.localns::LineString != undefined)
				{
					var _Lstyle:Style = null;
					if(this.userDefinedStyle)
					{
						_Lstyle = this.userDefinedStyle;	
					}
					else
					{
						_Lstyle = Style.getDefaultLineStyle();
						if(localStyle) 
						{
							_Lstyle = localStyle;
						}
						else if(placemark.localns::styleUrl != undefined)
						{
							_id = placemark.localns::styleUrl.text();
							if(_styleList.getValue(_id))
								_Lstyle = _styleList.getValue(_id);
						}
					}
					linesfeatures.push(new LineStringFeature(this.loadLineString(placemark),attributes,_Lstyle));
				}
				// Polygons
				else if(placemark.localns::Polygon != undefined) 
				{
					var _pStyle:Style = null;
					if(this.userDefinedStyle)
					{
						_pStyle = this.userDefinedStyle;
					}
					else 
					{
						_pStyle = Style.getDefaultPolygonStyle();
						if(localStyle)
						{
							_pStyle = localStyle;
						}
						else if(placemark.*::styleUrl != undefined)
						{
							_id = readStyleUrlId(placemark.*::styleUrl);
							if(_styleList.getValue(_id))
								_pStyle = _styleList.getValue(_id);
						}
					}
					polygonsfeatures.push(new PolygonFeature(this.loadPolygon(placemark),attributes,_pStyle));
				}
				
				//MultiGeometry  
				else if (placemark.localns::MultiGeometry != undefined)
				{
					var numberOfGeom:uint;
					var i:uint;
					var components:Vector.<Geometry>;
					var geomStyle:Style = null; 
					
					var multiG:XML = placemark..*::MultiGeometry[0];
					var lines:XMLList = multiG..*::LineString;
					var polygons:XMLList = multiG..*::Polygon;
					var points:XMLList = multiG..*::Point;
					
					//multiLineString
					if(lines.length() > 0)
					{
						numberOfGeom = lines.length();
						components = new Vector.<Geometry>;
						for(i = 0; i < numberOfGeom; i++)
						{
							var LineCont:XML = new XML("<container></container>");
							LineCont.appendChild(lines[i]);
							components.push(this.loadLineString(LineCont));	
						}
						if(this.userDefinedStyle)
						{
							geomStyle = this.userDefinedStyle;	
						} else {
							geomStyle = Style.getDefaultLineStyle();
							if(localStyle) {
								geomStyle = localStyle;
							}
							else if(placemark.*::styleUrl != undefined)
							{
								_id = readStyleUrlId(placemark.*::styleUrl);
								if(_styleList.getValue(_id))
									geomStyle = _styleList.getValue(_id);
							}
						}
						linesfeatures.push(new MultiLineStringFeature(new MultiLineString(components),
						attributes,geomStyle));
					}

					//multiPolygon
					if(polygons.length() > 0)	
					{
						numberOfGeom = polygons.length();
						components = new Vector.<Geometry>;
						for(i = 0; i < numberOfGeom; i++)
						{
							var PolyCont:XML = new XML("<container></container>");
							PolyCont.appendChild(polygons[i]);
							components.push(this.loadPolygon(PolyCont));	
						}
						if(this.userDefinedStyle)
						{
							geomStyle = this.userDefinedStyle;	
						} else {
							geomStyle = Style.getDefaultPolygonStyle();
							if(localStyle) {
								geomStyle = localStyle;
							}
							else if(placemark.*::styleUrl != undefined)
							{
								_id = readStyleUrlId(placemark.*::styleUrl);
								if(_styleList.getValue(_id))
									geomStyle = _styleList.getValue(_id);
							}
						}
						
						polygonsfeatures.push(new MultiPolygonFeature(new MultiPolygon(components),
						attributes,geomStyle));
					}
					//multiPoint
					//only one icon can be referenced in an IconStyle so icons are not supported for multipoints
					if(points.length() > 0)
					{
						var pointCoords:Vector.<Number> = new Vector.<Number>;
						numberOfGeom = points.length();
						for(i = 0; i < numberOfGeom; i++)
						{
							coordinates = points[i]..*::coordinates.toString().split(",");
							pointCoords.push(Number(coordinates[0]));
							pointCoords.push(Number(coordinates[1]));
						}
						var multiPoint:MultiPoint = new MultiPoint(pointCoords);
						
						if(this.userDefinedStyle)
							iconsfeatures.push(new MultiPointFeature(multiPoint,attributes,this.userDefinedStyle));
						else if(localStyle) 
						{	
							//iconsfeatures.push(getPointFeature(point,hmLocalStyle.getValue("PointStyle"),attributes));
							iconsfeatures.push(new MultiPointFeature(multiPoint,attributes,localStyle));
						}
						else if(placemark.*::styleUrl != undefined) 
						{
							_id = readStyleUrlId(placemark.*::styleUrl);
							if(_styleList.getValue(_id))
							{
								//iconsfeatures.push(getPointFeature(point,pointStyles[_id],attributes));
								iconsfeatures.push(new MultiPointFeature(multiPoint,attributes,geomStyle = _styleList.getValue(_id)));
							} else 
							{
								iconsfeatures.push(new MultiPointFeature(multiPoint, attributes, Style.getDefaultPointStyle()));
							}
						}
						else
							iconsfeatures.push(new MultiPointFeature(multiPoint, attributes, Style.getDefaultPointStyle()));	
					}
				}

				else if(placemark.localns::Point != undefined)
				{
					coordinates = placemark.localns::Point.localns::coordinates.text().split(",");
					
					//Maybe it is a label
					var isLabel:Boolean = false;
					var textLabel:String = "";
					for each(var extData:XML in placemark.*::ExtendedData.Data) 
					{	
						if(extData.@*::name == "label") {
							isLabel = true
							textLabel = extData.value.text();
							break;
						}
					}
					
					if(isLabel) {
						var loc:Location = new Location(coordinates[0], coordinates[1]);
						var lf:LabelFeature = LabelFeature.createLabelFeature(loc, attributes);
						lf.text = textLabel;
						if(this.userDefinedStyle) {
							lf.style = this.userDefinedStyle;
						} 
						else if(placemark.*::styleUrl != undefined || localStyle) 
						{
							var labelStyle:Style = null;
							if(localStyle) 
							{
								labelStyle = localStyle;
							} 
							else 
							{
								_id = readStyleUrlId(placemark.*::styleUrl);
								if(_styleList.getValue(_id))
									labelStyle = _styleList.getValue(_id);
							}
							
							if(labelStyle) 
							{ // style
								lf.style = labelStyle;
							}
						}
						labelfeatures.push(lf);
					} else {
						point = new Point(coordinates[0], coordinates[1]);
						if (this.internalProjection != null, this.externalProjection != null) 
						{
							point.projection = this.externalProjection;
							point.transform(this.internalProjection);
						}
						if(this.userDefinedStyle) {
							iconsfeatures.push(new PointFeature(point, attributes, this.userDefinedStyle));
						} 
						else if(placemark.*::styleUrl != undefined || localStyle) 
						{
							var objStyle:Style = null;
							if(localStyle) 
							{
								objStyle = localStyle;
							} 
							else 
							{
								_id = readStyleUrlId(placemark.*::styleUrl);
								if(_styleList.getValue(_id))
									objStyle = _styleList.getValue(_id);
							}
							
							if(objStyle) 
							{ // style
								iconsfeatures.push(getPointFeature(point,objStyle,attributes));
							}
							else // no matching style
								iconsfeatures.push(new PointFeature(point, attributes, Style.getDefaultPointStyle()));
						}
						else // no style
							iconsfeatures.push(new PointFeature(point, attributes, Style.getDefaultPointStyle()));
					}
				}
			}
			
			return polygonsfeatures.concat(linesfeatures, iconsfeatures, labelfeatures);
		}
		
		private function getPointFeature(point:Point, objStyle:Style, attributes:Object):Feature {
			if(!objStyle)
				return null;
			if(this.userDefinedStyle)
				return new PointFeature(point, attributes,this.userDefinedStyle);
			else
				return new PointFeature(point, attributes, objStyle);
		}
		
		private function readStyleUrlId(styleUrlXMLList:XMLList):String{
			var id:String = styleUrlXMLList.text();
			
			id = id.substr(id.lastIndexOf("#"),id.length);
			
			return id;
		}
		
		/**
		 * Parse point styles without icon
		 */ 
		
		private function loadPointStyleWithoutIcon(style:Object):Style
		{
			var pointStyle:Style;
			pointStyle = Style.getDefaultPointStyle();
			
			if(style["color"] != undefined)
			{
				var _fill:SolidFill = new SolidFill(style["color"], style["alpha"]);
				var _stroke:Stroke = new Stroke(style["color"], style["alpha"]);
				var _symbolizer:PointSymbolizer = new PointSymbolizer();
				_symbolizer.graphic.graphics.push(new Mark(Mark.WKN_SQUARE, _fill, _stroke));
				//_symbolizer.graphic = _mark;
				var _rule:Rule = new Rule();
				_rule.symbolizers.push(_symbolizer);
				pointStyle = new Style();
				pointStyle.rules.push(_rule);
			}
			return pointStyle;
		}
		
		/**
		 * Parse LineStrings
		 */ 
		
		private function loadLineString(placemark:XML):LineString
		{
			var coordinates:Array;
			var point:Point;
			
			var localns:Namespace = this._internalns;
			 
			var lineNode:XML= placemark..localns::LineString[0];
			XML.ignoreWhitespace = true;
			var lineData:String = lineNode..localns::coordinates[0].toString();
			
			lineData = lineData.split("\n").join("");
			lineData = lineData.split("\t").join("");
			
			lineData = lineData.replace(/^\s*(.*?)\s*$/g, "$1");
			coordinates = lineData.split(" ");
			
			var points:Vector.<Number> = new Vector.<Number>();
			var coords:String;
			for each(coords in coordinates)
			{
				var _coords:Array = coords.split(",");
				if(_coords.length<2)
					continue;
				point = new Point(_coords[0].toString(),
					_coords[1].toString());
				if (this.internalProjection != null, this.externalProjection != null) 
				{
					point.projection = this.externalProjection;
					point.transform(this.internalProjection);
				}
				points.push(point.x);
				points.push(point.y);
			}
			var line:LineString = new LineString(points);	
			return line;
		}
		
		/**
		 * Parse Polygons
		 * @call loadPolygonData to parse the coordinates
		 */ 
		private function loadPolygon(placemark:XML):Polygon
		{
                        var localns:Namespace = this._internalns;
			var polygon:XML = placemark..localns::Polygon[0];
			
			//exterior ring
			var outerBoundary:XML = polygon..localns::outerBoundaryIs[0];
			var ring:XML = outerBoundary..localns::LinearRing[0];
			
			var lines:Vector.<Geometry> = new Vector.<Geometry>(1);
			lines[0] = this.loadPolygonData(ring..localns::coordinates.toString());
			
			//interior ring
			var innerBoundary:XML = polygon..localns::innerBoundaryIs[0];
			if(innerBoundary) 
			{
				ring = innerBoundary..localns::LinearRing[0];
				try 
				{
					lines.push(this.loadPolygonData(ring..localns::coordinates.toString()));
				} 
				catch(e:Error) {}
			}
			
			return new Polygon(lines);
		}
		
		/**
		 * Parse polygon coordinates
		 */ 
		private function loadPolygonData(_Pdata:String):LinearRing
		{
			_Pdata = _Pdata.split("\n").join(" ");
			_Pdata = _Pdata.replace(/^\s*(.*?)\s*$/g, "$1");
			var coordinates:Array = _Pdata.split(" ");
			var Ppoints:Vector.<Number> = new Vector.<Number>();
			var Pcoords:String;
			var _Pcoords:Array;
			var point:Point;
			for each(Pcoords in coordinates) 
			{
				_Pcoords = Pcoords.split(",");
				if(_Pcoords.length<2)
					continue;
				point = new Point(_Pcoords[0].toString(),_Pcoords[1].toString());
				if (this.internalProjection != null, this.externalProjection != null) 
				{
					point.projection = this.externalProjection;
					point.transform(this.internalProjection);
				}
				Ppoints.push(point.x);
				Ppoints.push(point.y);
			}
			
			return new LinearRing(Ppoints);
		}
		
		/**
		 * Write empty file with specified document Name
		 */
		public function writeEmptyKmlFil(kmlName:String):Object
		{
			var kmlns:Namespace = new Namespace("","http://www.opengis.net/kml/2.2");
			var kmlFile:XML = new XML("<kml></kml>");
			kmlFile.addNamespace(kmlns);
			
			var doc:XML = new XML("<Document></Document>"); 
			kmlFile.appendChild(doc);
			var name:XML = new XML("<name>"+kmlName+"</name>");
			doc.appendChild(name);
			return "<?xml version='1.0' encoding='UTF-8'?>"+kmlFile.toString(); 
		}
		
		/**
		 * Write data
		 *
		 * @param features the features to build into a KML file
		 * @return the KML file (xml format)
		 * @call buildStyleNode
		 * @call buildPlacemarkNode
		 * the supported features are pointFeatures, lineFeatures and polygonFeatures
		 */
		
		override public function write(features:Object):Object
		{
			//todo write multigeometries
			var i:uint;
			var kmlns:Namespace = new Namespace("","http://www.opengis.net/kml/2.2");
			var kmlFile:XML = new XML("<kml></kml>");
			kmlFile.addNamespace(kmlns);
			
			var doc:XML = new XML("<Document></Document>"); 
			kmlFile.appendChild(doc);
			
			var listOfFeatures:Vector.<Feature> = features as Vector.<Feature>;
			var numberOfFeat:uint = listOfFeatures.length;
			if (numberOfFeat > 0 && listOfFeatures[0].layer)
			{
				var name:XML = new XML("<name>"+listOfFeatures[0].layer.displayedName+"</name>");
				doc.appendChild(name);
			}
			// gather Style list
			var styleHashMap:HashMap = new HashMap();
			for(i = 0; i < numberOfFeat; ++i)
			{
				if(listOfFeatures[i].style)
				{
					styleHashMap.put("#"+(listOfFeatures[i] as Feature).style.name, (listOfFeatures[i] as Feature).style);
				}
			}
			
			//build the style nodes first
			var keysArray:Array = styleHashMap.getKeys();
			var keyLength:Number = keysArray.length;
			for(i = 0; i < keyLength; ++i)
			{
				var style:XML = this.buildStyleNode(styleHashMap.getValue(keysArray[i]));
				if (style)
					doc.appendChild(style);
			}
			
			//build the placemarks
			for (i = 0; i < numberOfFeat; i++)
			{
				doc.appendChild(this.buildPlacemarkNode(listOfFeatures[i],i));
			}
			return "<?xml version='1.0' encoding='UTF-8'?>"+kmlFile.toString(); 
		}
		
		/**
		 * @return a kml placemark
		 * @call buildPolygonNode
		 * @call buildCoordsAsString 
		 */
		private function buildPlacemarkNode(feature:Feature,i:uint):XML
		{
			var lineNode:XML;
			var pointNode:XML;
			var extendedData:XML;
			
			var placemark:XML = new XML("<Placemark></Placemark>");
			var att:Object = feature.attributes;
			
			placemark.appendChild(new XML("<id>" + feature.name + "</id>"));
			if (att.hasOwnProperty("name") && att["name"] != "") {
				placemark.appendChild(new XML("<name>" + att["name"] + "</name>"));
			}
			else {
				//since we build the styles first, the feature will have an id for sure
				placemark.appendChild(new XML("<name>" + feature.name + "</name>"));
			}
			
			placemark.appendChild(new XML("<styleUrl>#" + feature.style.name + "</styleUrl>"));
			
			if (att.hasOwnProperty("description"))
				placemark.appendChild(new XML("<description><![CDATA[" + att["description"] + "]]></description>"));
			
			var coords:String;
			if(feature is LineStringFeature)
			{
				lineNode = new XML("<LineString></LineString>");
				var line:LineString = (feature as LineStringFeature).lineString;
				coords = this.buildCoordsAsString(line.getcomponentsClone());
				if(coords.length != 0)
					lineNode.appendChild(new XML("<coordinates>" + coords + "</coordinates>"));
				placemark.appendChild(lineNode);
			}
			else if(feature is PolygonFeature)
			{
				var poly:Polygon = (feature as PolygonFeature).polygon;
				placemark.appendChild(this.buildPolygonNode(poly));
			}
			else if(feature is PointFeature)
			{
				pointNode = new XML("<Point></Point>");
				var point:Point = (feature as PointFeature).point;
				pointNode.appendChild(new XML("<coordinates>" + point.x + "," + point.y + "</coordinates>"));
				placemark.appendChild(pointNode);
			}
			else if(feature is MultiPointFeature || feature is MultiLineStringFeature || feature is MultiPolygonFeature)
			{
				var multiGNode:XML = new XML("<MultiGeometry></MultiGeometry>");
				if(feature is MultiPointFeature)
				{
					var points:Vector.<Point> = (feature as MultiPointFeature).points.toVertices();
					var numberOfPoints:uint = points.length;
					for(i = 0; i < numberOfPoints; i++)
					{
						pointNode =	new XML("<Point></Point>");
						pointNode.appendChild(new XML("<coordinates>" + point.x + "," + point.y + "</coordinates>"));
						multiGNode.appendChild(pointNode);
						
					}
				}
				else if (feature is MultiLineStringFeature)
				{
					var lines:Vector.<Geometry> = (feature as MultiLineStringFeature).lineStrings.getcomponentsClone();
					var numberOfLines:uint = lines.length;
					for(i = 0; i < numberOfLines; i++)
					{
						var Line:LineString = lines[i] as LineString;
						coords = this.buildCoordsAsString(Line.getcomponentsClone());
						lineNode =	new XML("<LineString></LineString>");
						lineNode.appendChild(new XML("<coordinates>" + coords + "</coordinates>"));
						multiGNode.appendChild(lineNode);
						
					}	
				}
				else//multiPolygon
				{
					
				}
				placemark.appendChild(multiGNode);
			}
			
			//Donnees attributaires
			var data:XML;
			var displayName:XML;
			var value:XML;
			if(feature.layer || feature is LabelFeature) {
				extendedData =	new XML("<ExtendedData></ExtendedData>");
				if(feature is LabelFeature) {
					var l:Point = (feature as LabelFeature).geometry as Point;
					data = new XML("<Data name=\"label\"></Data>");
					value = new XML("<value>" + (feature as LabelFeature).text + "</value>");
					data.appendChild(value);
					extendedData.appendChild(data);
				}
				if(feature.layer) {
					var j:uint = feature.layer.attributesId.length;
					if(j>0 || feature is LabelFeature) {
						
						for(var i:uint = 0 ;i<j;++i) {
							var key:String = feature.layer.attributesId[i];
							//everything except name and description
							if(excludeFromExtendedData.indexOf(key) <0 ) {
								data = new XML("<Data name=\"attribute" + i + "\"></Data>");
								displayName = new XML("<displayName>" + key + "</displayName>");
								value = new XML("<value>" + att[key] + "</value>");
								data.appendChild(displayName);
								data.appendChild(value);
								extendedData.appendChild(data);
							}
						}
					}
				}
				placemark.appendChild(extendedData);
			}
			
			return placemark;
		}
		
		/**
		 * @return a polygon node
		 * the first ring is the outerBoundary; the others, if they exist, are innerBoundaries
		 */ 
		
		public function buildPolygonNode(poly:Polygon):XML
		{
			var coords:String;
			var polyNode:XML = new XML("<Polygon></Polygon>");
			var outerBoundary:XML = new XML("<outerBoundaryIs></outerBoundaryIs>");
			var extRingNode:XML = new XML("<LinearRing></LinearRing>");
			outerBoundary.appendChild(extRingNode);
			polyNode.appendChild(outerBoundary);
			
			var ringList:Vector.<Geometry> = poly.getcomponentsClone();
			var extRing:LinearRing = ringList[0] as LinearRing;
			coords = this.buildCoordsAsString(extRing.getcomponentsClone());
			if(coords.length != 0)
				extRingNode.appendChild(new XML("<coordinates>" + coords + "</coordinates>"));
			
			if(ringList.length > 1)
			{
				var l:uint = ringList.length;
				var i:uint;
				for(i = 1; i < l; i++)
				{
					var intRing:LinearRing = ringList[i] as LinearRing;
					var innerBoundary:XML = new XML("<innerBoundaryIs></innerBoundaryIs>");
					var intRingNode:XML = new XML("<LinearRing></LinearRing>");
					innerBoundary.appendChild(intRingNode);
					polyNode.appendChild(innerBoundary);
					
					coords = this.buildCoordsAsString(intRing.getcomponentsClone());
					if(coords.length != 0)
						intRingNode.appendChild(new XML("<coordinates>" + coords + "</coordinates>"));
				}
			}
			
			return polyNode;
		}
		
		/**
		 * @param the vector of coordinates of the geometry
		 * @return the coordinates as a string
		 * in kml coordinates are tuples consisting of longitude, latitude and altitude (optional)
		 * the geometries must be in 2D; the altitude is not supported    	
		 */
		
		public function buildCoordsAsString(coords:Vector.<Number>):String
		{
			var i:uint;
			var stringCoords:String = "";
			var numberOfPoints:uint = coords.length;
			for(i = 0; i < numberOfPoints; i += 2){
				stringCoords += String(coords[i])+",";
				stringCoords += String(coords[i+1]);
				if( i != (numberOfPoints -2))
					stringCoords += " ";
			}
			return stringCoords;
		}
		
		/**
		 * @param the feature and its index in the list of features to build (useful for the style ID)
		 * @return the xml style node
		 */ 
		
		private function buildStyleNode(style:Style):XML
		{
			var color:uint;
			var opacity:Number;
			var width:Number;
			var stroke:Stroke;
			var rules:Vector.<Rule> = style.rules;
			var symbolizers:Vector.<Symbolizer>;
			if(rules.length > 0)
			{
				symbolizers = rules[0].symbolizers;
			}
		
			//global style; can contain multiple Style types (Poly, Line, Icon)
			var placemarkStyle:XML = new XML("<Style></Style>");
			
			//Save the style id
			placemarkStyle.@id = style.name;
			
			if(!symbolizers)
				return null;
			
			var styleNode:XML = null;
			var extensionNode:XML=null;
			var symbLength:Number =symbolizers.length;
			
			// Boolean that track if a stroke style has been exported 
			//(to avoid stoke style duplication between polygon et line style)
			var strokeExported:Boolean = false;
			for (var i:int = 0; i < symbLength; ++i)
			{
				var symb:Symbolizer = symbolizers[i];
				if (symb is TextSymbolizer) {
					styleNode = new XML("<LabelStyle></LabelStyle>");
					var ts:TextSymbolizer = symb as TextSymbolizer;
					extensionNode = new XML("<LabelStyleSimpleExtensionGroup></LabelStyleSimpleExtensionGroup>");
					var addExtension:Boolean = false;
					if(ts.propertyName) {
						addExtension = true;
						extensionNode.@propertyName = ts.propertyName;
					}
					if(ts.font) {
						addExtension = true;
						styleNode.appendChild(this.buildColorNode(ts.font.color,ts.font.opacity));
						styleNode.colorMode = "normal";
						styleNode.scale = ts.font.size/10;
						if(ts.font.family) {
							extensionNode.@fontFamily = ts.font.family;
						}
						if(ts.font.weight == Font.BOLD) {
							extensionNode.@bold = Font.BOLD;
						}
						if(ts.font.style == Font.ITALIC) {
							extensionNode.@italic = Font.ITALIC;
						}
					}
					if (ts.halo)
					{
						addExtension = true;
						extensionNode.@haloColor = ts.halo.color;
						extensionNode.@haloRadius = ts.halo.radius;
						extensionNode.@haloOpacity = ts.halo.opacity;
					}
					if(addExtension)
						styleNode.appendChild(extensionNode);
					placemarkStyle.appendChild(styleNode);
				}
				else if (symb is LineSymbolizer)
				{
					if (!strokeExported)
					{
						styleNode = new XML("<LineStyle></LineStyle>");
						var lSym:LineSymbolizer = symb as LineSymbolizer;
						stroke = lSym.stroke;
						color = stroke.color;
						opacity = stroke.opacity;
						width = stroke.width;
						styleNode.appendChild(this.buildColorNode(color,opacity));
						styleNode.colorMode = "normal";
						styleNode.width = width;
						placemarkStyle.appendChild(styleNode);
						strokeExported = true;
						
						if (symb is ArrowSymbolizer)
						{
							extensionNode = new XML("<ListStyleSimpleExtensionGroup></ListStyleSimpleExtensionGroup>");
							if ((symb as ArrowSymbolizer).leftGraphic)
							{
								var leftMarker:Graphic = (symb as ArrowSymbolizer).leftGraphic;
								if(leftMarker.graphics
									&& leftMarker.graphics[0] is Mark)
								{
									extensionNode.@leftArrow = (leftMarker.graphics[0] as Mark).wellKnownGraphicName;
								} else {
									extensionNode.@leftArrow = "none";
								}
							}else{
								extensionNode.@leftArrow = "none";
							}
							if ((symb as ArrowSymbolizer).rightGraphic)
							{
								var rightMarker:Graphic = (symb as ArrowSymbolizer).leftGraphic;
								if(rightMarker.graphics.length > 0
									&& rightMarker.graphics[0] is Mark)
								{
									extensionNode.@rightArrow = (rightMarker.graphics[0] as Mark).wellKnownGraphicName;
								} else {
									extensionNode.@rightArrow = "none";
								}
							}else{
								extensionNode.@rightArrow = "none"
							}
							styleNode.appendChild(extensionNode);
						}
					}
				}else if (symb is PolygonSymbolizer)
				{
					styleNode = new XML("<PolyStyle></PolyStyle>");
					var polySym:PolygonSymbolizer = symb as PolygonSymbolizer;
					styleNode.outline = "0";
					if (polySym.stroke)
					{
						styleNode.outline = "1";
						if (!strokeExported)
						{
							var styleNode2:XML = new XML("<LineStyle></LineStyle>");
							var stroke2:Stroke = polySym.stroke;
							color = stroke2.color;
							opacity = stroke2.opacity;
							width = stroke2.width;
							styleNode2.appendChild(this.buildColorNode(color,opacity));
							styleNode2.colorMode = "normal";
							styleNode2.width = width;
							placemarkStyle.appendChild(styleNode2);	
							strokeExported = true;
						}
					}
					var fill:Fill = polySym.fill;
					if(fill is SolidFill)
					{
						styleNode.fill = "1";
						opacity = (fill as SolidFill).opacity;	
						color = (fill as SolidFill).color as uint;
					}
						
					else
					{
						styleNode.fill = "0";
						opacity = 0;
					}
					styleNode.appendChild(this.buildColorNode(color,opacity));
					styleNode.colorMode = "normal";	
					placemarkStyle.appendChild(styleNode);	
				}else if (symb is PointSymbolizer)
				{
					styleNode = new XML("<IconStyle></IconStyle>");
					var pointSym:PointSymbolizer = symb as PointSymbolizer;
					var graphic:Graphic = pointSym.graphic;
					if(!graphic || graphic.graphics.length==0)
						continue;
					var mark:IGraphic = graphic.graphics[0];
					
					// Switch between marker types
					if(mark is Mark)
					{
						var wkm:Mark = graphic as Mark;
						var solidFill:SolidFill
						if(wkm.fill is SolidFill)
							solidFill = wkm.fill as SolidFill;
						else
							solidFill = new SolidFill();
						styleNode.appendChild(this.buildColorNode(solidFill.color as uint, solidFill.opacity));
						styleNode.colorMode = "normal";
					}else if (mark is ExternalGraphic)
					{
						var iconNode:XML = new XML("<Icon></Icon>");
						
						var cm:ExternalGraphic = graphic as ExternalGraphic;
						var href:String = cm.onlineResource;
						iconNode.href = href;
						
						var hotSpotNode:XML = new XML("<hotSpot/>");
						hotSpotNode.@x = cm.xOffset;
						hotSpotNode.@xunits = cm.xUnit;
						hotSpotNode.@y = cm.yOffset;
						hotSpotNode.@yunits = cm.yUnit;
						
						styleNode.appendChild(iconNode);
						styleNode.appendChild(hotSpotNode);
					}else
					{
						//Not supported Marker
					}
					placemarkStyle.appendChild(styleNode);	
				}else
				{
					//Not supported symbolizer
				}
			}
			return placemarkStyle;
		}
		
		
		/**
		 * Build kml color tag
		 */ 
		private function buildColorNode(color:uint,opacity:Number):XML
		{
			var i:uint;
			var spareStringColor:String = "";
			var colorNode:XML = new XML("<color></color>");	
			var stringColor:String = color.toString(16);
			
			for (i = 0; i < (6 - stringColor.length); i++)
			{
				spareStringColor += "0";				
			}
			
			spareStringColor += stringColor;
			
			if(stringColor.length < 6)
				stringColor = spareStringColor;
			
			//in OpenScales, the feature opacity is between 0 and 1 (1 means 255 in KML)
			var KMLcolor:String = (opacity*255).toString(16) + stringColor.substr(4,2)
				+ stringColor.substr(2,2)+stringColor.substr(0,2);
			colorNode.appendChild(KMLcolor);
			return colorNode;
		}

	}
}

