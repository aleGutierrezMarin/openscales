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
	
	//parsing/building GPX 1.1 et 1.0
	/**
	 * todo finish this list
	 * limitations:
	 * - the element <extension/> is not supported
	 * 
	 */ 
	
	public class GPXFormat extends Format
	{
		private var _gpxFile:XML = null;
		private var _featuresVector:Vector.<Feature> = null;
		private var _extractAttributes:Boolean;
		private var _featuresids:HashMap = null; // the ID of the feature is fetched from the tag <name>
		//before adding the feature to the _featuresVector, check if its ID is already in the hashmap
		//skip this check if the name is missing
		
		private var _version:String = "1.1";
		
		private var _bounds:Bounds = null; 
       // the bounds of the whole collection of objects contained by the gpxFile
		
		//information on the gpxFile
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
			var pointNodes:XMLList = xmlNode..*::rtept; //the attributes of routePoints or trackPoint are ignored
			if(pointNodes.length() == 0)
				pointNodes = xmlNode..*::trkseg;
			
			var attributes:Object = {};
			var j:int = nodes.length() - pointNodes.length();
			var i:int;
			for(i = 0; i < j; ++i) {
				var name:String = nodes[i].localName();
				var value:Object = nodes[i].valueOf();
				/*if(name == null){
					continue;    
				}*/
					
				if((nodes[i].children().length() == 1)
					&& !(nodes[i].children().children()[0] is XML) && name != "name") {
					
					attributes[name] = value.children()[0].toXMLString(); 
				}
				if (name == "link"){
					attributes["href"] = String(nodes[i]..@href);
				}
				
				Util.extend(attributes, this.parseAttributes(nodes[i]));
			}   
			return attributes;
			
			return null;
		} 
		
		
		/**
		 * calls buildAttributeNodes
		 *
		 * @param featureVector: the objects based on which the gpx file will be created
		 * 
		 * @return: the gpx file 
		 */
		
		public function buildGpxFile(featureVector:Vector.<Feature>):XML{

			var gpxNode:XML = new XML("<gpx></gpx>"); 
			var i:uint;
			var j:uint;
			var vectorLength:uint = featureVector.length;
			var attNodes:XMLList;
			var featureNode:XML;
			var length:uint;
			for(i = 0; i < vectorLength; i++){
					
				if( featureVector[i] is PointFeature ){
					
					var point:Point = (featureVector[i] as PointFeature).point;
					featureNode = new XML("<wpt></wpt>");
					featureNode.@lat = point.x;
					featureNode.@lon = point.y;
					attNodes = this.buildAttributeNodes(featureVector[i]).children();
					length = attNodes.length();
					for(j = 0; j < length; j++)
						featureNode.appendChild(attNodes[j]);
					gpxNode.appendChild(featureNode);
				}
				else if(featureVector[i] is LineStringFeature){
					
					
				}
				
				
			}
			
			return gpxNode;
		}
		
		public function buildRouteNode(line:LineStringFeature):XML{
			
			//todo add name and attribute tags to the node
			var rteNode:XML = new XML("<rte></rte>");
			var attributes:Object = line.attributes;
			
			
			var lineS:LineString = line.lineString;
			var pointsVector:Vector.<Number> = lineS.getcomponentsClone();
			var length:uint = pointsVector.length;
			var i:uint;
			for( i = 0; i < length; i += 2 ){
				
				var rtept:XML = new XML("<rtept></rtept>");
				rtept.@lat = pointsVector[i];
				rtept.@lon = pointsVector[i + 1];
				rteNode.appendChild(rtept);
			}
			
			return rteNode;
		}
		
		/**
		 * @param feature
		 * 
		 * @return An xml containig the nodes created based on the feature attributes
		 * 
		 * The attribute nodes can be created in the same way, regardless of the type
		 * of feature because the routes and the tracks have the same type of
		 * attributes, in the same order; the waypoints may have additional attributes
		 * but the order remains unchanged
		 * 
		 */ 
		
		public function buildAttributeNodes(feature:Feature):XML{
			var att:Object = feature.attributes;
			var alist:XML = new XML("<container></container>");
			//the order of elements is important in gpx files
			//elements specific to points
			if (att.hasOwnProperty("ele"))
				alist.appendChild(new XML("<ele>" + att["ele"] + "</ele>"));
			if (att.hasOwnProperty("time"))
				alist.appendChild(new XML("<time>" + att["time"] + "</time>"));
			if (att.hasOwnProperty("magvar"))
				alist.appendChild(new XML("<magvar>" + att["magvar"] + "</magvar>"));
			if (att.hasOwnProperty("geoidheight"))
				alist.appendChild(new XML("<geoidheight>" + att["geoidheight"] + "</geoidheight>"));
			//elements common to points, routes and tracks
			if(feature.name)
				alist.appendChild(new XML("<name>" + feature.name + "</name>"));	
			if (att.hasOwnProperty("cmt"))
				alist.appendChild(new XML("<cmt>" + att["cmt"] + "</cmt>"));
			if (att.hasOwnProperty("desc"))
				alist.appendChild(new XML("<desc>" + att["desc"] + "</desc>"));
			if (att.hasOwnProperty("src"))
				alist.appendChild(new XML("<src>" + att["src"] + "</src>"));
			//differences between 1.0 & 1.1 
			
			if(this._version == "1.0")
			{
				if (att.hasOwnProperty("url"))
					alist.appendChild(new XML("<url>" + att["url"] + "</url>"));
				if (att.hasOwnProperty("urlname"))
					alist.appendChild(new XML("<urlname>" + att["urlname"] + "</urlname>"));
			}
			else
			{ // todo finish this + type element problem
				var linkNode:XML = new XML("<link></link>");
				
				if (att.hasOwnProperty("href"))
					linkNode.@href = att["href"];
				
				if (att.hasOwnProperty("text"))
					linkNode.appendChild(new XML("<text>" + att["text"] + "</text>"));
			}
			
			
			return alist;
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