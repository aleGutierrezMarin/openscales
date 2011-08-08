package org.openscales.core.format.gml.parser
{
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.geometry.ICollection;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.LineString;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.Trace;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.Point;
	import org.openscales.core.Util;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LinearRing;

	public class GML2 extends GMLParser
	{
		public function GML2()
		{
			this._eXML  = "</gml:featureMember></wfs:FeatureCollection>";
			this._eFXML = "</gml:featureMember>";
			this._sFXML = "<gml:featureMember>";
		}
		
		override public function get gml():Namespace {
			return new Namespace("gml","http://www.opengis.net/gml");	
		}
		
		override public function parseFeature(data:XML, lonLat:Boolean=true):Feature {
			use namespace gml;
			
			var geom:ICollection = null;
			var p:Vector.<Number> = new Vector.<Number>();
			
			var feature:Feature = null;
			
			var i:int;
			var j:int;
			
			if (data..*::MultiPolygon.length() > 0) {
				var multipolygon:XML = data..*::MultiPolygon[0];
				
				geom = new MultiPolygon();
				var polygons:XMLList = multipolygon..*::Polygon;
				j = polygons.length();
				for (i = 0; i < j; i++) {
					var polygon:Polygon = this.parsePolygonNode(polygons[i]);
					geom.addComponent(polygon);
				}
				feature = new MultiPolygonFeature(geom as MultiPolygon);
			} else if (data..*::MultiLineString.length() > 0) {
				var multilinestring:XML = data..*::MultiLineString[0];
				
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
				feature = new MultiLineStringFeature(geom as MultiLineString);
			} else if (data..*::MultiPoint.length() > 0) {
				var multiPoint:XML = data..*::MultiPoint[0];
				
				geom = new MultiPoint();
				
				var points:XMLList = multiPoint..*::Point;
				j = points.length();
				p = this.parseCoords(points[i]);
				if (p)
					geom.addPoints(p);
				feature = new MultiPointFeature(geom as MultiPoint);
				
			} else if (data..*::Polygon.length() > 0) {
				var polygon2:XML = data..*::Polygon[0];
				feature = new PolygonFeature(this.parsePolygonNode(polygon2));
			} else if (data..*::LineString.length() > 0) {
				var lineString2:XML = data..*::LineString[0];
				
				p = this.parseCoords(lineString2);
				if (p) {
					geom = new LineString(p);
				}
				feature = new LineStringFeature(geom as LineString);
			} else if (data..*::Point.length() > 0) {
				var point:XML = data..*::Point[0];
				var pointObject:Point; 
				p = this.parseCoords(point);
				if (p) {
					pointObject = new Point(p[0],p[1]);
					feature = new PointFeature(pointObject);
				}
			}else{
				Trace.warn("GMLFormat.parseFeature: unrecognized geometry);"); 
				return null; 
			}
			if (feature) {
				feature.name = data..@fid;
				
				if (this.parseExtractAttributes) {
					feature.attributes = this.parseAttributes(data);
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
		private function parseAttributes(xmlNode:XML):Object {
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
		private function parsePolygonNode(polygonNode:Object):Polygon {
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

	}
}