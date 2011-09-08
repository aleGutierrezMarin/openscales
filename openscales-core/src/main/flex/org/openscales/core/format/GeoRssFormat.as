package org.openscales.core.format
{
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.format.gml.parser.GML311;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;

	public class GeoRssFormat extends Format
	{
		/** This class reads and writes RSS files with GeoRss content.
		 * 
		 * Supported GeoRss version 1.1 
		 * @see GeoRss Schema at http://www.georss.org/xml/1.1/georss.xsd 
		 * 
		 * Suported Rss version 2.0
		 * @see Rss Schema at http://cyber.law.harvard.edu/rss/rss
		 * 
		 * @attribute rssFile: the GeoRss data 
		 * @attribute featureVector
		 */
	
		private var _rssFile:XML;
		private var _featureVector:Vector.<Feature>;
		private var _extractAttributes:Boolean;
		private var _featuresids:HashMap = null; 
		
		private var _title:String;
		private var _description:String;
		private var _link:String;
		private var geoRssNs:Namespace = new Namespace("georss", "http://www.georss.org/georss");

		public function GeoRssFormat(featuresids:HashMap,
									 extractAttributes:Boolean = true)
		{
			super();
			this._extractAttributes = extractAttributes;
			this._featuresids = featuresids;
			
			//use the setters to change these default values before calling the write function
			this.title = "default title";
			this.link = "default link";
			this.description = "default description";
		
		}

		/**
		 * @calls parseItem to create the features and add them to featureVector
		 * 
		 * @param data to parse (a GeoRss file)
		 * @return Object (a vector of features)
		 * 
		 * @see RSS 2.0 specification the rss element has a single child, channel, with 3 required elements
		 * 
		 * The external GML geometry is supported only inside the where element
		 * 
		 */
		
		override public function read(data:Object):Object{
			
			this.featureVector = new Vector.<Feature>();
			this.rssFile = new XML(data);
			
			this.title = this.rssFile..*::title[0].toString();
			this.description = this.rssFile..*::description[0].toString();
			this.link = this.rssFile..*::link[0].toString();
				
			var items:XMLList = this.rssFile..*::item;
			var itemNumber:uint = items.length();
			var i:uint;
			
			for(i = 0; i < itemNumber; i++){
				
				var feature:Feature = this.parseItem(items[i]);
				if(feature){
					this.featureVector.push(feature);
					if(feature.name)
						this._featuresids.put(feature.name, feature);
				}
			}
			return this.featureVector;
		}
		
		/**
		 * @return a feature
		 * This function will also parse the feature attributes
		 * 
		 * @call parseCoords
		 * @call parseFeature for exterior GML data (@see GML311.as)
		 * @call parseHTMLAttributes for the decription element
		 * 
		 */ 
		public function parseItem(item:XML):Feature{
			
			var children:XMLList = item.children();
			var childrenNum:uint = children.length();
			var i:uint;
			var coords:Vector.<Number>;
			var feature:Feature = null;
			var id:String = null;
			var att:Object = {};
		
			for(i = 0; i < childrenNum; i++){
				var elementType:String = String((children[i] as XML).localName());
				
				if(elementType == "guid"){
					var guid:String = children[i].toString();
					if(guid.indexOf("featureid") != -1)
						id = guid.substring(guid.indexOf("=")+1,guid.indexOf("&"));
					else id = guid;
					
					if(this._featuresids && this._featuresids.containsKey(id))
						return null; 
				}
					
				//a polygon element contains at least 3 pairs of coordinates @see geoRss schema 
				else if(elementType == "polygon"){	
					coords = this.parseCoords(children[i]);
					if(coords.length >= 6)
					{
						var ringGeom:Vector.<Geometry> = new Vector.<Geometry>();
						ringGeom.push(new LinearRing(coords));
						feature = new PolygonFeature(new Polygon(ringGeom));
					}		
				}		
				else if(elementType == "point"){
					coords = this.parseCoords(children[i]);
					if(coords.length == 2){
						feature = new PointFeature(new Point(coords[0],coords[1])); //longitude, latitude
					}	
				}
				//a line element contains at least 2 pairs of coordinates @see geoRss schema 
				else if(elementType == "line"){
					coords = this.parseCoords(children[i]);
					if(coords.length >= 4){
						feature = new LineStringFeature(new LineString(coords));
					}
				}
				
				//if the where element contains more than one GML feature, only the first one will be parsed
				else if(elementType == "where"){
					var gmlFormat:GML311 = new GML311();
					feature = gmlFormat.parseFeature(children[i], false);			
				}
				else if(elementType.toLowerCase() == "description") {
					if((children[i].children().length()) > 0)//OK; false if the node doesn't contain any value
						att["description"] = parseHTMLAttributes(children[i].toString());
				}
				//parse attributes
				else {
					if((children[i].children().length()) > 0)
					att[elementType] = children[i].toString();
				}
			}	
			if(feature){
				feature.attributes = att;
				if(id){
					feature.name = id;
				}		
			}	
			return feature;
		}

		private function parseHTMLAttributes(str:String):String {
			var reg:RegExp = /\<br\/\>/g;
			str = str.replace(reg,"<br/>");
			reg = /\<li\>/g;
			str = str.replace(reg,"<br/>");
			reg = /\<\/li\>/g;
			return str.replace(reg,"");
		}
		
		/**
		 * @georss schema A pair of coordinates represents latitude then longitude (WGS84 reference)
		 * In openScales, the order of coordinates is: longitude then latitude
		 */ 
		
		public function parseCoords(node:XML):Vector.<Number>{
			
			var coordsVector:Vector.<Number> = new Vector.<Number>();
			var coords:String = node.toString();
			var coordNum:uint = coords.split(" ").length;
			var i:uint;
			for(i = 0; i < coordNum; i += 2){
				coordsVector.push(Number(coords.split(" ")[i+1]));
				coordsVector.push(Number(coords.split(" ")[i]));
			}
			return coordsVector;
		}	
		
		/**
		 * @calls buildItemNode
		 * @param the features to include in the RSS file
		 * @return Object (the RSS file)
		 * @see RSS 2.0 specification the rss element has a single child, channel, with 3 required elements
		 * 
		 */
		
		override public function write(features:Object):Object{
			
			var i:uint;
			var rssFile:XML = new XML("<rss></rss>");
			var channel:XML = new XML("<channel></channel>");
			channel.appendChild(new XML("<title>" + this.title + "</title>"));
			channel.appendChild(new XML("<link>" + this.link + "</link>"));
			channel.appendChild(new XML("<description>" + this._description + "</description>"));
			rssFile.appendChild(channel);
			rssFile.addNamespace(this.geoRssNs);
			
			var data:Vector.<Feature> = features as Vector.<Feature>;
			var numberOfFeatures:uint = data.length; 
			for(i = 0; i < numberOfFeatures; i++){
				var nodeToAdd:XML = this.buildItemNode(data[i]);
				if(nodeToAdd)	
					channel.appendChild(nodeToAdd);
			} 
			return rssFile;
		}	
		
		/**
		 * @param the feature to write in the Rss file
		 * @return the feature XML node
		 * @call buildCoordsAsString
		 * The supported features are Points, LineStrings and Polygons
		 */ 
		public function buildItemNode(feature:Feature):XML{
			
			var i:uint;
			var coords:String = "";
			var item:XML = new XML("<item></item>");
			var attributes:Object = feature.attributes;
			item.addNamespace(this.geoRssNs);
		
			if (attributes.hasOwnProperty("title"))
				item.appendChild(new XML("<title>" + attributes["title"] + "</title>"));
			if (attributes.hasOwnProperty("link"))
				item.appendChild(new XML("<link>" + attributes["link"] + "</link>"));
			if (attributes.hasOwnProperty("description"))
				item.appendChild(new XML("<description>" + attributes["description"] + "</description>"));
			if(feature.name)
				item.appendChild(new XML("<guid>" + String(feature.name) + "</guid>"));
			
			if(feature is PointFeature){
				var pointGeom:Point = (feature as PointFeature).point;
				var point:XML = new XML("<point></point>");
				point.setNamespace(this.geoRssNs);
				point.appendChild(String(pointGeom.y) + " " + String(pointGeom.x));			
				item.appendChild(point);
			}
			else if(feature is LineStringFeature){
				var lineGeom:LineString = (feature as LineStringFeature).lineString;
				var line:XML = new XML("<line></line>");
				line.setNamespace(this.geoRssNs);

				line.appendChild(this.buildCoordsAsString(lineGeom.getcomponentsClone()));
				item.appendChild(line);
				
			}
			else if(feature is PolygonFeature){
				var polyGeom:Polygon = (feature as PolygonFeature).polygon;
				var poly:XML = new XML("<polygon></polygon>");
				poly.setNamespace(this.geoRssNs);
				
				var linearRings:Vector.<Geometry> = polyGeom.getcomponentsClone();
				//there's only one linearRing (the exterior one) in a GeoRss polygon tag 
				poly.appendChild(this.buildCoordsAsString((linearRings[0] as LinearRing).getcomponentsClone()));	
				item.appendChild(poly);
			}
			else{
				Trace.warn("This type of feature has no correspondent in the geoRss specification"); 
				return null; 
			}
			return item;
		}
		
		public function buildCoordsAsString(coords:Vector.<Number>):String{
			var i:uint;
			var stringCoords:String = "";
			var numberOfPoints:uint = coords.length;
			for(i = 0; i < numberOfPoints; i += 2){
				stringCoords += String(coords[i+1])+" ";
				stringCoords += String(coords[i]);
				if( i != (numberOfPoints -2))
					stringCoords += " ";
			}
			return stringCoords;
		}
		
		
		/**
		 * Setters and getters
		 */ 
			
		public function get featureVector():Vector.<Feature>
		{
			return _featureVector;
		}
		
		public function set featureVector(value:Vector.<Feature>):void
		{
			_featureVector = value;
		}
		
		public function get rssFile():XML
		{
			return _rssFile;
		}
		
		public function set rssFile(value:XML):void
		{
			_rssFile = value;
		}
		
		public function get title():String
		{
			return _title;
		}
		
		public function set title(value:String):void
		{
			_title = value;
		}
		public function get link():String
		{
			return _link;
		}
		
		public function set link(value:String):void
		{
			_link = value;
		}
		public function get description():String
		{
			return _description;
		}
		
		public function set description(value:String):void
		{
			_description = value;
		}

	}
}