package org.openscales.core.feature
{
	import org.openscales.geometry.Geometry;

	/**
	 * This class is not permanent and will be delete when it will be useless
	 *
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10
	 * @author jean-sebastien.baklouti@atosorigin.com
	 */
	public class DescribeFeature
	{
		private var _attributes:Object;
		private var _geometryType:String;
		
		public function DescribeFeature(geometryType:String,attributes:Object)
		{
			
			_geometryType = geometryType;
			_attributes = attributes;
		}
		
		
		public function get geometryType():String
		{
			return _geometryType;
		}

		public function set geometryType(value:String):void
		{
			_geometryType = value;
		}
		
		public function get attributes():Object
		{
			return _attributes;
		}
		
		public function set attributes(value:Object):void
		{
			_attributes = value;
		}

	}
}