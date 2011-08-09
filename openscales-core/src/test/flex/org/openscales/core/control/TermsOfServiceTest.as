package org.openscales.core.control
{
	import org.flexunit.Assert;
	
	public class TermsOfServiceTest
	{		
		[Test]
		public function testTermsOfServiceInitialization():void {
			var termsOfService:TermsOfService = new TermsOfService("www.google.fr", "Terms of service");
			
			Assert.assertEquals("www.google.fr", termsOfService.url);
			Assert.assertEquals("Terms of service", termsOfService.label);
			
		}
	}
}