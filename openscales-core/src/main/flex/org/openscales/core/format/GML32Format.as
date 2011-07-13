package org.openscales.core.format
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.xml.XMLNode;
	
	import org.openscales.core.Trace;
	import org.openscales.core.Util;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.ICollection;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjPoint;
	
	
	/**
	 * Read/Write GML. Supports the GML simple features profile.
	 */
	public class GML32Format extends Format
	{
		private namespace gml="http://www.opengis.net/gml/3.2";
		
		private var gmlns:Namespace = new Namespace("gml", "http://www.opengis.net/gml/3.2");
		
		protected var _gmlns:String = "http://www.opengis.net/gml/3.2";
		
		protected var _gmlprefix:String = "gml";
		
		protected var _gmlsrsdim:String = "srsDimension=";
		
		private var _extractAttributes:Boolean = true;
		
		private var _onFeature:Function;
		
		private var _featuresids:HashMap;
		
		private var _gmlFile:XML;
		
		private var projectionxml:String = "srsName=\"http://www.opengis.net/gml/srs/epsg.xml#4326\"";	
		
		private var projection:String = "http://www.opengis.net/gml/srs/epsg.xml#4326";
		
		private var xmlString:String;
		private var sXML:String;
		private var eXML:String    = "</wfs:member></wfs:FeatureCollection>";// it must not have reference at wfs in sthis class
		private var eFXML:String   = "</wfs:member>";
		private var sFXML:String   = "<wfs:member>";
		private var lastInd:int    = 0;
		//fps
		private var allowedTime:Number = 10; /* 10 milisecondes */
		private var startTime:Number = 0;
		private var savedIndex:Number = 0;
		private var sprite:Sprite = new Sprite();
		
		private var dim:uint = 2;
		
		
		
		/**
		 * GMLFormat constructor
		 *
		 * @param extractAttributes
		 *
		 */
		public function GML32Format(onFeature:Function,
									featuresids:HashMap,
									extractAttributes:Boolean = true) 
		{
			this.extractAttributes = extractAttributes;
			this._onFeature=onFeature;
			this._featuresids = featuresids;
			this._gmlFile = new XML();
		}
		
		/**
		 * Read data
		 *
		 * @param data data to read/parse.
		 *
		 * @return features.
		 */
		override public function read(data:Object):Object {
			this.xmlString = data as String; /* data = the xml file */
			data = null;
			if(this.xmlString.indexOf(this.sFXML)!=-1){ /* if xmlString contains "<wfs:member>" */
				var end:int = this.xmlString.indexOf(">",this.xmlString.indexOf(">")+1)+1; 
				this.sXML = this.xmlString.slice(0,end); 
				this.sprite.addEventListener(Event.ENTER_FRAME, this.readTimer); /* an event on a frame triggers the readTimer function */
			} else { 
				this.xmlString = null;
			}
			return null;
		}
		
		/**
		 * Creates a FeatureCollectionNode as a gml file
		 * Contains multiple FeatureNodes
		 * 
		 */
		
		public function buildFeatureCollectionNode(featureCol:Vector.<Feature>, ns:String, featureType:String, geometryName:String):XML{

			var i:uint;
			var wfsns:Namespace = new Namespace("wfs","http://www.opengis.net/wfs/2.0");
			var collectionNode:XML = new XML("<FeatureCollection></FeatureCollection>");
			collectionNode.addNamespace(wfsns);
			collectionNode.addNamespace(gmlns);
			collectionNode.setNamespace(wfsns);
			
			for(i=0; i<featureCol.length; i++){
				
				/* calculate and add an Envelope for each wfs:member; create a buildEnvelope function*/
				var wfsNode:XML = new XML("<member></member>");
				wfsNode.setNamespace(wfsns);
				var featureNode:XML = buildFeatureNode (featureCol[i],ns,featureType,geometryName);
				wfsNode.appendChild(featureNode);
				collectionNode.appendChild(wfsNode);
				
			}
			return collectionNode;
		}
		
		/**
		 * Creates a FeatureNode as a gml file 
		 * 
		 */
		
		public function buildFeatureNode(feature:Feature, ns:String, featureType:String, geometryName:String):XML{
			
			var i:uint;
			var nsName:String = ns.split("=")[0];
			var nsURL:String = ns.split("\"")[1];
			var geomns:Namespace = new Namespace(nsName, nsURL);
			
			var featureNode:XML = new XML("<"+featureType+"></"+featureType+">");
			featureNode.addNamespace(geomns);
			featureNode.setNamespace(geomns);
			featureNode.addNamespace(gmlns);
			
			var xmlNode:XML = new XML ("<"+geometryName+"></"+geometryName+">"); 
			xmlNode.setNamespace(geomns);
			
			featureNode.appendChild(xmlNode);
			if(feature is PointFeature){
				
				var pf:PointFeature = feature as PointFeature;
				var point:Point = pf.point as Point;
				xmlNode.appendChild(this.buildPointNode(point));	
			}else if(feature is PolygonFeature){
				
				var polygonFeature:PolygonFeature = feature as PolygonFeature;
				var polygon:Polygon = polygonFeature.polygon;
				xmlNode.appendChild(this.buildPolygonNode(polygon));
				
			}else if (feature is MultiPolygonFeature){
				/* builds a MultiSurface tag with multiple surfaceMembers (polygons) inside */
				
				var multiSurfaceNode:XML = new XML("<MultiSurface></MultiSurface>");
				multiSurfaceNode.setNamespace(gmlns);
				multiSurfaceNode.@srsDimension = this.dim;
				multiSurfaceNode.@srsName = this.projection;
			
				var mpf:MultiPolygonFeature = feature as MultiPolygonFeature;
				var mp:MultiPolygon = mpf.polygons;
				var polygonVector:Vector.<Geometry> = mp.getcomponentsClone();
				
				for(i=0; i<mp.componentsLength; i++){ /* create a subnode for each Polygon inside the multiSurface tag */
					var surfaceMemberNode:XML = new XML("<surfaceMember></surfaceMember>");
					surfaceMemberNode.setNamespace(gmlns);
					surfaceMemberNode.appendChild(this.buildPolygonNode(polygonVector[i] as Polygon));
					multiSurfaceNode.appendChild(surfaceMemberNode);
				}
				xmlNode.appendChild(multiSurfaceNode);
				
			}else if (feature is MultiPointFeature){
				var multiPointNode:XML = new XML("<MultiPoint></MultiPoint>");
				multiPointNode.setNamespace(gmlns);
				multiPointNode.@srsDimension = this.dim;
				multiPointNode.@srsName = this.projection;
			
				var multiPointFeature:MultiPointFeature = feature as MultiPointFeature;
				var multiPoint:MultiPoint = multiPointFeature.points as MultiPoint;
				var points:Vector.<Point> = multiPoint.toVertices();
				for(i = 0; i < points.length; i++){
					var pointMember:XML = new XML("<pointMember></pointMember>");
					pointMember.setNamespace(gmlns);
					pointMember.appendChild(this.buildPointNode(points[i]));
					multiPointNode.appendChild(pointMember);					
				}
				xmlNode.appendChild(multiPointNode);
				
			}else if (feature is LineStringFeature){
				
				var lsf:LineStringFeature = feature as LineStringFeature;
				var lineString:LineString = lsf.lineString as LineString;
				xmlNode.appendChild(this.buildLineStringNode(lineString));
				
			}else if (feature is MultiLineStringFeature){
				var mlsNode:XML = new XML("<MultiCurve></MultiCurve>");
				mlsNode.setNamespace(gmlns);
				mlsNode.@srsDimension = this.dim;
				mlsNode.@srsName = this.projection;
				
				var mlsf:MultiLineStringFeature = feature as MultiLineStringFeature;
				var mls:MultiLineString = mlsf.lineStrings as MultiLineString;
				var lsVector:Vector.<Geometry> = mls.getcomponentsClone();
				for(i = 0; i < mls.componentsLength; i++){
					var lsMember:XML = new XML("<curveMember></curveMember>");
					lsMember.setNamespace(gmlns);
					lsMember.appendChild(this.buildLineStringNode(lsVector[i] as LineString));
					mlsNode.appendChild(lsMember);					
				}
				xmlNode.appendChild(mlsNode);
			}
		
			return featureNode; 
		}
		
		
		public function buildPointNode(point:Point):XML{
			var pointNode:XML = new XML("<Point></Point>");
			pointNode.setNamespace(gmlns);
			pointNode.pos = String(point.x)+" "+String(point.y);
			pointNode.children().setNamespace(gmlns);
			pointNode.@srsDimension = this.dim;
			pointNode.@srsName = this.projection;
			return pointNode;
		}
		
		public function buildLineStringNode(lineString:LineString):XML{
			var i:uint;
			var coord:Vector.<Number> = lineString.components;
			var coordList:String = "";
			for(i=0; i<coord.length; i++){
				coordList+=String(coord[i]);
				if (i!=coord.length)
					coordList+=" ";
			}
			
			var lineStringNode:XML = new XML("<LineString></LineString>");
			lineStringNode.setNamespace(gmlns);
			lineStringNode.posList=coordList;
			lineStringNode.children().setNamespace(gmlns);
			lineStringNode.@srsDimension = this.dim;
			lineStringNode.@srsName = this.projection;
			return lineStringNode;
		}
		
		public function buildPolygonNode(polygon:Polygon):XML{
			var i:uint;
			var polygonNode:XML = new XML("<Polygon></Polygon>");
			polygonNode.setNamespace(gmlns);
		
			var linearRings:Vector.<Geometry> = polygon.getcomponentsClone();
			var exteriorRing:LinearRing = linearRings[0] as LinearRing;
			var exteriorRingNode:XML = buildLinearRingNode("exterior",exteriorRing);
			polygonNode.appendChild(exteriorRingNode);
			
			if(polygon.componentsLength> 1){/* if multiple LinearRings inside the Polygon => one is exterior and the others are interior*/
				for(i=1; i<polygon.componentsLength; i++){ /* for each interior LinearRing*/
					var interiorRing:LinearRing = linearRings[i] as LinearRing;
					var interiorNode:XML = this.buildLinearRingNode("interior", interiorRing);
					polygonNode.appendChild(interiorNode);
					
				}
				
			}
			
			return polygonNode;
		}
		
		public function buildLinearRingNode(type:String, ring:LinearRing):XML{
			var i:uint;
			var ringNode:XML = new XML("<"+type+"></"+type+">");
			ringNode.setNamespace(gmlns);
			
			var linearRingNode:XML = new XML("<LinearRing></LinearRing>");
			linearRingNode.setNamespace(gmlns);
			ringNode.appendChild(linearRingNode);

			var coordList:String = "";
			for(i=0; i<ring.components.length; i++)
			{
				coordList += String(ring.components[i]);
				if (i != ring.componentsLength - 1)
					coordList += " ";
			}
			linearRingNode.posList = coordList;
			linearRingNode.children().setNamespace(gmlns);
			return ringNode;
		}
		
		
		/**
		 * 
		 * @param event
		 * 
		 */
		
		private function readTimer(event:Event):void {
			startTime = getTimer();
			if(this.xmlString==null) {
				this.sprite.removeEventListener(Event.ENTER_FRAME,this.readTimer);
				return;
			}
			this.lastInd = this.xmlString.indexOf(this.sFXML,this.lastInd); /* the index of the beginning of the 1st member (<wfs:member>) */
			if(this.lastInd==-1) {
				this.sprite.removeEventListener(Event.ENTER_FRAME,this.readTimer);
				return;
			}
			var xmlNode:XML;
			var feature:Feature;
			var end:int;		
			
			
			while(this.lastInd!=-1) { /* while the last member hasn't been reached */
				if (getTimer() - startTime > allowedTime){
					return;
				}
				
				end = this.xmlString.indexOf(eFXML,this.lastInd); /* the index of the end of the current member */
				if(end<0)
					break;
				xmlNode = new XML( this.sXML + this.xmlString.substr(this.lastInd,end-this.lastInd) + this.eXML ) /* create a node
				for the current member*/ 
				
				this.lastInd = this.xmlString.indexOf(this.sFXML,this.lastInd+1); /* update of the index of the beginning of the next member */
				if(this._featuresids.containsKey((xmlNode..@id) as String)) /* check if the memeber id is in the HashMap _featuresids */
					continue;
				feature = this.parseFeature(xmlNode);
				if (feature) {
					this._onFeature(feature, true, false);
				}
			}
			
			if(this.lastInd==-1) {
				this.sprite.removeEventListener(Event.ENTER_FRAME,this.readTimer);
				this.xmlString = null;
				this.sXML = null;
				return;
			}
			
		}
		
		
		public function reset():void {
			this.xmlString = null;
			this.sXML = null;
		}
		
		public function destroy():void {
			this.reset();
			this._onFeature = null;
		}
		
		public function boxNode(bound:Bounds):XML
		{
			
			var boxNode:XML = new XML("<" + this._gmlprefix + ":Box xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
				"</" + this._gmlprefix +":Box>"); /* <gml:Box xmlns:gml="http://www.opengis.net/gml"> </gml:Box> */
			var coodinateNode:XML = new XML("<" + this._gmlprefix + ":coordinates xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\" >" +
				"</" + this._gmlprefix +":coordinates>"); /* <gml:coordinates xmlns:gml="http://www.opengis.net/gml"> </gml:coordinates> */
			
			
			coodinateNode.appendChild(this.buildCoordinatesWithoutProjSrsCode(new <Number>[bound.left,bound.bottom,bound.right,bound.top]));			
			boxNode.appendChild(coodinateNode); 
			return boxNode;
		}
		
		/**
		 *    It creates the geometries that are then attached to the returned
		 *    feature, and calls parseAttributes() to get attribute data out.
		 * 
		 *    Important note: All geom node names 'the_geom.*::' have been removed 
		 * 	  until a config is implemented to be able to parse the geom nodes in a
		 *    generic way. See Issue 185 for more info.
		 *
		 * @param node A XML feature node.
		 *
		 * @return A vector of feature
		 */
		public function parseFeature(xmlNode:XML):Feature {
			
			use namespace gml;
			
			var geom:ICollection = null;
			var p:Vector.<Number> = new Vector.<Number>();	
			var feature:Feature = null;
			
			var i:int;
			var j:int;
			var dim:Number = 2; /* if not specified, the dimension is 2 by default */;
			var envelope:XML = xmlNode..*::Envelope[0];
			var dimensionError:Boolean = false;
			
			if (xmlNode..*::MultiSurface.length() > 0) {
				var multiSurface:XML = xmlNode..*::MultiSurface[0]; /* 0..1 MultiSurface */
				if(multiSurface.hasOwnProperty('@srsDimension') && multiSurface.@srsDimension.length() )
				{
					dim = Number(multiSurface.@srsDimension);
					if (envelope.hasOwnProperty('@srsDimension') && envelope.@srsDimension.length())
						if(dim != Number(envelope.@srsDimension)){
							dimensionError = true;
						}
							
				}
				
				if (!dimensionError){
					geom = new MultiPolygon();
					var polygons:XMLList = multiSurface..*::Polygon; 
					j = polygons.length();
					for (i = 0; i < j; i++) { /* parse every polygon in the vector */
						var polygon:Polygon = this.parsePolygonNode(polygons[i], dim); 
						geom.addComponent(polygon);
					}
					feature = new MultiPolygonFeature(geom as MultiPolygon);
				}

				
			} else if (xmlNode..*::MultiCurve.length() > 0) { 
				var multiCurve:XML = xmlNode..*::MultiCurve[0];
				if( multiCurve.hasOwnProperty('@srsDimension') && multiCurve.@srsDimension.length() )
				{
					dim = Number(multiCurve.@srsDimension);
				}
				
				geom = new MultiLineString();
				var lineStrings:XMLList = multiCurve..*::LineString;
				j = lineStrings.length();
				
				for (i = 0; i < j; ++i) {
					p = this.parseCoords(lineStrings[i],dim);
					if(p){
						if(p.length != 0){
							var lineString:LineString = new LineString(p);
							geom.addComponent(lineString);
						}
						
					}
				}
				feature = new MultiLineStringFeature(geom as MultiLineString);
			} else if (xmlNode..*::MultiPoint.length() > 0) {
				var multiPoint:XML = xmlNode..*::MultiPoint[0];
				if( multiPoint.hasOwnProperty('@srsDimension') && multiPoint.@srsDimension.length() )
				{
					dim = Number(multiPoint.@srsDimension);
				}
				
				geom = new MultiPoint();
				
				var points:XMLList = multiPoint..*::Point;
				j = points.length();
				for(i = 0; i < j; i++){
					p = this.parseCoords(points[i],dim);
					if (p)
						if ( p.length != 0 ){
							geom.addPoints(p);
						}
				}			
				feature = new MultiPointFeature(geom as MultiPoint);
				
			} else if (xmlNode..*::Polygon.length() > 0) {
				var polygon2:XML = xmlNode..*::Polygon[0];
				if( polygon2.hasOwnProperty('@srsDimension') && polygon2.@srsDimension.length() )
				{
					dim = Number(polygon2.@srsDimension);
				}
				
				feature = new PolygonFeature(this.parsePolygonNode(polygon2,dim));
			} else if (xmlNode..*::LineString.length() > 0) {
				var lineString2:XML = xmlNode..*::LineString[0];
				if( lineString2.@srsDimension != null )
				{
					dim = Number(lineString2.@srsDimension);
				}
				
				p = this.parseCoords(lineString2,dim);
				if (p) {
					if (p.length != 0){
						geom = new LineString(p);
					}
					
				}
				feature = new LineStringFeature(geom as LineString);
			} else if (xmlNode..*::Point.length() > 0) {
				var point:XML = xmlNode..*::Point[0];
				if( point.hasOwnProperty('@srsDimension') && point.@srsDimension.length() )
				{
					dim = Number(point.@srsDimension);
				}
				
				var pointObject:Point; 
				p = this.parseCoords(point,dim);
				if (p) {
					if (p.length != 0){
						pointObject = new Point(p[0],p[1]);
						feature = new PointFeature(pointObject);
					}
					
					
				}
			}else{
				Trace.warn("GMLFormat.parseFeature: unrecognized geometry);"); 
				return null; 
			}
			if (feature) {
				feature.name = xmlNode..@id;
				
				if (this.extractAttributes) { 
					feature.attributes = this.parseAttributes(xmlNode);
				}    
				//todo see if the feature is locked or can be modified
				feature.isEditable = true;
				return feature;
				
			} else {
				return null;
			}
		}
		
		/**
		 * Parse attributes
		 *
		 * @param node A XML feature node.
		 *
		 * @return An attributes object.
		 */
		public function parseAttributes(xmlNode:XML):Object {
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
				
				// Check for a leaf node
				
				var properties:Vector.<String> = new <String>["posList", "upperCorner", "lowerCorner"];
				if((nodes[i].children().length() == 1)
					&& !(nodes[i].children().children()[0] is XML) && properties.indexOf(name) == -1) {
					attributes[name] = value.children()[0].toXMLString(); 
				}
				Util.extend(attributes, this.parseAttributes(nodes[i]));
			}   
			return attributes;
		}
		
		/**
		 * Given a GML node representing a polygon geometry
		 *
		 * @param node
		 *
		 * @return A polygon geometry.
		 */
		public function parsePolygonNode(polygonNode:Object, dim:Number):Polygon {
			//exterior tag: only one LinearRing with its coordinates (posList)
			//interior tag: 0..* LinearRings
			
			var exterior:XMLList = polygonNode..*::exterior;
			var interior:XMLList = polygonNode..*::interior;
			
			var j:int = interior.length();
			var rings:Vector.<Geometry> = new Vector.<Geometry>();
			var i:uint = 0;
			
			var coords:Vector.<Number> = this.parseCoords(exterior[0]..*::LinearRing[0],dim);
			if(coords == null || coords.length == 0)
				return null;
			rings[i++] = new LinearRing(coords); 
			
			if(j != 0 ){
				for (var k:uint = 0; k < j; k++) {
					coords = this.parseCoords(interior[k],dim);
					if(coords == null || coords.length == 0)
						continue;
					rings[i++] = new LinearRing(coords);
				}
				
			}
			return new Polygon(rings);
		}
		
		/**
		 * Return an array of coords - Point objects (the coordinates of the LinearRing received as a parameter (xmlNode) )
		 */ 
		public function parseCoords(xmlNode:XML, dim:Number):Vector.<Number> { 
			var x:Number, y:Number, left:Number, bottom:Number, right:Number, top:Number;
			
			var points:Vector.<Number>  = new Vector.<Number>();
			/* length of points = 0 if the node is empty */
			
			if (xmlNode) {
				
				var coordNodes:XMLList = xmlNode..*::posList;
				
				if (coordNodes.length() == 0) { 
					coordNodes = xmlNode..*::pos;
				}    
				
				if (coordNodes.length() == 0) {
					coordNodes = xmlNode..*::coordinates;
				}    
				
				var coordString:String = coordNodes[0].text();
				
				var nums:Array = (coordString) ? coordString.split(/[, \n\t]+/) : [];
				
				while (nums[0] == "") 
					nums.shift();
				
				var j:int = nums.length;
				while (nums[j-1] == "") 
					nums.pop();
				
				j = nums.length;
				
				/* verifies if the dimension of the feature is compatible with the number of coordinates */
				if ( j % dim == 0 ){
					var i:int;
					for(i = 0; i < j; i = i + dim) {
						x = Number(nums[i]);
						y = Number(nums[i+1]);
						var p:Point = new Point(x, y);
						if (this.internalProjSrsCode != null, this.externalProjSrsCode != null) {
							p.transform(this.externalProjSrsCode, this.internalProjSrsCode);
						}
						points.push(p.x);
						points.push(p.y);
					}
					return points;
				}
				
			}
			return null;
		}
		
		/**
		 * Generate a GML document object given a list of features.
		 *
		 * @param features List of features to serialize into an object.
		 *
		 * @return An object representing the GML document.
		 */
		override public function write(features:Object):Object {
			var featureCollection:XML = new XML(""/*<" + this._wfsprefix + ":" + this._collectionName + " xmlns:" 
			+ this._wfsprefix + "=\"" + this._wfsns + "\"></" + this._wfsprefix + ":" + this._collectionName + ">"*/);
			/*
			var j:int = features.length;
			var i:int;
			for (i = 0; i < j; i++) {
			featureCollection.appendChild(this.createFeatureXML(features[i]));
			}*/
			return featureCollection;
		}
		public function buildpointNode(point:Point):XML{
			
			var pointMember:XML = new XML("<" + this._gmlprefix + ":pointMember xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
				"</" + this._gmlprefix + ":pointMember>");
			var pointXML:XML = new XML("<" + this._gmlprefix + ":Point xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"  " +projectionxml + " >" +
				"</" + this._gmlprefix + ":Point>");
			pointXML.appendChild(this.buildCoordinatesNode(point));
			pointMember.appendChild(pointXML);
			return pointMember;
		}
		/**
		 * write
		 * @param polygon
		 * @return xml
		 * 
		 */		
		public function buildpolygonNode(polygon:Polygon):XML {
			
			var polygonMember:XML = new XML("<" + this._gmlprefix + ":polygonMember xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":polygonMember>");
			
			var polygonXML:XML = new XML("<" + this._gmlprefix + ":Polygon xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":Polygon>");
			var outerRing:XML = new XML("<" + this._gmlprefix + ":outerBoundaryIs xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":outerBoundaryIs>");
			var innerRing:XML = new XML("<" + this._gmlprefix + ":innerBoundaryIs xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":innerBoundaryIs>");
			var linearRing:XML = new XML("<" + this._gmlprefix + ":LinearRing xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":LinearRing>");
			var linearRingInner:XML = new XML("<" + this._gmlprefix + ":LinearRing xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":LinearRing>");
			linearRing.appendChild(this.buildCoordinatesNode(polygon.componentByIndex(0)));
			outerRing.appendChild(linearRing);
			polygonXML.appendChild(outerRing);
			// 1 -> n linearing is innerBoundaryIs
			var length:uint = polygon.componentsLength;
			for(var i:uint=1;i <length;i++ ){
				linearRingInner.appendChild(this.buildCoordinatesNode(polygon.componentByIndex(i)));
			}			
			innerRing.appendChild(linearRingInner);
			polygonXML.appendChild(innerRing);
			polygonMember.appendChild(polygonXML);
			
			return polygonMember;
			
		}
		/**
		 * create a GML Object
		 *
		 * @param geometry
		 *
		 * @return an XML
		 */
		public function buildGeometryNode(geometry:Object):XML {
			var gml:XML;
			var length:uint,index:uint;
			
			if (getQualifiedClassName(geometry) == "org.openscales.geometry::MultiPolygon"
			) {
				gml = new XML("<" + this._gmlprefix + ":MultiPolygon xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\" " 
					+ projectionxml + " >"
					+"</" + this._gmlprefix + ":MultiPolygon>");
				
				var polygonMember:XML = new XML("<" + this._gmlprefix + ":polygonMember xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">"
					+ "</" + this._gmlprefix + ":polygonMember>");
				length = (geometry as MultiPolygon).componentsLength;
				for(index=0;index <length;index++ ){
					polygonMember.appendChild(this.buildCoordinatesNode((geometry as MultiPolygon).componentByIndex(index)));
				}
				
				gml.appendChild(polygonMember);
			}
			else if ( getQualifiedClassName(geometry) == "org.openscales.geometry::Polygon") {
				gml = new XML("<" + this._gmlprefix + ":Polygon xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\" " +projectionxml + " ></" + this._gmlprefix + ":Polygon>");
				var outerRing:XML = new XML("<" + this._gmlprefix + ":outerBoundaryIs xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":outerBoundaryIs>");
				var linearRing:XML = new XML("<" + this._gmlprefix + ":LinearRing xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":LinearRing>");
				linearRing.appendChild(this.buildCoordinatesNode(geometry.componentByIndex(0)));
				outerRing.appendChild(linearRing);
				length = geometry.componentsLength;
				// 1 -> n linearing is innerBoundaryIs
				if(length > 1){
					var innerRing:XML = new XML("<" + this._gmlprefix + ":innerBoundaryIs xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":innerBoundaryIs>");
					var linearRingInner:XML = new XML("<" + this._gmlprefix + ":LinearRing xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":LinearRing>");
					for(var i:uint=1;i <length;i++ ){
						linearRingInner.appendChild(this.buildCoordinatesNode(geometry.componentByIndex(i)));
					}
					innerRing.appendChild(linearRingInner);
					gml.appendChild(innerRing);
				}
				gml.appendChild(outerRing);
			}
			else if (getQualifiedClassName(geometry) == "org.openscales.geometry::MultiLineString") 
			{
				gml = new XML("<" + this._gmlprefix + ":MultiLineString xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\" " +projectionxml + " >" +
					"</" + this._gmlprefix + ":MultiLineString>");
				
				var lineStringMember:XML = new XML("<" + this._gmlprefix + ":lineStringMember xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
					"</" + this._gmlprefix + ":lineStringMember>");
				
				var lineString:XML = new XML("<" + this._gmlprefix + ":LineString xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
					"</" + this._gmlprefix + ":LineString>");
				
				length = (geometry as MultiLineString).componentsLength;
				for(index=0;index <length;index++ ){
					lineString.appendChild(this.buildCoordinatesNode((geometry as MultiLineString).componentByIndex(index)));
				}				
				lineStringMember.appendChild(lineString);
				
				
				gml.appendChild(lineStringMember);
			}
			else if (getQualifiedClassName(geometry) == "org.openscales.geometry::LineString") {
				gml  = new XML("<" + this._gmlprefix + ":LineString xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\" " +projectionxml + " >" +
					"</" + this._gmlprefix + ":LineString>");
				gml.appendChild(this.buildCoordinatesNode(geometry));
			}
			else if (getQualifiedClassName(geometry) == "org.openscales.geometry::MultiPoint") {
				
				gml = new XML("<" + this._gmlprefix + ":MultiPoint xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"  " +projectionxml + " >" +
					"</" + this._gmlprefix + ":MultiPoint>");
				length = (geometry as MultiPoint).componentsLength;
				for(index=0;index <length;index++ ){
					gml.appendChild(buildPointNode(((geometry as MultiPoint).componentByIndex(index)) as Point))
				}	
				
			} else if (getQualifiedClassName(geometry) == "org.openscales.geometry::Point") {
				gml = new XML("<" + this._gmlprefix + ":Point xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"  " +projectionxml + " >" +
					"</" + this._gmlprefix + ":Point>");
				gml.appendChild(this.buildCoordinatesNode(geometry));
			}
			return gml; 
		}
		
		
		/**
		 * Builds the coordinates XmlNode
		 *
		 * @param geometry
		 *
		 * @return created xmlNode
		 */
		public function buildCoordinatesNode(geometry:Object):XML 
		{
			var coordinatesNode:XML = new XML("<" + this._gmlprefix + ":coordinates xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
				"</" + this._gmlprefix + ":coordinates>");
			coordinatesNode.@decimal = ".";
			coordinatesNode.@cs = ",";
			coordinatesNode.@ts = " ";
			var path:String = "";
			
			if(geometry is Point){
				
				if (this._internalProjSrsCode != null && this._externalProjSrsCode != null) {
					var p:ProjPoint = new ProjPoint(geometry.x, geometry.y);
					Proj4as.transform(_internalProjSrsCode, _externalProjSrsCode, p);
					geometry.x = p.x;
					geometry.y = p.y;
				}
				path += geometry.x + "," + geometry.y + " ";
				
			}else{
				var points:Vector.<Number> = null;
				if (geometry.components) {
					if (geometry.components.length > 0) {
						points = geometry.components;
					}
				}
				
				if (points) {
					path = buildCoordinatesNodeFromVector(points);
					if(geometry is LinearRing){
						if (this._internalProjSrsCode != null && this._externalProjSrsCode != null){
							var pointTemp:Point = new Point(points[0],points[1]);
							pointTemp.transform(this._internalProjSrsCode, this._externalProjSrsCode);
							path += pointTemp.x + "," + pointTemp.y + " ";
						}else{
							path += points[0] + "," + points[1] + " ";
						}
					}
				}
			}
			
			coordinatesNode.appendChild(path);
			
			return coordinatesNode;
		}
		
		public function buildCoordinatesNodeFromVector(points:Vector.<Number>):String {
			
			var j:int = points.length -1;
			var i:int;
			var pointTemp:Point;
			var path:String = "";
			for (i = 0; i < j; i=i+2) {
				if (this._internalProjSrsCode != null && this._externalProjSrsCode != null){
					
					pointTemp = new Point(points[i],points[i+1]);
					pointTemp.transform(this._internalProjSrsCode, this._externalProjSrsCode);
					path += pointTemp.x + "," + pointTemp.y + " ";
					
				}else{
					path += points[i] + "," + points[i+1] + " ";
				}
				
			}
			return path;
		}
		
		public function buildCoordinatesWithoutProjSrsCode(points:Vector.<Number>):String {
			
			var j:int = points.length -1;
			var i:int;
			var pointTemp:Point;
			var path:String = "";
			for (i = 0; i < j; i=i+2) {
				path += points[i] + "," + points[i+1] + " ";
				
			}
			return path;
		}
		
		
		
		//Getters and Setters
		
		public function get extractAttributes():Boolean {
			return this._extractAttributes; /* codé en dur = true */
		}
		
		public function set extractAttributes(value:Boolean):void {
			this._extractAttributes = value;
		}
		
	}
}

