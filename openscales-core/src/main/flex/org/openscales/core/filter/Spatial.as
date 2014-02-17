package org.openscales.core.filter
{
	import org.openscales.core.feature.Feature;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.basetypes.Bounds;
	
	public class Spatial implements IFilter
	{
		
		public static var BBOX:String = "BBOX";
		public static var INTERSECTS:String = "Intersects";
		public static var DWITHIN:String = "DWithin";
		public static var WITHIN:String = "Within";
		public static var CONTAINS:String = "Contains";
		public static var CROSSES:String = "Crosses";
		public static var OVERLAPS:String = "Overlaps";
		public static var TOUCHES:String = "Touches";
		public static var DISJOINT:String = "Disjoint";
		public static var BEYOND:String = "Crosses";
		public static var EQUALS:String = "Equals";
		
		
		private var _type:String;
		private var _property:String;
		private var _value:Object;
		private var _distance:Number;
		private var _distanceUnits:String;
		
		
		public function Spatial(type:String)
		{
			this._type = type;
		}
		
		public function matches(feature:Feature):Boolean
		{
			
			if(!feature || !feature.geometry)
				return false;

			var geom:Geometry;
			
			if(this.value is Bounds)
				geom = (this.value as Bounds).reprojectTo(feature.projection).toGeometry();
			else if(this.value is Geometry) {
				geom = (this.value as Geometry).clone();
				geom.transform(feature.projection);
			}
			
			switch(this.type) {
				case BBOX:
				case INTERSECTS:
					if(feature.geometry.intersects(geom)) {
						return true;
					}
					break;
				case CONTAINS:
					if(feature.geometry.contains(geom)) {
						return true;
					}
					break;
				default:
					throw new Error('evaluate is not implemented for this filter type.');
			}
			return false;
		}
		
		public function clone():IFilter
		{
			var ret:Spatial = new Spatial(this._type);
			ret.distance = this._distance;
			ret.distanceUnits = this._distanceUnits;
			ret.property = this._property;
			ret.value = this._value;
			return ret;
		}
		
		public function get sld():String
		{
			var ret:String = "<ogc:Filter>\n";
			ret+="<ogc:"+this._type+">\n";
			ret+="<ogc:PropertyName>"+this._property+"</ogc:PropertyName>\n";
			switch (this._type) {
				case BBOX:
					if(this._value is Bounds) {
						var b:Bounds = (this._value as Bounds).reprojectTo("EPSG:4326");
						ret+="<gml:Box srsName=\"urn:x-ogc:def:crs:EPSG:4326\">\n";
						ret+="<gml:coord>\n";
						ret+="<gml:X>"+b.left+"</gml:X>\n<gml:Y>"+b.bottom+"</gml:Y>\n";
						ret+="</gml:coord>\n";
						ret+="<gml:coord>\n";
						ret+="<gml:X>"+b.right+"</gml:X>\n<gml:Y>"+b.top+"</gml:Y>\n";
						ret+="</gml:coord>\n";
					}
					break;
				case INTERSECTS:
					break;
				case DWITHIN:
					break;
				case WITHIN:
					break;
				case CONTAINS:
					break;
				case CROSSES:
					break;
				case OVERLAPS:
					break;
				case TOUCHES:
					break;
				case DISJOINT:
					break;
				case BEYOND:
					break;
				case EQUALS:
					break;
				
			}
			ret+="</ogc:"+this._type+">\n";
			ret+="</ogc:Filter>\n";
			return ret;
		}
		
		public function set sld(sld:String):void
		{
			//TODO
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function get property():String
		{
			return _property;
		}

		public function set property(value:String):void
		{
			_property = value;
		}

		/**
		 * The bounds or geometry to be used by the filter.
		 * Use bounds for BBOX filters and geometry for INTERSECTS or DWITHIN filters.
		 */
		public function get value():Object
		{
			return _value;
		}

		/**
		 * @private
		 */
		public function set value(value:Object):void
		{
			_value = value;
		}

		/**
		 * The distance to use in a DWithin spatial filter.
		 */
		public function get distance():Number
		{
			return _distance;
		}

		/**
		 * @private
		 */
		public function set distance(value:Number):void
		{
			_distance = value;
		}

		/**
		 * The units to use for the distance, e.g. 'm'.
		 */
		public function get distanceUnits():String
		{
			return _distanceUnits;
		}

		/**
		 * @private
		 */
		public function set distanceUnits(value:String):void
		{
			_distanceUnits = value;
		}


	}
}