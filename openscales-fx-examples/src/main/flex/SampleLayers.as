package {
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.layer.osm.Mapnik;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.GraphicFill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.font.Font;
	import org.openscales.core.style.graphic.ExternalGraphic;
	import org.openscales.core.style.graphic.Mark;
	import org.openscales.core.style.halo.Halo;
	import org.openscales.core.style.marker.CustomMarker;
	import org.openscales.core.style.marker.WellKnownMarker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.ArrowSymbolizer;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.core.style.symbolizer.TextSymbolizer;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Polygon;
	
	/**
	 * Create sample layers. Externalized in a class in order to be reused in unit tests for
	 * example.
	 */
	public class SampleLayers
	{
		/**
		 * void constructor for the SampleLayers class wich is a collection of
		 * static functions returning some sample layers.
		 */
		public function SampleLayers() {
			// Nothing to do
		}
		
		/**
		 * Returns a sample layer of drawn features
		 */
		static public function features():VectorLayer {
			var mark:Mark;
			var psym:PointSymbolizer;
			// Create the drawings layer and some useful variables
			var layer:VectorLayer = new VectorLayer("Drawing samples");
			layer.projection = "EPSG:4326";
			var style:Style;
			var rule:Rule;
			var arrayComponents:Vector.<Number>;
			var arrayVertices:Vector.<Geometry>;
			var point:org.openscales.geometry.Point;
			
			var stroke:Stroke = new Stroke(0x000000,2);
			stroke.dashArray = new Array(5,2,7,3);
			
			var blackStyle:Style =  new Style();
			blackStyle.rules.push(new Rule());
			mark = new Mark(Mark.WKN_STAR,new SolidFill(0x999999,0.5),new Stroke(0x000000,2));
			psym = new PointSymbolizer();
			psym.graphic.graphics.push(mark);
			psym.graphic.size = 24;
			psym.graphic.rotation = 0;
			psym.graphic.opacity = 0.7;
			blackStyle.rules[0].symbolizers.push(psym);
			
			var graphicFill2:GraphicFill = new GraphicFill();
			mark = new Mark(Mark.WKN_STAR,new SolidFill(0xc6c6c6,0.5),new Stroke(0x000000,2));
			graphicFill2.graphic.graphics.push(mark);
			graphicFill2.graphic.size = 20;
			
			var graphicFill:GraphicFill = new GraphicFill();
			mark = new Mark(Mark.WKN_CIRCLE,graphicFill2,new Stroke(0x000000,2));
			graphicFill.graphic.graphics.push(mark);
			graphicFill.graphic.size = 40;
			
			blackStyle.rules[0].symbolizers.push(new PolygonSymbolizer(graphicFill,stroke));
			var wnmk:WellKnownMarker = new WellKnownMarker(WellKnownMarker.WKN_TRIANGLE,new SolidFill(0x999999,0.5),new Stroke(0xFF0000,2),12);
			blackStyle.rules[0].symbolizers.push(new ArrowSymbolizer(new Stroke(0x000000,2),wnmk,wnmk));
			blackStyle.rules[0].symbolizers.push(new TextSymbolizer("name", new Font(15,0xFFFFFF,0.7,null,Font.ITALIC,Font.BOLD),new Halo(0x000000,2,0.7)));
			
			var markerStyle:Style = new Style();
			markerStyle.rules.push(new Rule());
			mark = new Mark(Mark.WKN_CROSS,new SolidFill(0x999999,0.5),new Stroke(0x000000,2));
			psym = new PointSymbolizer();
			var extMark:ExternalGraphic = new ExternalGraphic("http://openscales.org/assets/red.png");
			//psym.graphic.graphics.push(mark);
			psym.graphic.graphics.push(extMark);
			//psym.graphic.graphics.push(mark);
			psym.graphic.size = 12;
			markerStyle.rules[0].symbolizers.push(psym);
			var ts:TextSymbolizer = new TextSymbolizer("name", new Font(30,0xFFFFFF,0.8,null,Font.ITALIC,Font.BOLD),new Halo(0x000000,2,0.8));
			markerStyle.rules[0].symbolizers.push(ts);
			ts = new TextSymbolizer("name", new Font(30,0xFFFFFF,0.8,null,Font.ITALIC,Font.BOLD),new Halo(0x000000,2,0.8));
			ts.rotation = 45;
			ts.displacementY = -15;
			markerStyle.rules[0].symbolizers.push(ts);
			//markerStyle.rules[0].symbolizers.push(new TextSymbolizer("name", new Font(20,0xFFFFFF,0.8,null,null,Font.BOLD),new Halo(0x000000,2,0.8)));
			
			// Add some (black) objects for the tests of inclusion with all the
			// features added below.
			style = new Style();
			style.rules.push(new Rule());
			mark = new Mark(Mark.WKN_TRIANGLE,new SolidFill(0x999999,0.5),new Stroke(0xFFFFFF,2));
			psym = new PointSymbolizer();
			psym.graphic.graphics.push(mark);
			psym.graphic.size = 12;
			style.rules[0].symbolizers.push(psym);
			style.rules[0].symbolizers.push(new TextSymbolizer("name", new Font(15,0xFFFFFF,0.5,null,Font.ITALIC),new Halo(0x000000,2,0.5)));
			
			// A point inside of the MultiPolygon (its first polygon).
			point = new org.openscales.geometry.Point(4.649002075147177, 45.78235984585472);
			layer.addFeature(new PointFeature(point,{'name':"toto1"},markerStyle));
			
			//(layer.features[layer.features.length-1] as Feature).id = "blackPoint1";
			// A point outside of the MultiPolygon but inside an excessive hole
			// of its third polygon.
			point = new org.openscales.geometry.Point(4.63114929194725, 45.692262077956364);
			layer.addFeature(new PointFeature(point,{'name':"toto2"},style));
			
			//(layer.features[layer.features.length-1] as Feature).id = "blackPoint2";
			// A point outside of the blue Polygon but inside its BBOX.
			point = new org.openscales.geometry.Point(4.910228209414947, 45.73119410607873);
			layer.addFeature(new PointFeature(point,{'name':"toto3"},blackStyle));
			//(layer.features[layer.features.length-1] as Feature).id = "blackPoint2";
			// A LineString intersecting all the other objects.
			
			
			style = new Style();
			style.rules.push(new Rule());
			style.rules[0].symbolizers.push(new PolygonSymbolizer(new SolidFill(0x999999,0.5),new Stroke(0x000000,2)));
			style.rules[0].symbolizers.push(new TextSymbolizer("name", new Font(13,0xFFFFFF,0.6,null,Font.ITALIC,Font.BOLD),new Halo(0x000000,2,0.6)));
			arrayComponents = new Vector.<Number>(4);
			arrayComponents[0]=4.5714111327782625;
			arrayComponents[1]=45.76368130194846;
			arrayComponents[2]=5.117294311391419;
			arrayComponents[3]=45.69513978441103;
			layer.addFeature(new LineStringFeature(new LineString(arrayComponents),{'name':"toto4"},style));
			
			
			//(layer.features[layer.features.length-1] as Feature).id = "blackLineString";
			// A Polygon intersecting all the other objects.
			arrayComponents = new Vector.<Number>(8);
			arrayVertices = new Vector.<Geometry>(1);
			arrayComponents[0]=4.5727844237936415;
			arrayComponents[1]=45.713361819965364;
			arrayComponents[2]=5.0300903319148516;
			arrayComponents[3]=45.713361819965364;
			arrayComponents[4]=5.0300903319148516;
			arrayComponents[5]= 45.659157810588724;
			arrayComponents[6]=4.5727844237936415;
			arrayComponents[7]= 45.659157810588724;
			arrayVertices[0]=new LinearRing(arrayComponents);
			layer.addFeature(new PolygonFeature(new Polygon(arrayVertices),null,blackStyle));
			//(layer.features[layer.features.length-1] as Feature).id = "blackPolygon";
			
			
			var multiColorStyle:Style = new Style();
			multiColorStyle.rules.push(new Rule());
			mark = new Mark(Mark.WKN_CIRCLE,new SolidFill(0xFF0000,0.5),new Stroke(0xFF0000,2));
			psym = new PointSymbolizer();
			psym.graphic.graphics.push(mark);
			psym.graphic.size = 10;
			multiColorStyle.rules[0].symbolizers.push(psym);
			multiColorStyle.rules[0].symbolizers.push(new LineSymbolizer(new Stroke(0x33FF00,3)));
			multiColorStyle.rules[0].symbolizers.push(new PolygonSymbolizer(new SolidFill(0x0033FF,0.5),new Stroke(0x0033FF,2)));
			// Add a Point.
			// This point is inside a hole of  the sample polygon: it must
			//   be selectable through the polygon.
			//style = new Style();
			//style.rules.push(new Rule());
			//(style.rules[0] as Rule).symbolizers.push(new PointSymbolizer(new WellKnownMarker(WellKnownMarker.WKN_CIRCLE,new SolidFill(0xFF0000,0.5),new Stroke(0xFF0000,2),10)));
			point = new org.openscales.geometry.Point(4.830228209414947, 45.73119410607873);
			layer.addFeature(new PointFeature(point,null,multiColorStyle));
			//(layer.features[layer.features.length-1] as Feature).id = "Point";
			
			
			// Add a MultiPoint.
			style = new Style();
			style.rules.push(new Rule());
			mark = new Mark(Mark.WKN_SQUARE,new SolidFill(0xFF9900,0.5),new Stroke(0xFF9900,2));
			psym = new PointSymbolizer();
			psym.graphic.graphics.push(mark);
			psym.graphic.size = 10;
			(style.rules[0] as Rule).symbolizers.push(psym);
			arrayComponents = new Vector.<Number>();
			arrayComponents.push(4.841262817300238,
				45.790978602336864,
				4.787704467700456,
				45.78044438566825,
				4.789077758715836,
				45.76463932817484,
				4.779411077427893,
				45.737578114943204,
				4.805557250900384,
				45.71959431070957,
				4.847442626869443,
				45.704251544623304,
				4.877655029207781,
				45.70808763101123,
				4.900314330961535,
				45.73541212687354,
				4.939453124899837,
				45.76942921252746,
				4.899627685453846,
				45.78235984585472,
				4.863922119053991,
				45.776613267874524);
			layer.addFeature(new MultiPointFeature(new MultiPoint(arrayComponents),null,multiColorStyle));
			//(layer.features[layer.features.length-1] as Feature).id = "MultiPoint";
			
			// Add a LineString.
			//style = new Style();
			//style.rules.push(new Rule());
			//(style.rules[0] as Rule).symbolizers.push(new LineSymbolizer(new Stroke(0x33FF00,3)));
			arrayComponents = new Vector.<Number>();
			
			arrayComponents.push(4.841262817300238,
				45.806776194899484,
				4.759552001885187,
				45.785711742833584,
				4.712173461854611,
				45.76511833511852,
				4.72727966302378,
				45.73828761221408,
				4.7980041503157995,
				45.709046611476175,
				4.844009399330996,
				45.69274170598194,
				4.901000976469224,
				45.69657858210952,
				4.927780151269115,
				45.73109862122825,
				4.999877929576513,
				45.77182400046717,
				4.9483795164998,
				45.790499817491956);
			layer.addFeature(new LineStringFeature(new LineString(arrayComponents),{'name':"toto5"},blackStyle));
			//(layer.features[layer.features.length-1] as Feature).id = "LineString";
			
			// Add a MultiLineString.
			var biColorStyle:Style = new Style();
			biColorStyle.rules.push(new Rule());
			stroke = new Stroke(0xFF3300,5);
			stroke.dashArray = new Array(5,2,7,3);
			(biColorStyle.rules[0] as Rule).symbolizers.push(new LineSymbolizer(stroke));
			(biColorStyle.rules[0] as Rule).symbolizers.push(new LineSymbolizer(new Stroke(0xFFFFFF,2)));
			
			arrayVertices = new Vector.<Geometry>();
			arrayComponents = new Vector.<Number>();
			arrayComponents.push(5.051376342653225,
				45.67595227768875,
				5.06030273425319,
				45.69274170598194,
				5.08708190905308,
				45.69466017695171,
				5.10012817369918,
				45.704251544623304);
			arrayVertices.push(new LineString(arrayComponents));
			arrayComponents = new Vector.<Number>();
			arrayComponents.push(4.970352172745865,
				45.700894753090175,
				5.001251220591892,
				45.68458747014324,
				5.047943115114779,
				45.670194742323545);
			arrayVertices.push(new LineString(arrayComponents));
			arrayComponents = new Vector.<Number>();
			arrayComponents.push(4.965545654192038,
				45.70569010786783,
				4.959365844622833,
				45.67835107594167,
				4.924346923730667,
				45.66683590649083,
				4.915420532130705,
				45.645718608921435);
			arrayVertices.push(new LineString(arrayComponents));
			layer.addFeature(new MultiLineStringFeature(new MultiLineString(arrayVertices),{'name':"toto6"},biColorStyle));
			//(layer.features[layer.features.length-1] as Feature).id = "MultiLineString";
			
			// Add a Polygon.
			//style = new Style();
			//style.rules.push(new Rule());
			//(style.rules[0] as Rule).symbolizers.push(new PolygonSymbolizer(new SolidFill(0x0033FF,0.5),new Stroke(0x0033FF,2)));
			arrayComponents = new Vector.<Number>();
			arrayVertices = new Vector.<Geometry>();
			arrayComponents.push(4.841262817300238,
				45.790978602336864,
				4.787704467700456,
				45.78044438566825,
				4.789077758715836,
				45.76463932817484,
				4.779411077427893,
				45.737578114943204,
				4.805557250900384,
				45.71959431070957,
				4.847442626869443,
				45.704251544623304,
				4.877655029207781,
				45.70808763101123,
				4.900314330961535,
				45.73541212687354,
				4.939453124899837,
				45.76942921252746,
				4.899627685453846,
				45.78235984585472,
				4.863922119053991,
				45.776613267874524);
			arrayVertices.push(new LinearRing(arrayComponents));
			arrayComponents = new Vector.<Number>();
			arrayComponents.push(4.85399,
				45.76610,
				4.85399,
				45.74071,
				4.89399,
				45.74071,
				4.89399,
				45.76610);
			arrayVertices.push(new LinearRing(arrayComponents));
			arrayComponents = new Vector.<Number>();
			arrayComponents.push(4.830276489177206,
				45.74451732248572,
				4.823410034100311,
				45.73684988805274,
				4.823410034100311,
				45.727743442058525,
				4.8426361083156175,
				45.72726411429607,
				4.849502563392512,
				45.73637063843944,
				4.844696044838685,
				45.74403813868174);
			arrayVertices.push(new LinearRing(arrayComponents));
			layer.addFeature(new PolygonFeature(new Polygon(arrayVertices),{'name':"toto7"},biColorStyle));
			//(layer.features[layer.features.length-1] as Feature).id = "Polygon";
			
			// Add a MultiPolygon.
			var polygonArray:Vector.<Geometry>= new Vector.<Geometry>(3);
			style = new Style();
			style.rules.push(new Rule());
			graphicFill = new GraphicFill();
			mark = new Mark(Mark.WKN_STAR,new SolidFill(0xFF0055,0.5),new Stroke(0xAA0055,2));
			//graphicFill.graphic.graphics.push(mark);
			graphicFill.graphic.size = 20;			
			style.rules[0].symbolizers.push(new PolygonSymbolizer(graphicFill,new Stroke(0xAA0055,2)));
			// 1st polygon
			arrayComponents = new Vector.<Number>();
			arrayVertices = new Vector.<Geometry>();
			arrayComponents.push(4.587203979455121,
				45.76559733794923,
				4.581024169885915,
				45.74116294948335,
				4.535018920870719,
				45.711443990657614,
				4.607116699178117,
				45.73205720683009,
				4.652435302685625,
				45.72726411429607,
				4.622909545854975,
				45.74403813868174,
				4.631835937454939,
				45.75266281785543,
				4.651062011670245,
				45.747871493947756,
				4.648315429639488,
				45.75793279909815,
				4.666168212839414,
				45.778049967894205,
				4.670974731393241,
				45.79815988146484,
				4.650375366162556,
				45.79815988146484,
				4.624969482378044,
				45.790499817491956);
			arrayVertices.push(new LinearRing(arrayComponents));
			arrayComponents = new Vector.<Number>();
			
			arrayComponents.push(4.600936889608912,
				45.76368130194846,
				4.601623535116601,
				45.75170458597825,
				4.61672973628577,
				45.75170458597825,
				4.6153564452703915,
				45.76032808059674);
			arrayVertices.push(new LinearRing(arrayComponents));
			polygonArray.push(new Polygon(arrayVertices));
			// 2nd polygon
			arrayVertices = new Vector.<Geometry>();
			arrayComponents = new Vector.<Number>();
			arrayComponents.push(4.6146697997627015,
				45.82209079519674,
				4.613296508747322,
				45.817305435010816,
				4.622909545854975,
				45.81778398953689);
			arrayVertices.push(new LinearRing(arrayComponents));
			polygonArray.push(new Polygon(arrayVertices));
			
			// 3rd polygon
			arrayComponents = new Vector.<Number>();
			arrayVertices = new Vector.<Geometry>();
			arrayComponents.push(4.603683471639669,
				45.704251544623304,
				4.590637206993569,
				45.70185385695145,
				4.577590942347468,
				45.69657858210952,
				4.576217651332089,
				45.68794524062948,
				4.581710815393605,
				45.68266865365893,
				4.591323852501258,
				45.680749771361995,
				4.602310180624291,
				45.68027004050453,
				4.611236572224254,
				45.68027004050453,
				4.6208496093319065,
				45.68122949810618,
				4.627716064408801,
				45.686026539317,
				4.628402709916491,
				45.69370094969332,
				4.624969482378044,
				45.700894753090175,
				4.6146697997627015,
				45.70473106981803);
			arrayVertices.push(new LinearRing(arrayComponents));
			arrayComponents = new Vector.<Number>();
			arrayComponents.push(4.6208496093319065,
				45.69609898698994,
				4.613296508747322,
				45.68842490567441,
				4.63046264643956,
				45.68266865365893,
				4.635269164993386,
				45.69513978441103);
			arrayVertices.push(new LinearRing(arrayComponents));
			polygonArray.push(new Polygon(arrayVertices));
			// feature
			layer.addFeature(new MultiPolygonFeature(new MultiPolygon(polygonArray),{'name':"toto8"},style));
			//(layer.features[layer.features.length-1] as Feature).id = "MultiPolygon";
			
			// Add some (black) objects for more tests of intersection.
			style = new Style();
			style.rules.push(new Rule());
			style.rules[0].symbolizers.push(new PolygonSymbolizer(new SolidFill(0x999999,0.5),new Stroke(0x000000,2)));
			//
			arrayComponents = new Vector.<Number>();
			arrayVertices = new Vector.<Geometry>();
			arrayComponents.push(4.81399,
				45.77610,
				4.81399,
				45.76571,
				4.83399,
				45.76571,
				4.83399,
				45.77610);
			arrayVertices.push(new LinearRing(arrayComponents));
			layer.addFeature(new PolygonFeature(new Polygon(arrayVertices),null,style));

			arrayComponents = new Vector.<Number>();
			arrayVertices = new Vector.<Geometry>();
			arrayComponents.push(4.873535156161644,
				45.75889092403663,
				4.860488891515543,
				45.75170458597825,
				4.872161865146266,
				45.74547567775447,
				4.886581420807746,
				45.75218370397337);
			arrayVertices.push(new LinearRing(arrayComponents));
			layer.addFeature(new PolygonFeature(new Polygon(arrayVertices),{'name':"toto"},style));
			
			// return the vector layer
			return layer;
		}
		
	}
}