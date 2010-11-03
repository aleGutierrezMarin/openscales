package org.openscales.geometry
{
	
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjPoint;
	
	/**
	 * Class to represent a point geometry.
	 */
	public class Point extends Geometry
	{
		private var _x:Number = NaN;
		private var _y:Number = NaN;

		public function Point(srsCode:String, x:Number, y:Number) {
			super(srsCode);
			this._x = x;
			this._y = y;
		}		
		
		/**
		 * To get this geometry clone
		 * */
		override public function clone():Geometry{
			return new Point(this.projSrsCode, this.x, this.y);
		}
		
		/**
		 * Return an array of all the vertices (Point) of this geometry
		 */
		override public function toVertices():Vector.<Point> {
			return new <Point>[ this.clone() as Point ];
		}
		
		override public function calculateBounds():void {
			this._bounds = new Bounds(this.projSrsCode, this.x, this.y, this.x, this.y);
		}

		override public function distanceTo(point:Geometry, options:Object=null):Number{
			var distance:Number = 0.0;
			if ( (!isNaN(this._x)) && (!isNaN(this._y)) && 
				((point as Point) != null) && (!isNaN((point as Point).x)) && (!isNaN((point as Point).y)) ) {

				var dx2:Number = Math.pow(this.x - (point as Point).x, 2);
				var dy2:Number = Math.pow(this.y - (point as Point).y, 2);
				distance = Math.sqrt( dx2 + dy2 );
			}
			return distance;
		}

		public function equals(point:Point):Boolean {
			var equals:Boolean = false;
			if (point != null) {
				equals = ((this.x == point.x && this.y == point.y) ||
					(isNaN(this.x) && isNaN(this.y) && isNaN(point.x) && isNaN(point.y)));
			}
			return equals;
		}

		override public function toShortString():String {
			return (this.x + ", " + this.y);
		}

		public function move(x:Number, y:Number):void {
			this.x = this.x + x;
			this.y = this.y + y;
		}
				
		/**
		 * Determine if the input geometry intersects this one.
		 * 
		 * @param geometry Any type of geometry.
		 * @return Boolean defining if the input geometry intersects this one.
		 */
		override public function intersects(geom:Geometry):Boolean {
			return ((geom is Point) ? this.equals(geom as Point) : geom.intersects(this)); 
    	}
	
		/**
		 * Method to convert the point (x/y) from a projection sysrtem to an other.
		 *
		 * @param sourceSrs SRS of the source projection
		 * @param destSrs SRS of the destination projection
		 */
		override protected function reprojectGeometry(sourceSrs:String, destSrs:String):void {
			var p:ProjPoint = new ProjPoint(this.x, this.y);
			Proj4as.transform(sourceSrs, destSrs, p);
			this.x = p.x;
			this.y = p.y;
		}

		public function get x():Number {
			return this._x;
		}

		public function set x(value:Number):void {
			this._x = value;
		}

		public function get y():Number {
			return this._y;
		}

		public function set y(value:Number):void {
			this._y = value;
		}
	}
}
