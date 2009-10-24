package org.openscales.core.feature
{
	import org.openscales.core.basetypes.Pixel;
	import org.openscales.core.geometry.LinearRing;
	import org.openscales.core.geometry.MultiPolygon;
	import org.openscales.core.geometry.Point;
	import org.openscales.core.geometry.Polygon;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.geometry.Collection;
	/**
	 * Feature used to draw a MultiPolygon geometry on FeatureLayer
	 */
	public class MultiPolygonFeature extends VectorFeature
	{
		public function MultiPolygonFeature(geom:MultiPolygon=null, data:Object=null, style:Style=null,isEditable:Boolean=false,isEditionFeature:Boolean=false,editionFeatureParentGeometry:Collection=null)
		{
			super(geom, data, style,isEditable,isEditionFeature,editionFeatureParentGeometry);
		}

		public function get polygons():MultiPolygon {
			return this.geometry as MultiPolygon;
		}

		override protected function executeDrawing(symbolizer:Symbolizer):void 
		{ 
            trace("Drawing multipolygon"); 
            // Variable declaration before for loop to improve performances 
            var polygon:Polygon = null; 
            var linearRing:LinearRing = null; 
            var p:Point = null; 
            var i:int = 0; 
            var j:int = 0; 
            var pAux:Pixel = null; 
            var count:int = 0; 
            var countFeature:int = 0; 
            var resolution:Number = this.layer.map.resolution 
            var dX:int = -int(this.layer.map.layerContainer.x) + this.left; 
            var dY:int = -int(this.layer.map.layerContainer.y) + this.top; 
            var x:Number; 
            var y:Number; 
            for (var k:int = 0; k < this.polygons.componentsLength; k++) { 
				polygon = (this.polygons.componentByIndex(k) as Polygon); 
                for (i=0; i<polygon.componentsLength; i++) { 
                	linearRing = (polygon.componentByIndex(i) as LinearRing); 
                    // Draws the n-1 polygon lines 
                    for (j=0; j<linearRing.componentsLength; j++) { 
                    	p = (linearRing.componentByIndex(j) as Point); 
                        //optimizing 
                        x = dX + p.x / resolution; 
                        y = dY - p.y / resolution; 
                        if (j==0) { 
							this.graphics.moveTo(x, y); 
                            } else { 
                            	this.graphics.lineTo(x, y); 
                            } 
                        } 
                        // Draws the last line of the polygon, as Flash won't render it if there is no fill 
                        if(linearRing.componentsLength > 0){ 
                        	p = linearRing.componentByIndex(0) as Point;
                        	x = dX + p.x / resolution; 
                        	y = dY - p.y / resolution;
                            this.graphics.lineTo(x,y); 
						} 
                    } 
            	} 
            	trace("End of multipolygon drawing"); 
			}	
		}
	}

