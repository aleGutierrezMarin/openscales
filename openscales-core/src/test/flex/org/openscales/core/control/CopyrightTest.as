package org.openscales.core.control
{
	import org.flexunit.Assert;
	
	public class CopyrightTest
	{		
		[Test]
		public function testCopyrightInitialization():void {
			var copyright:Copyright = new Copyright("test");
			
			Assert.assertEquals("test", copyright.copyright);
		}
	}
}