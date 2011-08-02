package org.openscales.core.format
{
	import flash.utils.getQualifiedClassName;
	
	import org.openscales.core.Util;
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
	
	//parsing GPX 1.1 et 1.0
	
	public class GPXFormat extends Format
	{
		private var _gpxFile:XML = null;
		private var _featuresVector:Vector.<Feature> = null;
		private var _extractAttributes:Boolean;
		private var _featuresids:HashMap = null; // the ID of the gpx Member is considered to be the tag <name>
		//before adding the feature to the _featuresVector, check if its ID is already in the hashmap
		//skip this check if the name is missing
		
		private var _version:String = "1.1";
		
		private var _bounds:Bounds = null; 
       // the bounds of the whole collection of objects contained by the gpxFile
		
		//information about the gpxFile
		private var _fileName:String; 
		private var _author:String;   
		private var _description:String;
		private var _authorEmail:String;
		private var _fileURL:String;
		
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
			var j:uint = 0;
			if(gpxFile.hasOwnProperty('@version') && gpxFile.@version.length())
				this._version = String(gpxFile..@version);
			
			if(this._version == "1.0") {
				//extract the file information, stored in the first 9 nodes, at most
				//count the nodes that can't be turned into features
				for (i = 0; i < 9; i++){
					if(membersList[i].localName() == "name" ){
						this._fileName = membersList[i].toString();
						j++;
					}
					else if (membersList[i].localName() == "desc"){
						this._description = membersList[i].toString();
						j++;
					}
						
					else if(membersList[i].localName() == "author"){
						this._author = membersList[i].toString();
						j++;
					}
					else if(membersList[i].localName() == "email"){
						this._authorEmail = membersList[i].toString();
						j++;
					}
						
					else if(membersList[i].localName() == "url"){
						this._fileURL = membersList[i].toString();
						j++;
					}
					else if(membersList[i].localName() == "bounds"){
						var bounds:XML = gpxFile..*::bounds[0];
						this._bounds = new Bounds(Number(bounds..@minlat), Number(bounds..@minlon), 
							Number(bounds..@maxlat), Number(bounds..@maxlon));
						j++;
					}
				}
			}
				
			for (i = j; i < listLength; i++){
				var feature:Feature = this.parseFeature(membersList[i]);
				if (feature){
					this._featuresVector.push(feature);
					this._featuresids.put(feature.name, feature);
				}
				
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
		
			if(featureNode.localName() == "metadata"){ //available only for the 1.1 version
				
				this.parseMetadataNode(featureNode);
			}
			else
			{	//check if ID already exists
				if(featureName){
					if(this._featuresids && this._featuresids.containsKey(featureName.toString()))
						return null; 
				}

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
					var trkSeg:XMLList = featureNode..*::trkseg;
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
					feature.attributes = this.parseAttributes(featureNode);
					
				}
				
				return feature;
				
			}
			return null;
	
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
		
		/**
		 * This function is called only if the version of the gpx is 1.1
		 */
		
		public function parseMetadataNode(xmlNode:XML):void{
			
			var nodes:XMLList = xmlNode.children();
			var i:uint;
			var nodesLength:uint = nodes.length();
			for(i = 0; i < nodesLength; i++){
				if(nodes[i].localName() == "name" )
					this._fileName = nodes[i].toString();
				else if (nodes[i].localName() == "desc")
					this._description = nodes[i].toString();
				else if(nodes[i].localName() == "author"){
					this._author = nodes[i]..*::name[0].toString();
					var emailNode:XML = nodes[i]..*::email[0];
					this._authorEmail = String(emailNode..@id) + String(emailNode..@domain);
				}
				else if(nodes[i].localName() == "link")
					this._fileURL = String(nodes[i]..@href);
				else if(nodes[i].localName() == "bounds"){
					var bounds:XML = xmlNode..*::bounds[0];
					this._bounds = new Bounds(Number(bounds..@minlat), Number(bounds..@minlon), 
						Number(bounds..@maxlat), Number(bounds..@maxlon));
				}
			}
			
		}
		
		public function parseAttributes(xmlNode:XML):Object{	
			var nodes:XMLList = xmlNode.children();
			var attributes:Object = {};
			var j:int = nodes.length();
			var i:int;
			for(i = 0; i < j; ++i) {
				var name:String = nodes[i].localName();
				var value:Object = nodes[i].valueOf();
				if(name == null){
					continue;    
				}
					
				if((nodes[i].children().length() == 1)
					&& !(nodes[i].children().children()[0] is XML) && name != "name") {
					attributes[name] = value.children()[0].toXMLString(); 
				}
				Util.extend(attributes, this.parseAttributes(nodes[i]));
			}   
			return attributes;
			
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