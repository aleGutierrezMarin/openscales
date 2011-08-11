package org.openscales.core.format
{
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.PolygonFeature;

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
		
		public function parseItem(item:XML):Feature{
			
			var children:XMLList = item.children();
			var childrenNum:uint = children.length();
			var s:String = String((children[childrenNum - 1] as XML).localName());
			
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