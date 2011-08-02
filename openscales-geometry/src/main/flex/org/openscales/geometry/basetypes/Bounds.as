package org.openscales.geometry.basetypes
{
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjPoint;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * Instances of this class represent bounding boxes.
	 * Data stored as left, bottom, right, top floats.
	 * All values are initialized to 0, however, you should make sure you set them
	 * before using the bounds for anything.
	 */
	public class Bounds
	{
		private var _left:Number = 0.0;
		private var _bottom:Number = 0.0;
		private var _right:Number = 0.0;
		private var _top:Number = 0.0;
		private var _projSrsCode:String;
		
		public static var DEFAULT_PROJ_SRS_CODE:String = "EPSG:4326";
		
		/**
		 * Class constructor
		 *
		 * @param left Left bound of Bounds instance
		 * @param bottom Bottom bound of Bounds instance
		 * @param right Right bound of Bounds instance
		 * @param top Top bound of Bounds instance
		 */
		public function Bounds(left:Number, bottom:Number, right:Number, top:Number, srsCode:String = "EPSG:4326")
		{
			if (!isNaN(left)) {
				this.left = left;
			}
			if (!isNaN(bottom)) {
				this.bottom = bottom;
			}
			if (!isNaN(right)) {
				this.right = right;
			}
			if (!isNaN(top)) {
				this.top = top;
			}
			if (srsCode) {
				this._projSrsCode = srsCode;
			} else {
				this._projSrsCode = Geometry.DEFAULT_SRS_CODE;
			}
		}
		
		/**
		 * Clone the bounds
		 * 
		 * @return A clone of the bounds
		 */
		public function clone():Bounds {
			return new Bounds(this._left, this._bottom, this._right, this._top, this._projSrsCode);
		}
		
		/**
		 * Determines if the bounds passed as param is equal to current instance
		 *
		 * @param bounds Bounds to check equality
		 * @return It is equal or not
		 */
		public function equals(bounds:Bounds):Boolean {
			var equals:Boolean = false;
			if (bounds != null) {
				equals = this.left == bounds.left &&
					this.right == bounds.right &&
					this.top == bounds.top &&
					this.bottom == bounds.bottom &&
					this.projSrsCode == bounds.projSrsCode;
			}
			return equals;
		}
		
		/**
		 * Returns a bbox string separating the bounds, with the decimal number passed as param, by commas.
		 *
		 * @param decimal Bounds number of decimals.
		 * @return The bounds separated by commas.
		 */  
		public function toString(decimal:Number = -1,forceLatLon:Boolean=true):String {
			if (decimal == -1) {
				decimal = 9;
			}
			var mult:Number = Math.pow(10, decimal);
			var bbox:String = "";
			if(forceLatLon || ProjProjection.projAxisOrder[this.projSrsCode] == ProjProjection.AXIS_ORDER_EN) {
				bbox = Math.round(this.left * mult) / mult + "," +
					Math.round(this.bottom * mult) / mult + "," +
					Math.round(this.right * mult) / mult + "," +
					Math.round(this.top * mult) / mult;
			} else {
				bbox = Math.round(this.bottom * mult) / mult + "," +
					Math.round(this.left * mult) / mult + "," +
					Math.round(this.top * mult) / mult + "," +
					Math.round(this.right * mult) / mult;
			}
			return bbox;
		}
		
		/**
		 * Returns a the new bounds equivalent to the present one plus the specified offset
		 * 
		 * @param x the x offset
		 * @param y the y offet
		 * @return the new bound
		 */
		public function add(x:Number, y:Number):Bounds {
			return new Bounds(this.left + x, this.bottom + y, this.right + x, this.top + y, this.projSrsCode);
		}
		
		/**
		 * Extends the current instance of Bounds from a location.
		 *
		 * @param lonlat The LonLat which will extend the bounds.
		 */
		public function extendFromLocation(location:Location):void {
			this.extendFromBounds(new Bounds(location.lon, location.lat, location.lon, location.lat, location.projSrsCode));
		}
		
		/**
		 * Extends the current instance of Bounds from bounds.
		 *
		 * @param bounds The bounds which will extend the current bounds.
		 */
		public function extendFromBounds(bounds:Bounds):void {
			var tmpBounds:Bounds = bounds;
			if(this.projSrsCode!=tmpBounds.projSrsCode) {
				tmpBounds = tmpBounds.reprojectTo(this.projSrsCode);
			}
			// TODO: check the equality of the projSrsCode of the two bounds ?!
			this.left = (tmpBounds.left < this.left) ? tmpBounds.left : this.left;
			this.bottom = (tmpBounds.bottom < this.bottom) ? tmpBounds.bottom : this.bottom;
			this.right = (tmpBounds.right > this.right) ? tmpBounds.right : this.right;
			this.top = (tmpBounds.top > this.top) ? tmpBounds.top : this.top;
		}
		
		/**
		 * Returns if the current bounds contains the LonLat passed as param
		 *
		 * @param loc The location to check
		 * @param inclusive It will include the border's bounds ?
		 * @return Lonlat is contained or not by the bounds
		 */
		public function containsLocation(loc:Location, inclusive:Boolean = true):Boolean {
			var tmpLoc:Location = loc;
			if(this.projSrsCode != tmpLoc.projSrsCode)
				tmpLoc = tmpLoc.reprojectTo(this.projSrsCode);
			
			var contains:Boolean = false;
			if (inclusive) {
				contains = ((tmpLoc.lon >= this.left) && (tmpLoc.lon <= this.right) &&
					(tmpLoc.lat >= this.bottom) && (tmpLoc.lat <= this.top));
			} else {
				contains = ((tmpLoc.lon > this.left) && (tmpLoc.lon < this.right) &&
					(tmpLoc.lat > this.bottom) && (tmpLoc.lat < this.top));
			}
			return contains;
		}
		
		/**
		 * Determines if the bounds passed in param intersects the current bounds.
		 *
		 * @param bounds The bounds to test intersection.
		 * @param inclusive It will include the border's bounds ?
		 *
		 * @return If the bounds intersects current bounds or not.
		 */
		public function intersectsBounds(bounds:Bounds, inclusive:Boolean = true):Boolean {
			
			var tmpBounds:Bounds = bounds;
			var tmpThis:Bounds = this;
			
			if(tmpThis.projSrsCode!=tmpBounds.projSrsCode)
			{
				tmpBounds = tmpBounds.reprojectTo(DEFAULT_PROJ_SRS_CODE);
				tmpThis = tmpThis.reprojectTo(DEFAULT_PROJ_SRS_CODE);
			}
			
				var inBottom:Boolean = (tmpBounds.bottom == tmpThis.bottom && tmpBounds.top == tmpThis.top) ?
					true : (((tmpBounds.bottom > tmpThis.bottom) && (tmpBounds.bottom < tmpThis.top)) ||
						((tmpThis.bottom > tmpBounds.bottom) && (tmpThis.bottom < tmpBounds.top)));
				var inTop:Boolean = (tmpBounds.bottom == tmpThis.bottom && tmpBounds.top == tmpThis.top) ?
					true : (((tmpBounds.top > tmpThis.bottom) && (tmpBounds.top < tmpThis.top)) ||
						((tmpThis.top > tmpBounds.bottom) && (tmpThis.top < tmpBounds.top)));
				var inRight:Boolean = (tmpBounds.right == tmpThis.right && tmpBounds.left == tmpThis.left) ?
					true : (((tmpBounds.right > tmpThis.left) && (tmpBounds.right < tmpThis.right)) ||
						((tmpThis.right > tmpBounds.left) && (tmpThis.right < tmpBounds.right)));
				var inLeft:Boolean = (tmpBounds.right == tmpThis.right && tmpBounds.left == tmpThis.left) ?
					true : (((tmpBounds.left > tmpThis.left) && (tmpBounds.left < tmpThis.right)) ||
						((tmpThis.left > tmpBounds.left) && (tmpThis.left < tmpBounds.right)));
			
				return (tmpThis.containsBounds(tmpBounds, true, inclusive) ||
					tmpBounds.containsBounds(tmpThis, true, inclusive) ||
					((inTop || inBottom ) && (inLeft || inRight )));
		}
		
		/**
		 * Returns if the current bounds contains the bounds passed as param
		 *
		 * @param bounds The bounds to check
		 * @param partial Partial containing shoulds return true ?
		 * @param inclusive It will include the border's bounds ?
		 *
		 * @return Bounds are contained or not by the bounds
		 */
		
		public function containsBounds(bounds:Bounds, partial:Boolean = false, inclusive:Boolean = true):Boolean {
			
			var tmpBounds:Bounds = bounds;
			var tmpThis:Bounds = this;
			
			if(tmpThis.projSrsCode!=tmpBounds.projSrsCode)
			{
				tmpBounds = tmpBounds.reprojectTo(DEFAULT_PROJ_SRS_CODE);
				tmpThis = tmpThis.reprojectTo(DEFAULT_PROJ_SRS_CODE);
			}
			
			
			// TODO: check the equality of the projSrsCode of the two bounds ?!
			var inLeft:Boolean;
			var inTop:Boolean;
			var inRight:Boolean;
			var inBottom:Boolean;
			
			if (inclusive) {
				inLeft = (tmpBounds.left >= tmpThis.left) && (tmpBounds.left <= tmpThis.right);
				inTop = (tmpBounds.top >= tmpThis.bottom) && (tmpBounds.top <= tmpThis.top);
				inRight= (tmpBounds.right >= tmpThis.left) && (tmpBounds.right <= tmpThis.right);
				inBottom = (tmpBounds.bottom >= tmpThis.bottom) && (tmpBounds.bottom <= tmpThis.top);
			} else {
				inLeft = (tmpBounds.left > tmpThis.left) && (tmpBounds.left < tmpThis.right);
				inTop = (tmpBounds.top > tmpThis.bottom) && (tmpBounds.top < tmpThis.top);
				inRight= (tmpBounds.right > tmpThis.left) && (tmpBounds.right < tmpThis.right);
				inBottom = (tmpBounds.bottom > tmpThis.bottom) && (tmpBounds.bottom < tmpThis.top);
			}
			
			return (partial) ? (inTop || inBottom ) && (inLeft || inRight )
				: (inTop && inLeft && inBottom && inRight);
		}
		
		/**
		 * Determines in which quadrant is placed the lonlat in relation to the current bounds.
		 *
		 * @param lonlat The lonlat we want to know the quadrant
		 *
		 * @return A string describing the quadrant (e.g. "bl" for Bottom-Left, "tr" for Top-Right etc.)
		 */
		public function determineQuadrant(lonlat:Location):String {
			var quadrant:String = "";
			var center:Location = this.center;
			
			/* quadrant += (lonlat.lat < center.lat) ? "b" : "t";
			quadrant += (lonlat.lon < center.lon) ? "l" : "r"; */
			
			if (lonlat.lat < center.lat){
				quadrant += "b";
			}
			else{
				quadrant += "t";
			}
			
			if(lonlat.lon < center.lon){
				quadrant += "l";
			}
			else{
				quadrant += "r";
			}
			
			return quadrant;
		}
		
		/**
		 * Returns a bounds instance from a string following this format: "left,bottom,right,top" or  "left,bottom,right,top,projection".
		 *
		 * @param str The string from which we want create a bounds instance.
		 * @param srsCode The code defining the projection
		 * 
		 * @throw an Argument error if the string contains other that 4 or 5 elements
		 * 
		 * @return An instance of bounds.
		 */
		public static function getBoundsFromString(str:String,srsCode:String = "EPSG:4326"):Bounds {
			var bounds:Array = str.split(",");
			
			if(bounds.length == 4)
				return Bounds.getBoundsFromArray(bounds,srsCode);
			
			if(bounds.length == 5)
			{
				var projection:String = bounds.pop();
				return Bounds.getBoundsFromArray(bounds,projection);
			}
			throw(new ArgumentError("the array must contains 4 or 5 values for bbox"));
		}
		
		/**
		 * Returns a bounds instance from an array following this format: [left,bottom,right,top].
		 *
		 * @param bbox The array from which we want create a bounds instance.
		 * @param srsCode The code defining the projection
		 *
		 * @return An instance of bounds.
		 */
		public static function getBoundsFromArray(bbox:Array,srsCode:String):Bounds {
			if(bbox.length != 4) throw(new ArgumentError("the array must contains 4 numbers for bbox"));
			return new Bounds(Number(bbox[0]), Number(bbox[1]), Number(bbox[2]), Number(bbox[3]), srsCode);
		}
		
		/**
		 * Returns a bounds instance from a size instance.
		 *
		 * @param size The size instance from which we want create a bounds instance.
		 *
		 * @return An instance of bounds.
		 */
		public static function getBoundsFromSize(size:Size):Bounds {
			return new Bounds(0, size.h, size.w, 0, null);
		}
		
		/**
		 * Returns the opposite quadrant compared to the quadrant where is placed
		 * the lonlat in relation to the current bounds.
		 *
		 * @param quadrant The quadrant to opposite
		 *
		 * @return A string describing the opposite quadrant
		 */
		public static function oppositeQuadrant(quadrant:String):String {
			var opp:String = "";
			
			opp += (quadrant.charAt(0) == 't') ? 'b' : 't';
			opp += (quadrant.charAt(1) == 'l') ? 'r' : 'l';
			
			return opp;
		}
		
		/**
		 * Returns a bounds string from an url containing the bbox param
		 *
		 * @param url The url from which we want extract the bounds.
		 * @return A string describing the bounds contained by the url.
		 */
		public static function getBBOXStringFromUrl(url:String):String {
			var startpos:int = url.indexOf("BBOX=") + 5;
			if (startpos < 5) {
				startpos = url.indexOf("bbox=") + 5;
			}
			var endpos:int = url.indexOf("%26", startpos);
			if (endpos < 0) {
				endpos = url.length;
			}
			var tempBbox:String = url.substring(startpos, endpos);
			var tempBboxArr:Array = tempBbox.split("%2C");
			return tempBboxArr[0] + "," + tempBboxArr[1] + " " + tempBboxArr[2] + "," + tempBboxArr[3];
		}
		
		/**
		 * Returns a bounds string from an instance of bounds
		 *
		 * @param bounds The bounds from which we want a string
		 * @return A string describing the bounds.
		 */
		public static function getBBOXStringFromBounds(bounds:Bounds):String {
			return bounds.left + "," + bounds.bottom + " " + bounds.right + "," + bounds.top;
		}
		
		/**
		 * Reproject the current bounds in another projection
		 * 
		 * @param newSrsCode:String SRS code of the target projection
		 * @return the reprojected bounds
		 */
		public function reprojectTo(newSrsCode:String):Bounds {
			if (newSrsCode == this._projSrsCode) {
				return this;
			}
			var pLB:ProjPoint = new ProjPoint(this._left, this._bottom);
			var pRT:ProjPoint = new ProjPoint(this._right, this._top);
			Proj4as.transform(this.projSrsCode, newSrsCode, pLB);
			Proj4as.transform(this.projSrsCode, newSrsCode, pRT);
			
			return new Bounds(pLB.x,pLB.y,pRT.x,pRT.y,newSrsCode);
		}
		
		/**
		 * Create a new polygon geometry based on this bounds.
		 *
		 * @return A new polygon with the coordinates of this bounds.
		 */
		public function toGeometry():Polygon {
			var geom:Polygon = new Polygon(new <Geometry>[
				new LinearRing(new <Number>[
					this.left, this.bottom,
					this.right, this.bottom,
					this.right, this.top,
					this.left, this.top])
			]);
			geom.projSrsCode = this.projSrsCode;
			return geom;
		}
		
		/**
		 * Use this method if you want to get the intersection between thoses Bounds 
		 * and the given ones. Use intersectsBounds() before to avoid problem with 
		 * empty intersections.
		 * <p>
		 * If the two Bounds are not in the same projection, they will be converted in
		 * EPSG:4326 and the returned Bounds will be in EPSG:4326 too, don't forget to
		 * reproject it with reprojectTo if you are not working with this projection.
		 * </p>
		 * 
		 * @return The Bounds representing the intersection between thosesBounds and the
		 * given ones. If the intersection is empty, the retuned Bounds will be empty with
		 * EPSG:4326 projection if the two bounds are not in the same projection, or the
		 * projection of the two bounds if they are in the same projection. 
		 */
		public function getIntersection(bounds:Bounds):Bounds{
			

			// Variable used of a reprojection is needed
			var thisBounds:Bounds = this;
			if (thisBounds.projSrsCode != bounds.projSrsCode)
			{
				thisBounds = thisBounds.reprojectTo("EPSG:4326");
				bounds = bounds.reprojectTo("EPSG:4326");
			}
			
			if (!(this.intersectsBounds(bounds)))
			{
				return new Bounds(0,0,0,0, thisBounds.projSrsCode);
			}
			
			// Init the values with on of the bounds
			var left:Number = bounds.left;
			var right:Number = bounds.right;
			var top:Number = bounds.top;
			var bottom:Number = bounds.bottom;
			
			// Compute the left limit of the extent
			if(thisBounds.left > bounds.left)
			{
				left = thisBounds.left;
			}
			
			// Compute the right limit of the extent
			if(thisBounds.right < bounds.right)
			{
				right = thisBounds.right;
			}
			
			// Compute the top limit of the extent
			if(thisBounds.top < bounds.top)
			{
				top = thisBounds.top;	
			}
			
			// Compute the bottom limit of the extent
			if(thisBounds.bottom > bounds.bottom)
			{
				bottom = thisBounds.bottom;
			}
			
			return new Bounds(left,bottom, right, top, thisBounds.projSrsCode);
		}
		
		
		/**
		 * Indicates the projection code.
		 */
		public function get projSrsCode():String {
			return this._projSrsCode;
		}
		/** 
		 * @private 
		 */ 
		public function set projSrsCode(value:String):void {
			this._projSrsCode = value;
		}
		
		/**
		 * Indicates the left bound of the bounds
		 */
		public function get left():Number {
			return _left;
		}
		/** 
		 * @private 
		 */ 
		public function set left(value:Number):void {
			_left = value;
		}
		
		/**
		 * Indicates the bottom bound of the bounds
		 */
		public function get bottom():Number {
			return _bottom;
		}
		/** 
		 * @private 
		 */ 
		public function set bottom(value:Number):void {
			_bottom = value;
		}
		
		/**
		 * Indicates the right bound of the bounds
		 */
		public function get right():Number {
			return _right;
		}
		/** 
		 * @private 
		 */ 
		public function set right(value:Number):void {
			_right = value;
		}
		
		/**
		 * Indicates the top bound of the bounds
		 */
		public function get top():Number {
			return _top;
		}
		/** 
		 * @private 
		 */ 
		public function set top(value:Number):void {
			_top = value;
		}
		
		/**
		 * Indicates the width of the bounds
		 */
		public function get width():Number {
			return Math.abs(this.right - this.left);
		}
		
		/**
		 * Indicates the height of the bounds
		 */
		public function get height():Number {
			return Math.abs(this.top - this.bottom);
		}
		
		/**
		 * Indicates the size of the bounds
		 */
		public function get size():Size {
			return new Size(this.width, this.height);
		}
		
		/**
		 * Indicates the center of the bounds
		 */
		public function get center():Location {
			return new Location((this.left + this.right) / 2, (this.bottom + this.top) / 2, this.projSrsCode);
		}
		
	}
}
