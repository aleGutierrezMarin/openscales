package org.openscales.core.ns
{
	/**
	 * @private
	 * 
	 * This namespace is used for method that can not be public but yet need to be tested 
	 * and thus accessed by a FlexUnit class.
	 * 
	 * Below is an example with a sample class and its testing class
	 * 
	 * <code>
	 * package org.my.class.pckg
	 * {
	 *		import org.openscales.core.ns.os_internal;
	 * 		use namespace os_internal;
	 * 		
	 * 		public class MyClass 
	 *		{
	 * 			os_internal function myFunction():void { trace("foo"); };  			
	 * 		}
	 * }	
	 * </code>
	 * 
	 * <code>
	 * package org.my.test.pckg
	 * {
	 * 		import org.openscales.core.ns.os_internal;
	 * 		use namespace os_internal;
	 * 		
	 * 		public class MyClassTest
	 * 		{
	 * 			[Test]
	 * 			public function testMyFunction():void
	 * 			{
	 * 				var instance:MyClass = new MyClass();
	 * 				instance.myFunction();
	 * 			}
	 * 		}
	 * }
	 * </code>
	 * 
	 */ 
	public namespace os_internal = "http://www.openscales.org/internal";
}
