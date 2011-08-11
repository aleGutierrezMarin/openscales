package org.openscales.core.format
{
	import org.openscales.core.feature.Feature;

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