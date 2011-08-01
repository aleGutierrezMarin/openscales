package org.openscales.core.format
{
	import flash.utils.getQualifiedClassName;
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Bounds;
	
	//parsing GPX 1.1
	
	public class GPXFormat extends Format
	{
		private var _gpxFile:XML = null;
		private var _featuresVector:Vector.<Feature> = null;
		private var _extractAttributes:Boolean;
		private var _featuresids:HashMap = null; // the ID of the gpx Member is considered to be the tag <name>
		//before adding the feature to the _featuresVector, check if its ID is already in the hashmap
		//skip this check if the name is missing
		
		//attributes contained by the metadata element
		private var _bounds:Bounds = null;

 // the bounds of the whole collection of objects contained by the gpxFile
		private var _fileName:String; // the name of the gpxFile
		private var _author:String;
		private var _description:String;
		
		public function GPXFormat(featuresids:HashMap,
								  extractAttributes:Boolean = true)
		{
			super();
			this._extractAttributes = extractAttributes;
			this._featuresids = featuresids;
			
		}
		
		/**
		 * calls parseFeature() to create the Feature objects and then adds them to a list of Features 
		 * 
		 * @param node A gpx file
		 *
		 * @return A vector of features
		 */

		public function parseGpxFile(gpxFile:XML):Vector.<Feature>{
			this.gpxFile = gpxFile;
			this._featuresVector = new Vector.<Feature>();
			
			var membersList:XMLList = this.gpxFile.children();
			var listLength:uint = membersList.length();
			var i:uint;
			for (i = 0; i < listLength; i++){
				
				var feature:Feature = this.parseFeature(membersList[i]);
				if (feature)
					this._featuresVector.push(feature);
			}
			
			return this._featuresVector;
		}

		/**
		 * calls parseAttributes() to get extract attribute data
		 *
		 * @param node An XML feature node
		 *
		 * @return A feature
		 */
		
		public function parseFeature(featureNode:XML):Feature
		{
			var featureName:XML = featureNode..*::name[0];	
			var i:uint;
			var feature:Feature = null;
			var coords:Vector.<Number> = null;
			var duplicateID:Boolean = false;
		
			if(featureNode.localName() == "metadata"){
				
				this.parseMetadataNode(featureNode);
			}
			
			
			if(featureName){
				if(this._featuresids && this._featuresids.containsKey(featureName.toString()))
					duplicateID = true;
			}
			
			if (duplicateID){
				return null;
			}
			else
			{
				if (featureNode.localName() == "wpt")
				{
					coords = this.parsePointCoords(featureNode);
					if (coords)
					{
						feature = new PointFeature(new Point(coords[0], coords[1]));	
						
					}
				}
				else if (featureNode.localName() == "rte")
				{
					
					
					var lineCoords:Vector.<Number> = this.parseLineStringCoords(featureNode);
					if (lineCoords)
					{	
						feature = new LineStringFeature(new LineString(lineCoords));
					}
				}
				else if (featureNode.localName() == "trk")
				{
					var trkSeg:XMLList = this._gpxFile..*::trkseg;
					var listLength:uint = trkSeg.length();
					var multiLine:MultiLineString = new MultiLineString();
					
					for(i = 0; i < listLength; i++){
						coords = this.parseLineStringCoords(trkSeg[i]);
						
						if (coords)
							multiLine.addLineString(new LineString(coords));
					}
					
					if(multiLine.componentsLength != 0)
						feature = new MultiLineStringFeature(multiLine);
					
				}
			
				if(feature && featureName){
				
					feature.name = featureName.toString();
				}
				
				if(feature && this._extractAttributes){
					
				}
				
				return feature;
				
			}
	
		}
		
		public function parseLineStringCoords(xmlNode:XML):Vector.<Number>{
		
			var i:uint;
			var coords:Vector.<Number>;
			var lineCoords:Vector.<Number> = new Vector.<Number>();
			var pointsList:XMLList = xmlNode..*::rtept;
			if (pointsList.length() == 0)
				pointsList = xmlNode..*::trkpt;
			
			//extract the length of the vector before the loop to optimize code
			var listLength:uint = pointsList.length();
			
			for(i = 0; i < listLength; i++){
				
				coords = this.parsePointCoords(pointsList[i]);
				if (coords)
				{
					lineCoords.push(coords[0]);
					lineCoords.push(coords[1]);	
				}
				
			}
			if(lineCoords.length != 0)
				return lineCoords;
			else return null;
			
		}
		
		public function parsePointCoords(xmlNode:XML):Vector.<Number> { 
			
			var coords:Vector.<Number> =  null;
			if(xmlNode.hasOwnProperty('@lat') && xmlNode.@lat.length() && 
			   xmlNode.hasOwnProperty('@lon') && xmlNode.@lon.length()){
				
				coords = new Vector.<Number>();
				coords.push(Number(xmlNode..@lat));
				coords.push(Number(xmlNode..@lon));
			
			}
	
			return coords; // if coords is null for a point, one or both of its coordinates are missing
		}
		
		public function parseMetadataNode(xmlNode:XML):void{
			var bounds:XML = xmlNode..*::bounds[0];
			this._bounds = new Bounds(Number(bounds..@minlat), Number(bounds..@minlon), 
				Number(bounds..@maxlat), Number(bounds..@maxlon));
			
			this._description = xmlNode..*::desc[0].toString();
			var authorNode:XML = xmlNode..*::author[0];
			this._author = authorNode..*::name[0].toString();
			
		}
		
		public function parseAttributes(xmlNode:XML):Object{
			
			
			return null;
		} 
		
		public function get gpxFile():XML
		{
			return _gpxFile;
		}

		public function set gpxFile(value:XML):void
		{
			_gpxFile = value;
		}

		public function get featuresVector():Vector.<Feature>
		{
			return _featuresVector;
		}

		public function set featuresVector(value:Vector.<Feature>):void
		{
			_featuresVector = value;
		}
		
		public function get bounds():Bounds
		{
			return _bounds;
		}
		
		public function set bounds(value:Bounds):void
		{
			_bounds = value;
		}
		
		public function get author():String
		{
			return _author;
		}
		
		public function set author(value:String):void
		{
			_author = value;
		}
		
	}
}