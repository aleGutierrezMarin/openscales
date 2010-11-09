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
		/**
		 * maybe change this name
		 * convert for example gml:MultiPointPropertyType in org.openscales.geometry::MultiPoint
		 * */
		private function changeNameOfGeometry(geometryType:String):String{
			return "org.openscales.geometry::" + geometryType.substring(4,geometryType.length - 12);;
		}
		
		public function setGeometryTypeFromGMLFormat(geometryType:String):void{
			_geometryType = changeNameOfGeometry(geometryType);
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
		/**
		 *maybe to remove 
		 * @return 
		 * 
		 */		
	    public function getAttributesWithoutType():Object{
			var attributesTemp:Object = new Object();
			
	        for each(var temp:String in _attributes ){

				attributesTemp[temp] = "";
				
			}	
			return attributesTemp;
		}	
		
		public function set attributes(value:Object):void
		{
			_attributes = value;
		}

	}
}