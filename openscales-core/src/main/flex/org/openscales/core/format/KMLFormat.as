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
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.request.DataRequest;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.Fill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.marker.WellKnownMarker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
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
				
				var color:Number;
				var alpha:Number=1;
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
					var Lcolor:Number = color;
					var Lalpha:Number = alpha;
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
					if(style.PolyStyle.color != undefined) {
						//the style of the polygon itself
						Pcolor = KMLColorsToRGB(style.PolyStyle.color.text());
						Palpha = KMLColorsToAlpha(style.PolyStyle.color.text());
						Pfill = new SolidFill();
						Pfill.color = Pcolor;
						Pfill.opacity = Palpha;
						Pstroke.color = Pcolor;//the color of the outline is the color of the polygon
					}
					//if the polygon shouldn't be filled
					if(style.PolyStyle.fill != undefined && style.PolyStyle.fill.text() == "0") {
						Pfill = null;
					}
					//the style of the outline (the contour of the polygon)
					if( lineStyles[id]!=undefined &&
						(style.PolyStyle.outline == undefined || style.PolyStyle.outline.text() == "1") ) 
					{
						//change the color of the polygon outline
						Pstroke.color = Lcolor;
						Pstroke.width = Lwidth;
					}
					var Pps:PolygonSymbolizer = new PolygonSymbolizer(Pfill, Pstroke);
					Prule = new Rule();
					Prule.name = id;
					Prule.symbolizers.push(Pps);
					Prule.symbolizers.push(Pps);
					polygonStyles[id] = new Style();
					polygonStyles[id].rules.push(Prule);
					polygonStyles[id].name = id;
				}
			}
		}
		
		private function _loadPolygon(_Pdata:String):LinearRing {
			
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
		 * load placemarks
		 * @param a list of placemarks
		 * @call _loadPolygon
		 */
		private function loadPlacemarks(placemarks:XMLList):void {
			// todo  Multigeometry tag
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
					var _Ldata:String = placemark.LineString.coordinates.text();
					_Ldata = _Ldata.replace("\n"," ");
					_Ldata = _Ldata.replace(/^\s*(.*?)\s*$/g, "$1");
					coordinates = _Ldata.split(" ");
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
					linesfeatures.push(new LineStringFeature(line,attributes,_Lstyle));
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
					//extract exterior ring
					var lines:Vector.<Geometry> = new Vector.<Geometry>(1);
					lines[0] = this._loadPolygon(placemark.Polygon.outerBoundaryIs.LinearRing.coordinates.text());
					//interior ring
					if(placemark.Polygon.innerBoundaryIs != undefined) 
					{
						try 
						{
							lines.push(this._loadPolygon(placemark.Polygon.innerBoundaryIs.LinearRing.coordinates.text()));
						} 
						catch(e:Error) {}
					}
					polygonsfeatures.push(new PolygonFeature(new Polygon(lines),attributes,_Pstyle));
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
							{ // icon
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
								var _style:Style;
								if(this.userDefinedStyle)
								{
									_style = this.userDefinedStyle;
								}
								else
									_style = Style.getDefaultPointStyle();
								
								if(pointStyles[_id]["color"] != undefined)
								{
									var _fill:SolidFill = new SolidFill(pointStyles[_id]["color"], pointStyles[_id]["alpha"]);
									var _stroke:Stroke = new Stroke(pointStyles[_id]["color"], pointStyles[_id]["alpha"]);
									var _mark:WellKnownMarker = new WellKnownMarker(WellKnownMarker.WKN_SQUARE, _fill, _stroke);
									var _symbolizer:PointSymbolizer = new PointSymbolizer();
									_symbolizer.graphic = _mark;
									var _rule:Rule = new Rule();
									_rule.name = _id;
									_rule.symbolizers.push(_symbolizer);
									_style = new Style();
									_style.name = _id;
									_style.rules.push(_rule);
								}
								iconsfeatures.push(new PointFeature(point, attributes, _style));
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
			loadPlacemarks(placemarks);
			
			var _features:Vector.<Feature> = polygonsfeatures.concat(linesfeatures, iconsfeatures);
			
			return _features;
		}
		
		/**
		 * Write data
		 *
		 * @param features the features to build into a KML file
		 * @return the KML file (xml format)
		 * @call buildStyleNode
		 */
		
		override public function write(features:Object):Object
		{
			var i:uint;
			var kmlns:Namespace = new Namespace("kml","http://www.opengis.net/kml/2.2");
			var kmlFile:XML = new XML("<kml></kml>");
			kmlFile.addNamespace(kmlns);
			
			var doc:XML = new XML("<Document></Document>"); 
			kmlFile.appendChild(doc);
			
			var listOfFeatures:Vector.<Feature> = features as Vector.<Feature>;
			var numberOfFeat:uint = listOfFeatures.length;
			
			//build the style nodes first
			for(i =0; i < numberOfFeat; i++)
			{
				if(listOfFeatures[i].style)
				{
					doc.appendChild(this.buildStyleNode(listOfFeatures[i],i));
				}
			}
			//build the placemarks
			
			return kmlFile; 
		}
		
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
				
				if(symbolizers.length > 0)
				{
					//symbolizers[0] is the polygon style (fill and color)
					var polySym:PolygonSymbolizer = symbolizers[0] as PolygonSymbolizer;
					var fill:Fill = polySym.fill;
					stroke = polySym.stroke;
					color = stroke.color;
					opacity = stroke.opacity;
					styleNode.appendChild(this.buildColorNode(color,opacity));
					styleNode.colorMode = "normal";
					if(fill is SolidFill)
						styleNode.fill = "1";
					else 
						styleNode.fill = "0";
					placemarkStyle.appendChild(styleNode);	
					
					if(symbolizers.length > 1)
					{
						//symbolizers[1] is the outline style (fill - null and color of the outline)
						styleNode.outline = "1";
						var styleNode2:XML = new XML("<LineStyle></LineStyle>");
						var polySym2:PolygonSymbolizer = symbolizers[1] as PolygonSymbolizer;
						var stroke2:Stroke = polySym2.stroke;
						color = stroke2.color;
						opacity = stroke2.opacity;
						styleNode2.appendChild(this.buildColorNode(color,opacity));
						placemarkStyle.appendChild(styleNode2);	
					}
					
						
				}			
			}
			
			return placemarkStyle;
		}
		
		
		/**
		 * build kml color tag
		 * opacity of 1 in OpenScales means 255 in KML
		 */ 
		private function buildColorNode(color:uint,opacity:Number):XML
		{
			var colorNode:XML = new XML("<color></color>");
			
			var stringColor:String = color.toString(16);
			var KMLcolor:String = opacity.toString(16) + stringColor.substr(4,2)
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

