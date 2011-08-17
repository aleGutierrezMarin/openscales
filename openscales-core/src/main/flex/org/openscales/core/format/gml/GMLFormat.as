package org.openscales.core.format.gml
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
	import org.openscales.core.format.Format;
	import org.openscales.core.format.gml.parser.GML2;
	import org.openscales.core.format.gml.parser.GML311;
	import org.openscales.core.format.gml.parser.GML321;
	import org.openscales.core.format.gml.parser.GMLParser;
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
	import org.openscales.proj4as.ProjProjection;
	
	
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
		
		private var projectionxml:String = "srsName=\"http://www.opengis.net/gml/srs/epsg.xml#4326\"";
		
		private var _version:String = "2.1.1";
		
		private var _gmlParser:GMLParser = null;
		
		private var gml:Namespace = null;
		
		
		private var xmlString:String;
		private var sXML:String;
		
		private var lastInd:int    = 0;
		//fps
		private var allowedTime:Number = 10;
		private var startTime:Number = 0;
		private var savedIndex:Number = 0;
		private var sprite:Sprite = new Sprite();
		
		private var _asyncLoading:Boolean = true;
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
			if(!this._asyncLoading || this._version!="2.1.1") {
				var dataXML:XML = new XML(data);
				var features:XMLList;
			}
			
			var lonlat:Boolean = true;
			
			switch (this._version) {
				case "2.1.1":
					if(!this._gmlParser || !(this._gmlParser is GML2))
						this._gmlParser = new GML2();
					if(!this._asyncLoading) {
						features = dataXML..*::featureMember;
					}
					//featureMember
					break;
				case "3.1.1":
					if(ProjProjection.projAxisOrder[this.externalProjSrsCode]
						&& ProjProjection.projAxisOrder[this.externalProjSrsCode]==ProjProjection.AXIS_ORDER_NE)
						lonlat = false;
					if(!this._gmlParser || !(this._gmlParser is GML311))
						this._gmlParser = new GML311();
					//featureMembers
					//if(!this._asyncLoading) {
						features = dataXML..*::featureMembers;
						dataXML = features[0];
						features = dataXML.children();
					//}
					break;
				case "3.2.1":
					if(ProjProjection.projAxisOrder[this.externalProjSrsCode]
						&& ProjProjection.projAxisOrder[this.externalProjSrsCode]==ProjProjection.AXIS_ORDER_NE)
						lonlat = false;
					if(!this._gmlParser || !(this._gmlParser is GML321))
						this._gmlParser = new GML321();
					//members
					//if(!this._asyncLoading) {
					features = dataXML..*::member;
					//}
					break;
				default:
					return null;
			}
			
			this._gmlParser.internalProjSrsCode = this.internalProjSrsCode;
			this._gmlParser.externalProjSrsCode = this.externalProjSrsCode;
			this._gmlParser.parseExtractAttributes = this.extractAttributes;
			
			if(this._asyncLoading && this._version=="2.1.1") {
				this.xmlString = data as String;
				data = null;
				if(this.xmlString.indexOf(this._gmlParser.sFXML)!=-1){
					var end:int = this.xmlString.indexOf(">",this.xmlString.indexOf(">")+1)+1;
					this.sXML = this.xmlString.slice(0,end);
					this.dim = 2;
					this.sprite.addEventListener(Event.ENTER_FRAME, this.readTimer);
				} else {
					this.xmlString = null;
				}
			} else {
				for each( dataXML in features) {
					this._onFeature(this._gmlParser.parseFeature(dataXML,lonlat));
				}
			}
			
			return null;
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
			this.lastInd = this.xmlString.indexOf(this._gmlParser.sFXML,this.lastInd);
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
				
				end = this.xmlString.indexOf(this._gmlParser.eFXML,this.lastInd);
				if(end<0)
					break;
				xmlNode = new XML( this.sXML + this.xmlString.substr(this.lastInd,end-this.lastInd) + this._gmlParser.eXML )
				this.lastInd = this.xmlString.indexOf(this._gmlParser.sFXML,this.lastInd+1);
				switch (this._version) {
					case "2.1.1":
						if(this._featuresids.containsKey((xmlNode..@fid) as String))
							continue;
						break;
					default:
						continue;
				}
				
				feature = this._gmlParser.parseFeature(xmlNode);
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
		
		public function boxNode(bound:Bounds):XML{
			
			var boxNode:XML = new XML("<" + this._gmlprefix + ":Box xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\">" +
				"</" + this._gmlprefix +":Box>");
			var coodinateNode:XML = new XML("<" + this._gmlprefix + ":coordinates xmlns:" + this._gmlprefix + "=\"" + this._gmlns + "\" >" +
				"</" + this._gmlprefix +":coordinates>");
			
			coodinateNode.appendChild(this.buildCoordinatesWithoutProjSrsCode(new <Number>[bound.left,bound.bottom,bound.right,bound.top]));			
			boxNode.appendChild(coodinateNode); 
			return boxNode;
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
		public function buildPointNode(point:Point):XML{
			
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
		public function buildPolygonNode(polygon:Polygon):XML {
			
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
		public function buildCoordinatesNode(geometry:Object):XML {
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
		
		/**
		 * Indicates the GML version
		 */
		public function get version():String {
			return this._version;
		}
		/**
		 * @Private
		 */
		public function set version(value:String):void {
			this._version = value;
		}
	}
}

