package org.openscales.core.format
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.openscales.core.feature.CustomMarker;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.request.DataRequest;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.Fill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.marker.Marker;
	import org.openscales.core.style.marker.WellKnownMarker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;
	
	
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
		private var polygonsfeatures:Vector.<Feature> = new Vector.<Feature>();
		// styles
		private var lineStyles:Object = new Object();
		private var pointStyles:Object = new Object();
		private var polygonStyles:Object = new Object();
		
		private var _userDefinedStyle:Style = null;
		
		public function KMLFormat() {}
			
		/**
		 * Read data
		 *
		 * @param data data to read/parse
		 * @return array of features (polygons, lines and points)
		 * @call loadStyles (only if the user does not set a style)
		 * @call loadPlacemarks (to extract the geometries)
		 * 
		 * if there is no style defined in the KML file, the feature created will have a default Open Scales style
		 * @see Style.as
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
			loadPlacemarks(placemarks);
			
			var _features:Vector.<Feature> = polygonsfeatures.concat(linesfeatures, iconsfeatures);
			
			return _features;
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
		
		private function updateImages(e:Event):void {
			var _url:String = e.target.loader.name;
			var _imgs:Array = _images[_url];
			_images[_url] = null;
			var _bm:Bitmap = Bitmap(_externalImages[_url].loader.content); 
			var _bmd:BitmapData = _bm.bitmapData;
			for each(var _img:Sprite in _imgs) {
				var _image:Bitmap = new Bitmap(_bmd.clone());
				_image.x = -_image.width/2;
				_image.y = -_image.height;
				_img.addChild(_image);
			}
		}
		
		private function updateImagesError(e:Event):void {
			var _url:String = e.target.loader.name;
			var _imgs:Array = _images[_url];
			_images[_url] = null;
			_externalImages[_url] = null;
			
			for each(var _img:Sprite in _imgs) {
				var _marker:Bitmap = new _defaultImage();
				_marker.y = -_marker.height;
				_marker.x = -_marker.width/2;
				_img.addChild(_marker);
			}
		}
		
		/**
		 * load styles
		 * This function is called only if the user does not set the userDefinedStyle attribute
		 * @calls KMLColorsToRGB
		 * @calls KMLColorsToAlpha
		 */
		private function loadStyles(styles:XMLList):void {
			
			use namespace google;
			use namespace opengis;
			
			for each(var style:XML in styles) {
				var id:String = "";
				if(style.@id=="")
					continue;
				id = "#"+style.@id.toString();
				
				//useless, there are no colors outside a LineStyle or PolyStyle or IconStyle
				var color:Number;
				var alpha:Number = 1;
				if(style.color != undefined) {
					color = KMLColorsToRGB(style.color.text());
					alpha = KMLColorsToAlpha(style.color.text())
				}
				
				if(style.IconStyle != undefined) {
					pointStyles[id] = new Object();
					pointStyles[id]["icon"] = null
					if(style.IconStyle.Icon != undefined && style.IconStyle.Icon.href != undefined) {
						try {
							var _url:String = style.IconStyle.Icon.href.text();
							var _req:DataRequest;
							_req = new DataRequest(_url, updateImages, updateImagesError);
							_req.proxy = this._proxy;
							//_req.security = this._security; // FixMe: should the security be managed here ?
							_req.send();
							_externalImages[_url] = _req;
							pointStyles[id]["icon"] = _url;
							_images[_url] = new Array();
						} catch(e:Error) {
							pointStyles[id]["icon"] = null;
						}
					}
					if(style.IconStyle.color != undefined) {
						pointStyles[id]["color"] = KMLColorsToRGB(style.IconStyle.color.text());
						pointStyles[id]["alpha"] = KMLColorsToAlpha(style.IconStyle.color.text());
					}
					if(style.IconStyle.scale != undefined)
						pointStyles[id]["scale"] = Number(style.IconStyle.scale.text());
					if(style.IconStyle.heading != undefined) //0 to 360°
						pointStyles[id]["rotation"] = Number(style.IconStyle.headingtext());
					// TODO implement offset support + rotation effect
				}
				
				if(style.LineStyle != undefined) {
					var Lcolor:Number = 0x96A621;
					var Lalpha:Number = 1;
					var Lwidth:Number = 1;
					if(style.LineStyle.color != undefined) {
						Lcolor = KMLColorsToRGB(style.LineStyle.color.text());
						Lalpha = KMLColorsToAlpha(style.LineStyle.color.text());
					}
					if(style.LineStyle.width != undefined) {
						Lwidth = parseInt(style.LineStyle.width.text());
					}
					var Lrule:Rule = new Rule();
					Lrule.name = id;
					Lrule.symbolizers.push(new LineSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha)));
					Lrule.symbolizers.push(new LineSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha)));
			 		lineStyles[id] = new Style();
					lineStyles[id].name = id;
					lineStyles[id].rules.push(Lrule);
				}
				
				if(style.PolyStyle != undefined) {
					var Pcolor:Number = 0x96A621;
					var Palpha:Number = 1;
					var Pfill:SolidFill = new SolidFill();;
					Pfill.color = Pcolor;
					Pfill.opacity = Palpha;
					var Prule:Rule;
					var Pstroke:Stroke = new Stroke();
					Pstroke.width = 1;
					Pstroke.color = Pcolor;
					
					if(style.PolyStyle.color != undefined) 
					{
						//the style of the polygon itself
						Pcolor = KMLColorsToRGB(style.PolyStyle.color.text());
						Palpha = KMLColorsToAlpha(style.PolyStyle.color.text());
						Pfill = new SolidFill();
						Pfill.color = Pcolor;
						Pfill.opacity = Palpha;
						Pstroke.color = Pcolor;
					}
					
					var Pps1:PolygonSymbolizer;
					var Pps2:PolygonSymbolizer;
					
					//if the polygon shouldn't be filled
					if(style.PolyStyle.fill != undefined && style.PolyStyle.fill.text() == "0") {
						Pfill = null;
					}
					//the style of the outline (the contour of the polygon)
					if( lineStyles[id]!=undefined &&
						(style.PolyStyle.outline == undefined || style.PolyStyle.outline.text() == "1") ) 
					{
						//change the color of the polygon outline
						var outlineStroke:Stroke = new Stroke();
						outlineStroke.color = Lcolor;
						outlineStroke.width = Lwidth;
						Pps2 = new PolygonSymbolizer(null, outlineStroke);
					}
					else
					{
						Pps2 = new PolygonSymbolizer(null, Pstroke);
					}
					
					Pps1 = new PolygonSymbolizer(Pfill, Pstroke);
					Prule = new Rule();
					Prule.name = id;
					Prule.symbolizers.push(Pps1);
					Prule.symbolizers.push(Pps2);
					polygonStyles[id] = new Style();
					polygonStyles[id].rules.push(Prule);
					polygonStyles[id].name = id;
				}
			}
		}
		
		/**
		 * Load placemarks
		 * @param a list of placemarks
		 * @call loadLineString
		 * @call loadPolygon
		 */
		private function loadPlacemarks(placemarks:XMLList):void 
		{
			use namespace google;
			use namespace opengis;
			
			for each(var placemark:XML in placemarks) {
				var coordinates:Array;
				var point:Point;
				var htmlContent:String = "";
				var attributes:Object = new Object();
				
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
				
				for each(var extendedData:XML in placemark.ExtendedData.Data) 
				{
					if(extendedData.value)
						attributes[extendedData.@name] = extendedData.value.text();
					htmlContent = htmlContent + "<b>" + extendedData.@name + "</b> : " + extendedData.value.text() + "<br />";
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
						_Lstyle = Style.getDefaultLineStyle();
					if(placemark.styleUrl != undefined)
					{
						_id = placemark.styleUrl.text();
						if(lineStyles[_id] != undefined)
							_Lstyle = lineStyles[_id];
					}
							
					linesfeatures.push(new LineStringFeature(this.loadLineString(placemark),attributes,_Lstyle));
				}
				
				// Polygons
				if(placemark.Polygon != undefined) 
				{
					var _Pstyle:Style = null;
					if(this.userDefinedStyle){
						_Pstyle = this.userDefinedStyle;
					}
					else
						_Pstyle = Style.getDefaultSurfaceStyle();
					if(placemark.styleUrl != undefined)
					{
						_id = placemark.styleUrl.text();
						if(polygonStyles[_id] != undefined)
							_Pstyle = polygonStyles[_id];
					}
			
					polygonsfeatures.push(new PolygonFeature(this.loadPolygon(placemark),attributes,_Pstyle));
				}
				
				//MultiGeometry  
				if (placemark.MultiGeometry != undefined)
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
						}
						else
							geomStyle = Style.getDefaultLineStyle();
						if(placemark.styleUrl != undefined)
						{
							_id = placemark.styleUrl.text();
							if(lineStyles[_id] != undefined)
								geomStyle = lineStyles[_id];
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
						}
						else
							geomStyle = Style.getDefaultSurfaceStyle();
						if(placemark.styleUrl != undefined)
						{
							_id = placemark.styleUrl.text();
							if(lineStyles[_id] != undefined)
								geomStyle = lineStyles[_id];
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
						if(this.userDefinedStyle)
						{
							geomStyle = this.userDefinedStyle;
						}
						else if(placemark.styleUrl != undefined) 
						{
							_id = placemark.styleUrl.text();
							geomStyle = this.loadPointStyleWithoutIcon(_id);
						}
						else
							geomStyle = Style.getDefaultPointStyle();
						
						iconsfeatures.push(new MultiPointFeature(new MultiPoint(pointCoords),attributes,geomStyle));
							
					}
				}
				//Points
				// rotation is not supported yet
				if(placemark.Point != undefined)
				{
					coordinates = placemark.Point.coordinates.text().split(",");
					point = new Point(coordinates[0], coordinates[1]);
					if (this.internalProjSrsCode != null, this.externalProjSrsCode != null) 
					{
						point.transform(this.externalProjSrsCode, this.internalProjSrsCode);
					}
					var loc:Location;
					if(placemark.styleUrl != undefined) 
					{
						_id = placemark.styleUrl.text();
						if(pointStyles[_id] != undefined) 
						{ // style
							if(pointStyles[_id]["icon"]!=null) 
							{ // style with icon
								var _icon:String = pointStyles[_id]["icon"];
								var customMarker:CustomMarker;
								if(_images[_icon]!=null) 
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
								iconsfeatures.push(customMarker);
							}
							else 
							{ // style without icon
								if(this.userDefinedStyle)
								{
									iconsfeatures.push(new PointFeature(point, attributes,this.userDefinedStyle));
								}
								else
									iconsfeatures.push(new PointFeature(point, attributes, 
									this.loadPointStyleWithoutIcon(_id)));
							}
						}
						else // no matching style
							iconsfeatures.push(new PointFeature(point, attributes, Style.getDefaultPointStyle()));
					}
					else // no style
						iconsfeatures.push(new PointFeature(point, attributes, Style.getDefaultPointStyle()));
				}
			}
		}
		
		/**
		 * Load point style without icon
		 * @param the id of the style element
		 */ 
		
		private function loadPointStyleWithoutIcon(id:String):Style
		{
			var pointStyle:Style;
			pointStyle = Style.getDefaultPointStyle();
			
			if(pointStyles[id]["color"] != undefined)
			{
				var _fill:SolidFill = new SolidFill(pointStyles[id]["color"], pointStyles[id]["alpha"]);
				var _stroke:Stroke = new Stroke(pointStyles[id]["color"], pointStyles[id]["alpha"]);
				var _mark:WellKnownMarker = new WellKnownMarker(WellKnownMarker.WKN_SQUARE, _fill, _stroke);//the color of its stroke is the kml color
				var _symbolizer:PointSymbolizer = new PointSymbolizer();
				_symbolizer.graphic = _mark;
				var _rule:Rule = new Rule();
				_rule.name = id;
				_rule.symbolizers.push(_symbolizer);
				pointStyle = new Style();
				pointStyle.name = id;
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
			var lineData:String = lineNode..*::coordinates[0].toString();
			
			lineData = lineData.replace("\n"," ");
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
				if (this.internalProjSrsCode != null, this.externalProjSrsCode != null) 
				{
					point.transform(this.externalProjSrsCode, this.internalProjSrsCode);
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
			
			//extract exterior ring
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
			_Pdata = _Pdata.replace("\n"," ");
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
				if (this.internalProjSrsCode != null, this.externalProjSrsCode != null) 
				{
					point.transform(this.externalProjSrsCode, this.internalProjSrsCode);
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
			
			//build the style nodes first
			for(i = 0; i < numberOfFeat; i++)
			{
				if(listOfFeatures[i].style)
				{
					doc.appendChild(this.buildStyleNode(listOfFeatures[i],i));
				}
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
			var placemark:XML = new XML("<Placemark></Placemark>");
			var att:Object = feature.attributes;
			if (att.hasOwnProperty("name"))
				placemark.appendChild(new XML("<name>" + att["name"] + "</name>"));
			else
				//since we build the styles first, the feature will have an id for sure
				placemark.appendChild(new XML("<name>" + feature.name + "</name>"));
			
			placemark.appendChild(new XML("<styleUrl>#" + feature.name + "</styleUrl>"));
			
			var coords:String;
			if(feature is LineStringFeature)
			{
				var lineNode:XML = new XML("<LineString></LineString>");
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
				var pointNode:XML = new XML("<Point></Point>");
				var point:Point = (feature as PointFeature).point;
				pointNode.appendChild(new XML("<coordinates>" + point.x + "," + point.y + "</coordinates>"));
				placemark.appendChild(pointNode);
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
						extRingNode.appendChild(new XML("<coordinates>" + coords + "</coordinates>"));
				}
			}
			
			return polyNode;
		}
		
		/**
		 * @param the vector of coordinates of the geometry
		 * @return the coordinates as a string
		 * in kml coordinates are tuples consisting of longitude, latitude and altitude (optional)
		 * there is a space between tuples and commas inside the tuple
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
		
		private function buildStyleNode(feature:Feature,i:uint):XML
		{
			var color:uint;
			var opacity:Number;
			var width:Number;
			var stroke:Stroke;
			var rules:Vector.<Rule> = feature.style.rules;
			var symbolizers:Vector.<Symbolizer>;
			if(rules.length > 0)
			{
				symbolizers = rules[0].symbolizers;
			}
		
			//global style; can contain multiple Style types (Poly, Line, Icon)
			var placemarkStyle:XML = new XML("<Style></Style>");
			
			//this way, the feature and its style will have the same ID
			placemarkStyle.@id = "feature"+i.toString();
			feature.name = "feature"+i.toString();
			
			var styleNode:XML = null;
			if(feature is LineStringFeature)
			{
				//for lines, we will not store the outline style (the contour of the line)				
				var lineF:LineStringFeature = feature as LineStringFeature;
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
			}
			else if(feature is PolygonFeature)
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
			else if(feature is PointFeature)
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
		
		/**
		 * Getters and Setters
		 */ 
		public function get proxy():String
		{
			return _proxy;
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
	}
}

