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
	import org.openscales.core.style.marker.ArrowMarker;
	import org.openscales.core.style.marker.CustomMarker;
	import org.openscales.core.style.marker.Marker;
	import org.openscales.core.style.marker.WellKnownMarker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.ArrowSymbolizer;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LabelPoint;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;
	
	use namespace os_internal;
	
	/**
	 * Read KML 2.0 and 2.2 file format.
	 */
	
	public class KMLFormat extends Format
	{
		[Embed(source="/assets/images/marker-blue.png")]
		private var _defaultImage:Class;
		
		private namespace opengis="http://www.opengis.net/kml/2.2";
		private namespace google="http://earth.google.com/kml/2.0";
		private var _proxy:String;
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
		 * Read data
		 *
		 * @param data data to read/parse
		 * @return array of features (polygons, lines and points)
		 * @call loadStyles (only if the user does not set a style)
		 * @call loadPlacemarks (to extract the geometries)
		 */
		override public function read(data:Object):Object {
			var dataXML:XML = data as XML;
			
			use namespace google;
			use namespace opengis;
			
			if(!this.userDefinedStyle)
			{
				var styles:XMLList = dataXML..Style;
				loadStyles(styles.copy());
			}
			
			var placemarks:XMLList = dataXML..Placemark;
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
			
			use namespace google;
			use namespace opengis;
			//var styleMap:HashMap = null;
			for each(var style:XML in styles) {
				
				var id:String = "";
				if(style.@id=="")
					continue;
				id = "#"+style.@id.toString();

				_styleList.put(id, getStyle(style));		
			}
		}
		
		public function getStyle(style:XML):Style 
		{
			if(style == null)
				return null;
			
			var _style:Style = new Style();
			
			// Read the style id
			if (style.@id.length() > 0)
			{
				_style.name = style.@id;
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
							if (hotSpot[0].@x.length() > 0)
								xOffSet = hotSpot[0].@x;
							if (hotSpot[0].@xunits.length() > 0)
								xUnit = hotSpot[0].@xunits;
							if (hotSpot[0].@y.length() > 0)
								yOffSet = hotSpot[0].@y;
							if (hotSpot[0].@yunits.length() > 0)
								yUnit = hotSpot[0].@yunits;
						}
						currentRule.symbolizers.push(new PointSymbolizer(new CustomMarker(href, 1, xOffSet, xUnit, yOffSet, yUnit)));	
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
						currentRule.symbolizers.push(new PointSymbolizer(new WellKnownMarker(WellKnownMarker.WKN_SQUARE,iconFill,null,6, iconAlpha, iconRotation)));
					}
				}
				if(styleList[i].localName() == "LineStyle") 
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
						leftArrowMarker = extensionLine[0].@leftArrow;
						rightArrowMarker = extensionLine[0].@rightArrow;
						isArrow = true;
					}
					
					if (isArrow)
					{
						currentRule.symbolizers.push(new LineSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha)));
						var leftMarker:ArrowMarker;
						var rightMarker:ArrowMarker;
						
						if (leftArrowMarker != "none")
						{
							if (Lwidth < 3)
								leftMarker = new ArrowMarker(leftArrowMarker, null,new Stroke(Lcolor, Lwidth, Lalpha), 12);
							else
								leftMarker = new ArrowMarker(leftArrowMarker, null,new Stroke(Lcolor, Lwidth, Lalpha), 4*Lwidth);
						}
						
						if (rightArrowMarker != "none")
						{
							if (Lwidth < 3)
								rightMarker = new ArrowMarker(rightArrowMarker, null, new Stroke(Lcolor, Lwidth, Lalpha), 12);
							else
								rightMarker = new ArrowMarker(rightArrowMarker, null, new Stroke(Lcolor, Lwidth, Lalpha), 4*Lwidth);
						}
						currentRule.symbolizers.push(new ArrowSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha), leftMarker, rightMarker));
						outLineSymbolizer = new LineSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha));
					}else{
						currentRule.symbolizers.push(new LineSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha)));
						outLineSymbolizer = new LineSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha));
					}
				}
				
				if(styleList[i].localName() == "PolyStyle") 
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
			use namespace google;
			use namespace opengis;
			
			for each(var placemark:XML in placemarks) {
				var coordinates:Array;
				var point:Point;
				var htmlContent:String = "";
				var attributes:Object = new Object();
				var localStyle:Style;
				var localStyles:XMLList = placemark..*::Style;
				var attributeName:String = "";
				
				//there can be a Style defined inside the Placemark element
				//in this case, there is no styleUrl element and the Style element doesn't have an ID
				if(localStyles.length()== 1) 
				{
					localStyle = this.getStyle(localStyles[0]);
				}
				if(placemark.name != undefined) 
				{
					attributes["name"] = placemark.name.text();
					htmlContent = htmlContent + "<b>" + placemark.name.text() + "</b><br />";   
				}
				if(placemark.description != undefined) 
				{
					attributes["description"] = placemark.description.text();
					htmlContent = htmlContent + placemark.description.text() + "<br />";
				}
				
				if(placemark.id != undefined) 
				{
					attributes["id"] = placemark.id.text();
					htmlContent = htmlContent + placemark.description.text() + "<br />";
				}
				
				for each(var extendedData:XML in placemark.ExtendedData.Data) 
				{	
					if(extendedData.displayName.text() != undefined) {
						attributeName = extendedData.displayName.text();
						if(excludeFromExtendedData.indexOf(attributeName) < 0) {
							attributes[attributeName] = extendedData.value.text();
						}
					} else {
						attributeName = extendedData.@name;
						if(excludeFromExtendedData.indexOf(attributeName) < 0) {
							attributes[attributeName] = extendedData.value.text();
						}
					}
					
					htmlContent = htmlContent + "<b>" + attributeName + "</b> : " + extendedData.value.text() + "<br />";
				}
				
				for each(var simpleExtendedData:XML in placemark.ExtendedData.SchemaData.SimpleData) 
				{	
					attributeName = simpleExtendedData.@name;
					if(excludeFromExtendedData.indexOf(attributeName) < 0) {
						attributes[attributeName] = simpleExtendedData.text();
					}
					
					htmlContent = htmlContent + "<b>" + attributeName + "</b> : " + simpleExtendedData.text() + "<br />";
				}
				attributes["popupContentHTML"] = htmlContent;	
				var _id:String;
				
				// LineStrings
				if(placemark.LineString != undefined)
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
						else if(placemark.styleUrl != undefined)
						{
							_id = placemark.styleUrl.text();
							if(_styleList.getValue(_id))
								_Lstyle = _styleList.getValue(_id);
						}
					}
					linesfeatures.push(new LineStringFeature(this.loadLineString(placemark),attributes,_Lstyle));
				}
				// Polygons
				else if(placemark.Polygon != undefined) 
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
						else if(placemark.styleUrl != undefined)
						{
							_id = readStyleUrlId(placemark.styleUrl);
							if(_styleList.getValue(_id))
								_pStyle = _styleList.getValue(_id);
						}
					}
					polygonsfeatures.push(new PolygonFeature(this.loadPolygon(placemark),attributes,_pStyle));
				}
				
				//MultiGeometry  
				else if (placemark.MultiGeometry != undefined)
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
							else if(placemark.styleUrl != undefined)
							{
								_id = readStyleUrlId(placemark.styleUrl);
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
							else if(placemark.styleUrl != undefined)
							{
								_id = readStyleUrlId(placemark.styleUrl);
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
						else if(placemark.styleUrl != undefined) 
						{
							_id = readStyleUrlId(placemark.styleUrl);
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
				else if(placemark.Point != undefined)
				{
					coordinates = placemark.Point.coordinates.text().split(",");
					
					//Maybe it is a label
					var isLabel:Boolean = false;
					var textLabel:String = "";
					for each(var extData:XML in placemark.ExtendedData.Data) 
					{	
						if(extData.@name == "label") {
							isLabel = true
							textLabel = extData.value.text();
						}
					}
					
					if(isLabel) {
						var l:LabelPoint = new LabelPoint(textLabel,coordinates[0], coordinates[1]);
						labelfeatures.push(new LabelFeature(l,attributes));
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
						else if(placemark.styleUrl != undefined || localStyle) 
						{
							var objStyle:Style = null;
							if(localStyle) 
							{
								objStyle = localStyle;
							} 
							else 
							{
								_id = readStyleUrlId(placemark.styleUrl);
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
			/*var loc:Location;
			if(objStyle["icon"]!=null) 
			{ // style with icon
				var _icon:String = objStyle["icon"];
				var pointFeature = PointFeature;
				var customMarker:CustomMarker;
				/*if(_images[_icon]!=null) 
				{ // image not loaded so we will wait for it
					var _img:Sprite = new Sprite();
					_images[_icon].push(_img);
					loc = new Location(point.x,point.y);
					customMarker = CustomMarker.createDisplayObjectMarker(_img,loc,attributes,0,0);
				}
				else if(_externalImages[_icon]!=null) 
				{ // image already loaded, we copy the loader content
					var Image:Bitmap = new Bitmap(new Bitmap(_externalImages[_icon].loader.content).bitmapData.clone());
					Image.y = -Image.height;
					Image.x = -Image.width/2;
					customMarker = CustomMarker.createDisplayObjectMarker(Image,new Location(point.x,point.y),attributes,0,0);
				}
				else 
				{ // image failed to load
					var _marker:Bitmap = new _defaultImage();
					_marker.y = -_marker.height;
					_marker.x = -_marker.width/2;
					customMarker = CustomMarker.createDisplayObjectMarker(_marker,new Location(point.x,point.y),attributes,0,0);
				}
				return customMarker;
			}
			else 
			{ */// style without icon
				if(this.userDefinedStyle)
					return new PointFeature(point, attributes,this.userDefinedStyle);
				else
					return new PointFeature(point, attributes, objStyle);
			//}
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
				var _mark:WellKnownMarker = new WellKnownMarker(WellKnownMarker.WKN_SQUARE, _fill, _stroke);//the color of its stroke is the kml color
				var _symbolizer:PointSymbolizer = new PointSymbolizer();
				_symbolizer.graphic = _mark;
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
			 
			var lineNode:XML= placemark..*::LineString[0];
			XML.ignoreWhitespace = true;
			var lineData:String = lineNode..*::coordinates[0].toString();
			
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
			var polygon:XML = placemark..*::Polygon[0];
			
			//exterior ring
			var outerBoundary:XML = polygon..*::outerBoundaryIs[0];
			var ring:XML = outerBoundary..*::LinearRing[0];
			
			var lines:Vector.<Geometry> = new Vector.<Geometry>(1);
			lines[0] = this.loadPolygonData(ring..*::coordinates.toString());
			
			//interior ring
			var innerBoundary:XML = polygon..*::innerBoundaryIs[0];
			if(innerBoundary) 
			{
				ring = innerBoundary..*::LinearRing[0];
				try 
				{
					lines.push(this.loadPolygonData(ring..*::coordinates.toString()));
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
			_Pdata = _Pdata.split("\n").join("");
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
			var kmlns:Namespace = new Namespace("kml","http://www.opengis.net/kml/2.2");
			var kmlFile:XML = new XML("<kml></kml>");
			kmlFile.addNamespace(kmlns);
			
			var doc:XML = new XML("<Document></Document>"); 
			kmlFile.appendChild(doc);

			var listOfFeatures:Vector.<Feature> = features as Vector.<Feature>;
			var numberOfFeat:uint = listOfFeatures.length;
			if (numberOfFeat > 0 && listOfFeatures[0].layer)
			{
				var name:XML = new XML("<Name>"+listOfFeatures[0].layer.displayedName+"</Name>");
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
			return kmlFile; 
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
			else if(feature is LabelFeature)
			{
				pointNode = new XML("<Point></Point>");
				var label:LabelPoint = (feature as LabelFeature).labelPoint;
				pointNode.appendChild(new XML("<coordinates>" + label.x + "," + label.y + "</coordinates>"));
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
			if(feature.layer) {
				var j:uint = feature.layer.attributesId.length;
				if(j>0) {
					extendedData =	new XML("<ExtendedData></ExtendedData>");
					
					//if feature is a Label, register the value
					if(feature is LabelFeature) {
						var l:LabelPoint = (feature as LabelFeature).labelPoint;
						data = new XML("<Data name=\"label\"></Data>");
						value = new XML("<value>" + l.label.text + "</value>");
						data.appendChild(value);
						extendedData.appendChild(data);
						
						data = new XML("<Data name=\"rotationZ\"></Data>");
						value = new XML("<value>" + l.label.rotationZ + "</value>");
						data.appendChild(value);
						extendedData.appendChild(data);
					}
					
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
			var symbLength:Number =symbolizers.length;
			
			// Boolean that track if a stroke style has been exported 
			//(to avoid stoke style duplication between polygon et line style)
			var strokeExported:Boolean = false;
			for (var i:int = 0; i < symbLength; ++i)
			{
				var symb:Symbolizer = symbolizers[i];
				if (symb is LineSymbolizer)
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
							var extensionNode:XML = new XML("<ListStyleSimpleExtensionGroup></ListStyleSimpleExtensionGroup>");
							if ((symb as ArrowSymbolizer).leftMarker)
							{
								extensionNode.@leftArrow = ((symb as ArrowSymbolizer).leftMarker as ArrowMarker).arrowMarker;
							}else{
								extensionNode.@leftArrow = "none"
							}
							if ((symb as ArrowSymbolizer).rightMarker)
							{
								extensionNode.@rightArrow = ((symb as ArrowSymbolizer).rightMarker as ArrowMarker).arrowMarker;
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
					var graphic:Marker = pointSym.graphic;
					
					// Switch between marker types
					if(graphic is WellKnownMarker)
					{
						var wkm:WellKnownMarker = graphic as WellKnownMarker;
						var solidFill:SolidFill = wkm.fill;
						styleNode.appendChild(this.buildColorNode(solidFill.color as uint, solidFill.opacity));
						styleNode.colorMode = "normal";
					}else if (graphic is CustomMarker)
					{
						var iconNode:XML = new XML("<Icon></Icon>");
						
						var cm:CustomMarker = graphic as CustomMarker;
						var href:String = cm.url;
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
			
			
			
			
			
			
			
		/*	//if(feature is LineStringFeature || feature is MultiLineStringFeature)
			//{
				//for lines, we will not store the outline style (the contour of the line)				
				//var lineF:LineStringFeature = feature as LineStringFeature;
				styleNode = new XML("<LineStyle></LineStyle>");
				if(symbolizers.length > 0)
				{
					var lSym:LineSymbolizer = symbolizers[0] as LineSymbolizer;
					stroke = lSym.stroke;
					color = stroke.color;
					opacity = stroke.opacity;
					width = stroke.width;
					styleNode.appendChild(this.buildColorNode(color,opacity));
					styleNode.colorMode = "normal";
					styleNode.width = width;
					placemarkStyle.appendChild(styleNode);				
				}
			//}
			else if(feature is LabelFeature)
			{	
				styleNode = new XML("<LabelStyle></LabelStyle>");
				styleNode.color = "000000";
				styleNode.colorMode = "normal";
				styleNode.scale = "1";
				placemarkStyle.appendChild(styleNode);
			}
			else if(feature is PolygonFeature || feature is MultiPolygonFeature)
			{
				//for polygons, we can store both the polygon style and the outline 
				var polyF:PolygonFeature = feature as PolygonFeature;
				styleNode = new XML("<PolyStyle></PolyStyle>");
				
				if(symbolizers.length > 1)
				{
					//the second symbolizer is the outline style (fill - null and color of the outline)
					styleNode.outline = "1";
					var styleNode2:XML = new XML("<LineStyle></LineStyle>");
					var polySym2:PolygonSymbolizer = symbolizers[1] as PolygonSymbolizer;
					var stroke2:Stroke = polySym2.stroke;
					color = stroke2.color;
					opacity = stroke2.opacity;
					styleNode2.appendChild(this.buildColorNode(color,opacity));
					styleNode2.width = stroke2.width;
					placemarkStyle.appendChild(styleNode2);	
				}		
				
				if(symbolizers.length > 0)
				{
					//the first symbolizer is the polygon style (fill and color)
					var polySym:PolygonSymbolizer = symbolizers[0] as PolygonSymbolizer;
					var fill:Fill = polySym.fill;
					stroke = polySym.stroke;
					color = stroke.color;
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
				}			
			}
			else if(feature is PointFeature || feature is MultiPointFeature)
			//the style with icon is not implemented meaning the .kmz format is not supported	
			{
				var pointFeat:PointFeature = feature as PointFeature;
				styleNode = new XML("<IconStyle></IconStyle>");
				if(symbolizers.length > 0)
				{
					var pointSym:PointSymbolizer = symbolizers[0] as PointSymbolizer;
					var graphic:Marker = pointSym.graphic;
					if(graphic is WellKnownMarker)
					{//we can build the color node
						var wkm:WellKnownMarker = graphic as WellKnownMarker;
						var solidFill:SolidFill = wkm.fill;
						styleNode.appendChild(this.buildColorNode(solidFill.color as uint, solidFill.opacity));
						styleNode.colorMode = "normal";
					}
				}
				placemarkStyle.appendChild(styleNode);	
			}*/
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

	}
}

