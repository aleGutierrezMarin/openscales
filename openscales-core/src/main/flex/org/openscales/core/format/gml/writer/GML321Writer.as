package org.openscales.core.format.gml.writer
{
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Bounds;

	public class GML321Writer extends GMLWriter
	{
		private var _geomns:Namespace;
		
		public function GML321Writer()
		{
			super();
		}
		
		/**
		 * Given a list of Features, this function creates a GML file.
		 * 
		 * @return An XML object
		 * 
		 * @calls buildFeatureNode to create an XML node for each feature in the list
		 * 
		 */
		
		override public function write(featureCol:Vector.<Feature>, geometryNamespace:String,
									   featureType:String, geometryName:String):XML{
			
			var i:uint;
			var nsName:String = geometryNamespace.split("=")[0];
			var nsURL:String = geometryNamespace.split("\"")[1];
			this.geomns = new Namespace(nsName, nsURL);
			
			var collectionNode:XML = new XML("<FeatureCollection></FeatureCollection>");
			collectionNode.addNamespace(wfsns);
			collectionNode.addNamespace(this.gmlns);
			collectionNode.setNamespace(wfsns);
			
			for(i=0; i<featureCol.length; i++){
				var wfsNode:XML = new XML("<member></member>");
				wfsNode.setNamespace(wfsns);
				
				var featureNode:XML = buildFeatureNode (featureCol[i],featureType,geometryName);
				wfsNode.appendChild(featureNode);
				collectionNode.appendChild(wfsNode);
				
			}
			return collectionNode;
		}
		
		/**
		 * @param A feature
		 * 
		 * @return an XML node
		 * 
		 * @calls buildPointNode, buildPolygonNode, buildLineStringNode, 
		 * depending on the type of feature 
		 * 
		 * @calls buildEnvelopeNode 
		 * In GML, each member is preceded by an <Envelope/> node
		 * 
		 */
		
		public function buildFeatureNode(feature:Feature,featureType:String, geometryName:String):XML{
			
			var i:uint;
			
			var featureNode:XML = new XML("<"+featureType+"></"+featureType+">");
			featureNode.addNamespace(geomns);
			featureNode.setNamespace(geomns);
			featureNode.addNamespace(this.gmlns);
			featureNode.@id = feature.name;
			featureNode.@id.setNamespace(this.gmlns);
			
			var xmlNode:XML = new XML ("<"+geometryName+"></"+geometryName+">"); 
			xmlNode.setNamespace(geomns);
			
			featureNode.appendChild(xmlNode);
			featureNode.insertChildBefore(xmlNode, this.buildEnvelopeNode(feature.geometry.bounds));
			if(feature is PointFeature){
				
				var pf:PointFeature = feature as PointFeature;
				var point:Point = pf.point as Point;
				xmlNode.appendChild(this.buildPointNode(point));	
			}else if(feature is PolygonFeature){
				
				var polygonFeature:PolygonFeature = feature as PolygonFeature;
				var polygon:Polygon = polygonFeature.polygon;
				xmlNode.appendChild(this.buildPolygonNode(polygon));
				
			}else if (feature is MultiPolygonFeature){
				// builds a MultiSurface tag with multiple surfaceMembers (polygons) inside 
				
				var multiSurfaceNode:XML = new XML("<MultiSurface></MultiSurface>");
				multiSurfaceNode.setNamespace(this.gmlns);
				multiSurfaceNode.@srsDimension = this.dim;
				
				
				var mpf:MultiPolygonFeature = feature as MultiPolygonFeature;
				var mp:MultiPolygon = mpf.polygons;
				var polygonVector:Vector.<Geometry> = mp.getcomponentsClone();
				multiSurfaceNode.@srsName = mp.projSrsCode;
				
				for(i=0; i<mp.componentsLength; i++){ // create a subnode for each Polygon inside the multiSurface tag 
					var surfaceMemberNode:XML = new XML("<surfaceMember></surfaceMember>");
					surfaceMemberNode.setNamespace(this.gmlns);
					surfaceMemberNode.appendChild(this.buildPolygonNode(polygonVector[i] as Polygon));
					multiSurfaceNode.appendChild(surfaceMemberNode);
				}
				xmlNode.appendChild(multiSurfaceNode);
				
			}else if (feature is MultiPointFeature){
				var multiPointNode:XML = new XML("<MultiPoint></MultiPoint>");
				multiPointNode.setNamespace(this.gmlns);
				multiPointNode.@srsDimension = this.dim;
				
				var multiPointFeature:MultiPointFeature = feature as MultiPointFeature;
				var multiPoint:MultiPoint = multiPointFeature.points as MultiPoint;
				var points:Vector.<Point> = multiPoint.toVertices();
				
				multiPointNode.@srsName = multiPoint.projSrsCode;
				for(i = 0; i < points.length; i++){
					var pointMember:XML = new XML("<pointMember></pointMember>");
					pointMember.setNamespace(this.gmlns);
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
				mlsNode.setNamespace(this.gmlns);
				mlsNode.@srsDimension = this.dim;
				
				var mlsf:MultiLineStringFeature = feature as MultiLineStringFeature;
				var mls:MultiLineString = mlsf.lineStrings as MultiLineString;
				var lsVector:Vector.<Geometry> = mls.getcomponentsClone();
				
				mlsNode.@srsName = mls.projSrsCode;
				for(i = 0; i < mls.componentsLength; i++){
					var lsMember:XML = new XML("<curveMember></curveMember>");
					lsMember.setNamespace(this.gmlns);
					lsMember.appendChild(this.buildLineStringNode(lsVector[i] as LineString));
					mlsNode.appendChild(lsMember);					
				}
				xmlNode.appendChild(mlsNode);
			}
			
			return featureNode; 
		}
		
		/**
		 * Creates a GML <Point/> node
		 * 
		 * @param a Point Feature
		 * @return an XML object
		 *
		 * The order of the coordinates will be: longitude, latitude  
		 */
		
		public function buildPointNode(point:Point):XML{
			var pointNode:XML = new XML("<Point></Point>");
			pointNode.setNamespace(this.gmlns);
			pointNode.pos = String(point.x)+" "+String(point.y);
			pointNode.children().setNamespace(this.gmlns);
			pointNode.@srsDimension = this.dim;
			pointNode.@srsName = point.projSrsCode;
			return pointNode;
		}
		
		/**
		 * Creates a GML <LineString/> node
		 * 
		 * @param a LineString Feature
		 * @return an XML object
		 * 
		 */
		
		public function buildLineStringNode(lineString:LineString):XML{
			var i:uint;
			var coord:Vector.<Number> = lineString.components;
			var coordList:String = "";
			for(i=0; i<coord.length; i++){
				coordList+=String(coord[i]);
				if (i != (coord.length - 1))
					coordList += " ";
			}
			
			var lineStringNode:XML = new XML("<LineString></LineString>");
			lineStringNode.setNamespace(this.gmlns);
			lineStringNode.posList=coordList;
			lineStringNode.children().setNamespace(this.gmlns);
			lineStringNode.@srsDimension = this.dim;
			lineStringNode.@srsName = lineString.projSrsCode;
			return lineStringNode;
		}
		
		/**
		 * Creates a GML <Polygon/> node
		 * 
		 * @param a Polygon Feature
		 * @return an XML object
		 * 
		 * @calls buildLinearRingNode to create GML <LinearRing/> nodes
		 * 
		 */
		
		public function buildPolygonNode(polygon:Polygon):XML{
			var i:uint;
			var polygonNode:XML = new XML("<Polygon></Polygon>");
			polygonNode.setNamespace(this.gmlns);
			
			var linearRings:Vector.<Geometry> = polygon.getcomponentsClone();
			var exteriorRing:LinearRing = linearRings[0] as LinearRing;
			var exteriorRingNode:XML = buildLinearRingNode("exterior",exteriorRing);
			polygonNode.appendChild(exteriorRingNode);
			
			if(polygon.componentsLength> 1){// if multiple LinearRings inside the Polygon => one is exterior and the others are interior
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
			ringNode.setNamespace(this.gmlns);
			
			var linearRingNode:XML = new XML("<LinearRing></LinearRing>");
			linearRingNode.setNamespace(this.gmlns);
			ringNode.appendChild(linearRingNode);
			
			var coordList:String = "";
			for(i=0; i<ring.components.length; i++)
			{
				coordList += String(ring.components[i]);
				if (i != ring.components.length - 1)
					coordList += " ";
			}
			linearRingNode.posList = coordList;
			linearRingNode.children().setNamespace(this.gmlns);
			return ringNode;
		}
		
		/**
		 * Given the Bounds of the Geometry, this function creates a GML <Envelope/> node
		 * 
		 * @param Bounds
		 * @return an XML object
		 * 
		 */
		public function buildEnvelopeNode(bounds:Bounds):XML{
			var i:uint;
			var boundNode:XML = new XML("<boundedBy></boundedBy>");
			boundNode.setNamespace(this.gmlns);
			var envNode:XML = new XML("<Envelope></Envelope>");
			envNode.setNamespace(this.gmlns);
			envNode.@srsDimension = this.dim;
			envNode.@srsName = bounds.projSrsCode;
			var low:String = String(bounds.left) +" "+ String(bounds.bottom);
			var up:String = String(bounds.right) +" "+ String(bounds.top);
			envNode.lowerCorner = low;
			envNode.upperCorner = up;
			boundNode.appendChild(envNode);
			
			return boundNode;
		}

		
		/**
		 * Getters and Setters
		 */
		
		public function get geomns():Namespace
		{
			return _geomns;
		}

		public function set geomns(value:Namespace):void
		{
			_geomns = value;
		}
		
		
		
	}
}