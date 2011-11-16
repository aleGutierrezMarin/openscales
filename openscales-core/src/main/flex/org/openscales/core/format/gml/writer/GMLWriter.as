package org.openscales.core.format.gml.writer
{
	import org.openscales.core.feature.Feature;

	public class GMLWriter
	{
		
	
		private var _wfsns:Namespace;
		private var _gmlns:Namespace;
		private var _dim:uint = 2;
		
		public function GMLWriter()
		{
			this.wfsns = new Namespace("wfs","http://www.opengis.net/wfs/2.0");
			this.gmlns = new Namespace("gml", "http://www.opengis.net/gml/3.2");
			
		}
		
		public function write(featureCol:Vector.<Feature>, geometryNamespace:String,
							  featureType:String, geometryName:String):XML{
			return null;
		}


		public function get wfsns():Namespace
		{
			return _wfsns;
		}

		public function set wfsns(value:Namespace):void
		{
			_wfsns = value;
		}

		public function get gmlns():Namespace
		{
			return _gmlns;
		}

		public function set gmlns(value:Namespace):void
		{
			_gmlns = value;
		}

		public function get dim():uint
		{
			return _dim;
		}

		public function set dim(value:uint):void
		{
			_dim = value;
		}


	}
}