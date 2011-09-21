package org.openscales.core.layer.ogc.provider
{
	import org.flexunit.asserts.*;
	import org.openscales.core.ns.os_internal;
	import org.openscales.geometry.basetypes.Bounds;

	public class WMSTileProviderTest{
		
		use namespace os_internal;
		
		[Test]
		public function shouldForgeRequestsWithAllTheMandatoryParameters():void{
			
			// Given a WMSTileProvider 
			var provider:WMSTileProvider = new WMSTileProvider('http://someDomain.com','1.1.1','someLayer','EPSG:4326');
			provider.width = 200;
			provider.height = 200;
			
			// When a request is forged
			var bbox:Bounds = new Bounds(-180,-90,180,90);
			var url:String = provider.getTileUrl(bbox);
			
			// Then URL contains all WMS mandatory parameters, set to the values defined in the provider
			assertTrue('Mandatory parameter VERSION is not present',url.match('VERSION=1.1.1'));
			assertTrue('Mandatory parameter SERVICE is not present',url.match('SERVICE=WMS'));
			assertTrue('Mandatory parameter REQUEST is not present',url.match('REQUEST=GetMap'));
			assertTrue('Mandatory parameter LAYERS is not present',url.match('LAYERS='+provider.layer));
			assertTrue('Mandatory parameter STYLES is not present',url.match('STYLES='+provider.style));
			assertTrue('Mandatory parameter SRS is not present',url.match('SRS='+provider.projection));
			assertTrue('Mandatory parameter BBOX is not present',url.match('BBOX='+bbox));
			assertTrue('Mandatory parameter WIDTH is not present',url.match('WIDTH='+provider.width));
			assertTrue('Mandatory parameter HEIGHT is not present',url.match('HEIGHT='+provider.height));
			assertTrue('Mandatory parameter FORMAT is not present',url.match('FORMAT='+provider.format));
			
		}
	}
}