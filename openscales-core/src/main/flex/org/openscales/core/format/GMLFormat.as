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
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjPoint;
	
	/**
	 * Read/Write GML. Supports the GML simple features profile.
	 */
	public class GMLFormat extends Format
	{
		
		
		protected var _gmlns:String = "http://www.opengis.net/gml";
		
		protected var _gmlprefix:String = "gml";
		
		private var _extractAttributes:Boolean = true;
		
		private var _dim:Number;
		
		private var _onFeature:Function;
		
		private var _featuresids:HashMap;
		
		
		private var xmlString:String;
		private var sXML:String;
		private var eXML:String    = "</gml:featureMember></wfs:FeatureCollection>";// it must not have reference at wfs in sthis class
		private var eFXML:String   = "</gml:featureMember>";
		private var sFXML:String   = "<gml:featureMember>";
		private var step:int       = 200;
		private var lastInd:int    = 0;
		//fps
		private var allowedTime:Number = 10;
		private var startTime:Number = 0;
		private var savedIndex:Number = 0;
		private var sprite:Sprite = new Sprite();
		
		/**
		 * GMLFormat constructor
		 *
		 * @param extractAttributes
		 *
		 */
		public function GMLFormat(onFeature:Function,
								  featuresids:HashMap,
								  extractAttributes:Boolean = true) {
			this.extractAttributes = extractAttributes;
			this._onFeature=onFeature;
			this._featuresids = featuresids;
		}
		
		/**
		 * Read data
		 *
		 * @param data data to read/parse.
		 *
		 * @return features.
		 */
		
		
		override public function read(data:Object):Object {
			this.xmlString = data as String;
			data = null;
			if(this.xmlString.indexOf(this.sFXML)!=-1){
				var end:int = this.xmlString.indexOf(">",this.xmlString.indexOf(">")+1)+1;
				this.sXML = this.xmlString.slice(0,end);
				this.dim = 2;
				this.sprite.addEventListener(Event.ENTER_FRAME, this.readTimer);
			} else {
				this.xmlString = null;
			}
			return null;
		}
		
		
		private function readTimer(event:Event):void {
			startTime = getTimer();
			if(this.xmlString==null) {
				this.sprite.removeEventListener(Event.ENTER_FRAME,this.readTimer);
				return;
			}
			this.lastInd = this.xmlString.indexOf(this.sFXML,this.lastInd);
			if(this.lastInd==-1) {
				this.sprite.removeEventListener(Event.ENTER_FRAME,this.readTimer);
				return;
			}
			var xmlNode:XML;
			var feature:Feature;
			var end:int;		
			
			
			while(this.lastInd!=-1) {
				if (getTimer() - startTime > allowedTime){
					return;
				}
				
				end = this.xmlString.indexOf(eFXML,this.lastInd);
				if(end<0)
					break;
				xmlNode = new XML( this.sXML + this.xmlString.substr(this.lastInd,end-this.lastInd) + this.eXML )
				this.lastInd = this.xmlString.indexOf(this.sFXML,this.lastInd+1);
				if(this._featuresids.containsKey((xmlNode..@fid) as String))
					continue;
				
				feature = this.parseFeature(xmlNode);
				if (feature) {
					this._onFeature(feature, false, false);
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
		 * @return A vetor of feature
		 */
		public function parseFeature(xmlNode:XML):Feature {
			var geom:ICollection = null;
			var p:Vector.<Number> = new Vector.<Number>();
			var p2:Vector.<Geometry> = new Vector.<Geometry>();
			
			
			var feature:Feature = null;
			
			var i:int;
			var j:int;
			
			if (xmlNode..*::MultiPolygon.length() > 0) {
				var multipolygon:XML = xmlNode..*::MultiPolygon[0];
				
				geom = new MultiPolygon();
				var polygons:XMLList = multipolygon..*::Polygon;
				j = polygons.length();
				for (i = 0; i < j; i++) {
					var polygon:Polygon = this.parsePolygonNode(polygons[i]);
					geom.addComponent(polygon);
				}
			}

            else if (xmlNode..*::MultiLineString.length() > 0) {
				var multilinestring:XML = xmlNode..*::MultiLineString[0];
				
				geom = new MultiLineString();
				var lineStrings:XMLList = multilinestring..*::LineString;
				j = lineStrings.length();
				
				for (i = 0; i < j; ++i) {
					p = this.parseCoords(lineStrings[i]);
					if(p){
						var lineString:LineString = new LineString(p);
						geom.addComponent(lineString);
					}
				}
			} else if (xmlNode..*::MultiPoint.length() > 0) {
				var multiPoint:XML = xmlNode..*::MultiPoint[0];
				
				geom = new MultiPoint();
				
				var points:XMLList = multiPoint..*::Point;
				j = points.length();
				p = this.parseCoords(points[i]);
				if (p)
					geom.addPoints(p);
				
			} else if (xmlNode..*::Polygon.length() > 0) {
				var polygon2:XML = xmlNode..*::Polygon[0];
				
				geom = this.parsePolygonNode(polygon2);
			} else if (xmlNode..*::LineString.length() > 0) {
				var lineString2:XML = xmlNode..*::LineString[0];
				
				p = this.parseCoords(lineString2);
				if (p) {
					geom = new LineString(p);
				}
			} else if (xmlNode..*::Point.length() > 0) {
				var point:XML = xmlNode..*::Point[0];
				
				geom = new MultiPoint();
				p = this.parseCoords(point);
				if (p) {
					geom.addPoints(p);
				}
			}
			
			if (geom) {
				// Test more specific geom before because for is operator, a lineString is a multipoint for example (inheritance) 
				if (geom is MultiPolygon) {
					feature = new MultiPolygonFeature(geom as MultiPolygon);
				} else if (geom is Polygon) {
					feature = new PolygonFeature(geom as Polygon);
				} else if (geom is MultiLineString) {
					feature = new MultiLineStringFeature(geom as MultiLineString);
				} else if (geom is LineString) {
					feature = new LineStringFeature(geom as LineString);
				} else if (geom is MultiPoint) {
					feature = new MultiPointFeature(geom as MultiPoint);
				} else if (geom is Point) {
					feature = new PointFeature(geom as Point);
				} else {
					Trace.warn("GMLFormat.parseFeature: unrecognized geometry);"); 
					return null; 
				}
				
				feature.name = xmlNode..@fid;
				
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
				if((nodes[i].children().length() == 1)
					&& !(nodes[i].children().children()[0] is XML)) {
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
		public function parsePolygonNode(polygonNode:Object):Polygon {
			var linearRings:XMLList = polygonNode..*::LinearRing;
			// Optimize by specifying the array size
			var j:int = linearRings.length();
			var rings:Vector.<Geometry> = new Vector.<Geometry>();
			var i:int;
			for (i = 0; i < j; i++) {
				rings[i] = new LinearRing(this.parseCoords(linearRings[i]));
			}
			return new Polygon(rings);
		}
		
		/**
		 * Return an array of coords
		 */ 
		public function parseCoords(xmlNode:XML):Vector.<Number> {
			var x:Number, y:Number, left:Number, bottom:Number, right:Number, top:Number;
			
			var points:Vector.<Number>  = new Vector.<Number>();
			
			if (xmlNode) {
				
				var coordNodes:XMLList = xmlNode.*::posList;
				
				if (coordNodes.length() == 0) { 
					coordNodes = xmlNode.*::pos;
				}    
				
				if (coordNodes.length() == 0) {
					coordNodes = xmlNode.*::coordinates;
				}    
				
				var coordString:String = coordNodes[0].text();
				
				var nums:Array = (coordString) ? coordString.split(/[, \n\t]+/) : [];
				
				while (nums[0] == "") 
					nums.shift();
				
				var j:int = nums.length;
				while (nums[j-1] == "") 
					nums.pop();
				
				j = nums.length;
				var i:int;
				for(i = 0; i < j; i = i + this.dim) {
					x = Number(nums[i]);
					y = Number(nums[i+1]);
					var p:Point = new Point(x, y);
					if (this.internalProjSrsCode != null, this.externalProjSrsCode != null) {
						p.transform(this.externalProjSrsCode, this.internalProjSrsCode);
					}
					points.push(p.x);
					points.push(p.y);
				}
				return points
			}
			return points;
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
		
		
		/**
		 * create a GML Object
		 *
		 * @param geometry
		 *
		 * @return an XML
		 */
		public function buildGeometryNode(geometry:Object):XML {
			var gml:XML;
			var projectionxml:String = "srsName=\"http://www.opengis.net/gml/srs/epsg.xml#4326\"";
			if (getQualifiedClassName(geometry) == "org.openscales.geometry::MultiPolygon"
				) {
				gml = new XML("<" + this._gmlprefix + ":MultiPolygon xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\" " 
					           + projectionxml + " >"
							  +"</" + this._gmlprefix + ":MultiPolygon>");
				
				var polygonMember:XML = new XML("<" + this._gmlprefix + ":polygonMember xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">"
					                            + "</" + this._gmlprefix + ":polygonMember>");
				
				var polygon:XML = new XML("<" + this._gmlprefix + ":Polygon xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":Polygon>");
				var outerRing:XML = new XML("<" + this._gmlprefix + ":outerBoundaryIs xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":outerBoundaryIs>");
				var linearRing:XML = new XML("<" + this._gmlprefix + ":LinearRing xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":LinearRing>");
				//TODO improve this part of code to manage outer and inter ring and multipolygone
				linearRing.appendChild(this.buildCoordinatesNode(geometry.components[0]));
				outerRing.appendChild(linearRing);
				polygon.appendChild(outerRing);
				polygonMember.appendChild(polygon);
				
				gml.appendChild(polygonMember);
			}
			else if ( getQualifiedClassName(geometry) == "org.openscales.geometry::Polygon") {
				gml = new XML("<" + this._gmlprefix + ":MultiPolygon xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\" " +projectionxml + " ></" + this._gmlprefix + ":MultiPolygon>");
				
				var polygonMember:XML = new XML("<" + this._gmlprefix + ":polygonMember xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":polygonMember>");
				
				var polygon:XML = new XML("<" + this._gmlprefix + ":Polygon xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":Polygon>");
				var outerRing:XML = new XML("<" + this._gmlprefix + ":outerBoundaryIs xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":outerBoundaryIs>");
				var linearRing:XML = new XML("<" + this._gmlprefix + ":LinearRing xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"></" + this._gmlprefix + ":LinearRing>");
				//TODO improve this part of code to manage outer and inter ring
				var length:uint = (geometry as Polygon).componentsLength;
				for(var index:uint=0;i <length;i++ ){
					linearRing.appendChild(this.buildCoordinatesNode((geometry as Polygon).componentByIndex(index)));
				}				
				linearRing.appendChild(this.buildCoordinatesNode(geometry.components[0]));
				outerRing.appendChild(linearRing);
				polygon.appendChild(outerRing);
				polygonMember.appendChild(polygon);
				
				gml.appendChild(polygonMember);
			}
			else if (getQualifiedClassName(geometry) == "org.openscales.geometry::MultiLineString") 
			{
				gml = new XML("<" + this._gmlprefix + ":MultiLineString xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\" " +projectionxml + " >" +
					"</" + this._gmlprefix + ":MultiLineString>");
				
				var lineStringMember:XML = new XML("<" + this._gmlprefix + ":lineStringMember xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
					"</" + this._gmlprefix + ":lineStringMember>");
				
				var lineString:XML = new XML("<" + this._gmlprefix + ":LineString xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
					"</" + this._gmlprefix + ":LineString>");
				
				var length:uint = (geometry as MultiLineString).componentsLength;
				for(var index:uint=0;i <length;i++ ){
				 lineString.appendChild(this.buildCoordinatesNode((geometry as MultiLineString).componentByIndex(index)));
				}				
				lineStringMember.appendChild(lineString);
				
				
				gml.appendChild(lineStringMember);
			}
			else if (getQualifiedClassName(geometry) == "org.openscales.geometry::LineString") {
				gml = new XML("<" + this._gmlprefix + ":MultiLineString xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\" " +projectionxml + " >" +
					"</" + this._gmlprefix + ":MultiLineString>");
				
				var lineStringMember:XML = new XML("<" + this._gmlprefix + ":lineStringMember xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
					"</" + this._gmlprefix + ":lineStringMember>");
				
				var lineString:XML = new XML("<" + this._gmlprefix + ":LineString xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
					"</" + this._gmlprefix + ":LineString>");
				
				lineString.appendChild(this.buildCoordinatesNode(geometry));
				lineStringMember.appendChild(lineString);
				
				gml.appendChild(lineStringMember);
			}
			else if (getQualifiedClassName(geometry) == "org.openscales.geometry::MultiPoint") {
				
				gml = new XML("<" + this._gmlprefix + ":MultiPoint xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"  " +projectionxml + " >" +
					          "</" + this._gmlprefix + ":MultiPoint>");
				var parts:Object = "";
				parts = geometry.components;   
				
				var j:int = parts.length;
				var i:int;
				for (i = 0; i < j; ++i) { 
					var pointMember:XML = new XML("<" + this._gmlprefix + ":pointMember xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
						"</" + this._gmlprefix + ":pointMember>");
					var point:XML = new XML("<" + this._gmlprefix + ":Point xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
						"</" + this._gmlprefix + ":Point>");
					var length:uint = (geometry as MultiPoint).componentsLength;
					for(var index:uint=0;i <length;i++ ){
						point.appendChild(this.buildCoordinatesNode((geometry as MultiPoint).componentByIndex(index)));
					}	
					pointMember.appendChild(point);
					gml.appendChild(pointMember);
				}     
			} else if (getQualifiedClassName(geometry) == "org.openscales.geometry::Point") {
				parts = geometry;
				gml = new XML("<" + this._gmlprefix + ":Point xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\"  " +projectionxml + " >" +
					"</" + this._gmlprefix + ":Point>");
				gml.appendChild(this.buildCoordinatesNode(parts));
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
		public function buildCoordinatesNode(geometry:Object):XML {
			var coordinatesNode:XML = new XML("<" + this._gmlprefix + ":coordinates xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
				"</" + this._gmlprefix + ":coordinates>");
			coordinatesNode.@decimal = ".";
			coordinatesNode.@cs = ",";
			coordinatesNode.@ts = " ";
			var path:String = "";
			
			if(geometry is Point){
				
				if (this.internalProj != null && this.externalProj != null) {
					var p:ProjPoint = new ProjPoint(geometry.x, geometry.y);
					Proj4as.transform(internalProj, externalProj, p);
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
				var j:int = points.length -1;
				var i:int;
				var pointTemp:Point;
				for (i = 0; i < j; i=i+2) {
					if (this.internalProj != null && this.externalProj != null){
						pointTemp = new Point(points[i],points[i+1]);
					    pointTemp.transform(this.internalProj, this.externalProj);
						path += pointTemp.x + "," + pointTemp.y + " ";
					}else{
						path += points[i] + "," + points[i+1] + " ";
					}
					
				}
			  }
			}
			
			coordinatesNode.appendChild(path);
			
			return coordinatesNode;
		}
		
		
		//Getters and Setters
		
		public function get extractAttributes():Boolean {
			return this._extractAttributes;
		}
		
		public function set extractAttributes(value:Boolean):void {
			this._extractAttributes = value;
		}
		
		public function get dim():Number {
			return this._dim;
		}
		
		public function set dim(value:Number):void {
			this._dim = value;
		}
		
	}
}

