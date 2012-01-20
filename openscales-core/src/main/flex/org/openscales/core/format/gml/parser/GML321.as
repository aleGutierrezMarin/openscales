package org.openscales.core.format.gml.parser
{
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.utils.Trace;
	import org.openscales.core.utils.Util;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.ICollection;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.proj4as.ProjProjection;

	public class GML321 extends GMLParser
	{
		/**
		 * The purpose of this class is to read gml data
		 * Supported version 3.2.1
		 * 
		 */ 
		
		public function GML321()
		{
			super();
		
		}
		
		//this function has no purpose other than to be used in tests
		public function parseGmlFile(xml:XML):Vector.<Feature>{
			var featureVector:Vector.<Feature> = new Vector.<Feature>();
			var membersList:XMLList = xml..*::member;
			var i:uint;
			for (i = 0; i < membersList.length(); i++){
				featureVector[i] = parseFeature(membersList[i]);
			}
			
			return featureVector;
		}
		
		
		/**
		 * @param xmlNode: it contains one gml node member (@see GMLFormat, function read)
		 * @param lonLat: true if the order of coordinates is (x,y)
		 * 
		 * @return feature 
		 * 
		 * @calls parseCoords (@see GMLFormat)
		 * @calls parseAttributes
		 * @calls parsePolygonNode
		 * 
		 */
		
		override public function parseFeature(xmlNode:XML,lonLat:Boolean=true):Feature {

			var proj:ProjProjection = ProjProjection.getProjProjection("EPSG:4326");
			var geom:ICollection = null;
			var p:Vector.<Number> = new Vector.<Number>();	
			var feature:Feature = null;
			
			var i:int;
			var j:int;
			this.dim = 2; // if not specified, the dimension is 2 by default;
			var _dim:uint = this.dim;
			var envelope:XML = xmlNode..*::Envelope[0];
			var dimensionError:Boolean = false;
			
			if (xmlNode..*::MultiSurface.length() > 0) {
				var multiSurface:XML = xmlNode..*::MultiSurface[0]; // 0..1 MultiSurface
				if(multiSurface.hasOwnProperty('@srsDimension') && multiSurface.@srsDimension.length() )
				{
					this.dim = Number(multiSurface.@srsDimension);
					if (envelope.hasOwnProperty('@srsDimension') && envelope.@srsDimension.length())  {
						if(this.dim != Number(envelope.@srsDimension)){
							dimensionError = true;
						}
					}
					this.dim = _dim;
					
				}
				
				if (!dimensionError){
					geom = new MultiPolygon();
					var polygons:XMLList = multiSurface..*::Polygon; 
					j = polygons.length();
					for (i = 0; i < j; i++) {
						var polygon:Polygon = this.parsePolygonNode(polygons[i], lonLat); 
						geom.addComponent(polygon);
					}
					feature = new MultiPolygonFeature(geom as MultiPolygon);
					
				}
				
			} else if (xmlNode..*::MultiCurve.length() > 0) { 
				var multiCurve:XML = xmlNode..*::MultiCurve[0];
				if( multiCurve.hasOwnProperty('@srsDimension') && multiCurve.@srsDimension.length() )
				{
					this.dim = Number(multiCurve.@srsDimension);
				}
				
				geom = new MultiLineString();
				var lineStrings:XMLList = multiCurve..*::LineString;
				j = lineStrings.length();
				
				for (i = 0; i < j; ++i) {
					p = this.parseCoords(lineStrings[i], lonLat);
					if(p){
						if(p.length != 0){
							var lineString:LineString = new LineString(p);
							geom.addComponent(lineString);
						}
						
					}
				}
				feature = new MultiLineStringFeature(geom as MultiLineString);
				this.dim = _dim;
			} else if (xmlNode..*::MultiPoint.length() > 0) {
				var multiPoint:XML = xmlNode..*::MultiPoint[0];
				if( multiPoint.hasOwnProperty('@srsDimension') && multiPoint.@srsDimension.length() )
				{
					this.dim = Number(multiPoint.@srsDimension);
				}
				
				geom = new MultiPoint();
				
				var points:XMLList = multiPoint..*::Point;
				j = points.length();
				for(i = 0; i < j; i++){
					p = this.parseCoords(points[i], lonLat);
					if (p)
						if ( p.length != 0 ){
							geom.addPoints(p);
						}
				}			
				feature = new MultiPointFeature(geom as MultiPoint);
				this.dim = _dim;
				
			} else if (xmlNode..*::Polygon.length() > 0) {
				var polygon2:XML = xmlNode..*::Polygon[0];
				if( polygon2.hasOwnProperty('@srsDimension') && polygon2.@srsDimension.length() )
				{
					this.dim = Number(polygon2.@srsDimension);
				}
				
				feature = new PolygonFeature(this.parsePolygonNode(polygon2,lonLat));
				this.dim = _dim;
			} else if (xmlNode..*::LineString.length() > 0) {
				var lineString2:XML = xmlNode..*::LineString[0];
				if( lineString2.@srsDimension != null )
				{
					this.dim = Number(lineString2.@srsDimension);
				}
				
				p = this.parseCoords(lineString2, lonLat);
				if (p) {
					if (p.length != 0){
						geom = new LineString(p);
					}
					
				}
				feature = new LineStringFeature(geom as LineString);
				this.dim = _dim;
			} else if (xmlNode..*::Point.length() > 0) {
				var point:XML = xmlNode..*::Point[0];
				if( point.hasOwnProperty('@srsDimension') && point.@srsDimension.length() )
				{
					this.dim = Number(point.@srsDimension);
				}
				
				var pointObject:Point; 
				p = this.parseCoords(point, lonLat);
				if (p) {
					if (p.length != 0){
						pointObject = new Point(p[0],p[1]);
						feature = new PointFeature(pointObject);
					}
				}
				this.dim = _dim;
			}else{
				Trace.warn("GMLFormat.parseFeature: unrecognized geometry);"); 
				return null; 
			}
			if (feature) {
				
				var geomNode:XML = xmlNode.children()[0];
				feature.name = String(geomNode.attributes()[0]);
				
				if (this.parseExtractAttributes) { 
					feature.attributes = this.parseAttributes(xmlNode);
				}    
				
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
				
				var properties:Vector.<String> = new <String>["posList", "upperCorner", "lowerCorner", "pos"];
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
		public function parsePolygonNode(polygonNode:Object, lonLat:Boolean):Polygon {
			//exterior tag: only one LinearRing with its coordinates (posList)
			//interior tag: 0..* LinearRings
			var proj:ProjProjection = ProjProjection.getProjProjection("EPSG:4326");
			var exterior:XMLList = polygonNode..*::exterior;
			var interior:XMLList = polygonNode..*::interior;
			
			var j:int = interior.length();
			var rings:Vector.<Geometry> = new Vector.<Geometry>();
			var i:uint = 0;
			
			var coords:Vector.<Number> = this.parseCoords(exterior[0]..*::LinearRing[0], lonLat);
			if(coords == null || coords.length == 0)
				return null;
			rings[i++] = new LinearRing(coords); 
			
			if(j != 0 ){
				for (var k:uint = 0; k < j; k++) {
					coords = this.parseCoords(interior[k], lonLat);
					if(coords == null || coords.length == 0)
						continue;
					rings[i++] = new LinearRing(coords);
				}
				
			}
			return new Polygon(rings);
		}
		
	}
}