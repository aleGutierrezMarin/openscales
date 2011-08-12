package org.openscales.core.format
{
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
		 * Supported GeoRss version: 1.1 
		 * @see GeoRss Schema at http://www.georss.org/xml/1.1/georss.xsd 
		 * 
		 * Suported Rss version: 2.0
		 * 
		 * @attribute rssFile: the GeoRss data 
		 * @attribute featureVector
		 */
	
		private var _rssFile:XML;
		private var _featureVector:Vector.<Feature>;
		
		public function GeoRssFormat()
		{
			super();
		}

		/**
		 * @calls parseItem to create the features and add them to featureVector
		 * 
		 * @param: data to parse (a GeoRss file)
		 * @return: Object (a vector of features)
		 */

		override public function read(data:Object):Object{
			
			this.rssFile = new XML(data);
			var items:XMLList = this.rssFile..*::item;
			var itemNumber:uint = items.length();
			var i:uint;
			
			for(i = 0; i < itemNumber; i++){
				
				var feature:Feature = this.parseItem(items[i]);
				if(feature)
					this.featureVector.push(feature);	
			}
			
			return this.featureVector;
		}
		
		/**
		 * @return: a feature
		 * This function will also parse the feature attributes
		 * 
		 * @call
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
				var itemType:String = String((children[i] as XML).localName());
				
				if(itemType == "guid")
					id = children[i].toString();
				
				//a polygon element contains at least 3 pairs of coordinates @see geoRss schema 
				else if(itemType == "polygon"){	
					coords = this.parseCoords(children[i]);
					if(coords.length >= 6)
					{
						var ringGeom:Vector.<Geometry>;
						ringGeom.push(LinearRing(coords));
						feature = new PolygonFeature(new Polygon(ringGeom));
					}		
				}		
				else if(itemType == "point"){
					coords = this.parseCoords(children[i]);
					if(coords.length == 2){
						feature = new PointFeature(new Point(coords[0],coords[1])); //longitude, latitude
					}	
				}
				//a line element contains at least 2 pairs of coordinates @see geoRss schema 
				else if(itemType == "line"){
					coords = this.parseCoords(children[i]);
					if(coords.length >= 4){
						feature = new LineStringFeature(new LineString(coords));
					}
				}
				//external geometry: GML 3.1.1 content
				else if(itemType == "where"){
					this.parseExternalGeom(children[i] as XML);
				}
				//parse attributes
				else {
					if((children[i].children().length()) > 0)
					att[itemType] = children[i].toString();
				}
			}
			
			if(feature)
				feature.attributes = att;
			return feature;
		}
		
		public function parseExternalGeom(whereNode:XML):void{
			//default CRS for GML: WSG84: latitude, longitude (in that order)
			var i:uint;
			var gmlFormat:GML311 = new GML311();
			var gmlList:XMLList = whereNode.children();
			var j:uint = gmlList.length();
			for(i = 0; i < j; i++){
				var feature:Feature = gmlFormat.parseFeature(gmlList[i],false);
				if(feature)
					this.featureVector.push(feature);
			}
		}
		
		/**
		 * A pair of coordinates represents latitude then longitude (WGS84 reference)
		 * In openScales, the order of coordinates is: longitude then latitude
		 */ 
		
		public function parseCoords(node:XML):Vector.<Number>{
			
			var coordsVector:Vector.<Number>;
			var coords:String = node.toString();
			var coordNum:uint = coords.split(" ").length;
			var i:uint;
			for(i = 0; i < coordNum; i += 2){
				coordsVector.push(coords.split(" ")[i+1]);
				coordsVector.push(coords.split(" ")[i]);
			}
							
			
			return null;
		}		
		
		/**
		 * Setters & getters
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
		
	}
}