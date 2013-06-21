package org.openscales.core.style.graphic
{
	import mockolate.mock;
	import mockolate.received;
	
	import org.hamcrest.assertThat;
	import org.openscales.SuperTest;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.request.DataRequest;
	
	use namespace os_internal;

	public class ExternalGraphicTest extends SuperTest
	{		
		[Mock]
		public var mockRequest:DataRequest;
		
		private var _instance:ExternalGraphic;
		
		override public function setUp():void
		{
			super.setUp();			
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			mockRequest = null;
			_instance = null;
		}
		
		[Test]
		public function shouldLoadUsingProxyAtInstanciation():void{
			// When an external graphic is created with a proxy and url ressource
			_instance = new TestableExternalGraphic(mockRequest,"http://toto.org","image/png","http://proxy.com");
			// Then the method the send method of DataRequest object should be called once
			assertThat(mockRequest, received().method("send").once());
			// And the proxy should have been passed to the DataRequest object
			assertThat(mockRequest, received().setter("proxy").arg("http://proxy.com"));
		}
	}
}
import org.openscales.core.request.DataRequest;
import org.openscales.core.style.graphic.ExternalGraphic;

/**
 * This class provide a way to test ExternalGrpahic, which means it allows to customize the DataRequest object used to send queries
 */ 
class TestableExternalGraphic extends ExternalGraphic{
	private var _request:DataRequest;
	
	public function TestableExternalGraphic(request:DataRequest,onlineResource:String,format:String="image/png",proxy:String=null) {
		_request = request;
		super(onlineResource,format,proxy);
		
	}
	
	override protected function buildRequest(url:String, onSuccess:Function, onFailure:Function):DataRequest
	{
		return _request;
	}	
}