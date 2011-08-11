package org.openscales.core.format
{
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LinearRing;
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

		override public function read(data:Object):Object{
			
			this.rssFile = new XML(data);
			var items:XMLList = this.rssFile..*::item;
			var itemNumber:uint = items.length();
			var i:uint;
			
			for(i = 0; i < itemNumber; i++){
				
				this.featureVector.push(this.parseItem(items[i]));
				
			}
			
			return this.featureVector;
		}
		
		/**
		 * @return: a feature
		 * this function will also parse the feature attributes
		 * 
		 * @call
		 * 
		 */ 
		public function parseItem(item:XML):Feature{
			
			var children:XMLList = item.children();
			var childrenNum:uint = children.length();
			var i:uint;
			var feature:Feature = null;
			var id:String = null;
			
			for(i = 0; i < childrenNum; i++){
				var itemType:String = String((children[i] as XML).localName());
				
				if(itemType == "guid")
					id = children[i].toString();
				
				//a polygon element contains a list of pairs of coordinates 
				else if(itemType == "polygon"){
					var geom:Vector.<Geometry>;
					geom.push(LinearRing(this.parseCoords(children[i])));
					var polygon:Polygon = new Polygon(geom);
				}
			}
			
			return feature;
		}
		/**
		 * a pair of coordinates represents latitude then longitude (WGS84 reference)
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