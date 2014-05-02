package org.openscales.core.layer.ogc
{
	import org.openscales.geometry.basetypes.Bounds;
	import flexunit.framework.Assert;
	
	public class WFSTest
	{
		private const NAME:String = "WFSLayer";
		private const URL:String = "http://openscales.org/geoserver/wfs";
		private const TYPENAME:String = "topp:states";
		private const VERSION:String = "2.0.0";
		private const PROJECTION:String = "EPSG:4326";
		private const BBOX:Bounds = new Bounds(-180, -90, 180, 90);
		private var _wfs:WFS = null;
		private var _bbox:String = "-180,-90,180,90";
		
		public function WFSTest() {}
		
		
		[Before]
		public function setUp():void
		{
			_wfs = new WFS(NAME,URL,TYPENAME, VERSION);
			_wfs.params.bbox = this._bbox;
		}
		
		[After]
		public function tearDown():void
		{
			_wfs = null;
		}
		
		[Test]
		public function getFullRequestStringTest():void {
			
			_wfs.url = "http://someServer.com";
			var request:String = _wfs.getFullRequestString();
			Assert.assertTrue('Mandatory parameter VERSION is not present',request.match('VERSION=2.0.0'));
			Assert.assertTrue('Mandatory parameter SERVICE is not present',request.match('SERVICE=WFS'));
			Assert.assertTrue('Mandatory parameter REQUEST is not present',request.match('REQUEST=GetFeature'));
			Assert.assertTrue('Parameter TYPENAMES is not present',request.match('TYPENAMES=topp:states'));
			Assert.assertTrue('Parameter BBOX is not present',request.match('BBOX=-180,-90,180,90'));
		}
		
	}
}