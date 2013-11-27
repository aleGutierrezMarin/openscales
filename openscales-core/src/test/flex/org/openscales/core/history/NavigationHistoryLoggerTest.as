package org.openscales.core.history
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.openscales.core.Map;
	import org.openscales.core.ns.os_internal;

	use namespace os_internal;
	
	public class NavigationHistoryLoggerTest
	{		
		private var _instance:NavigationHistoryLogger;
		private var _map:Map;
		
		[Before]
		public function setUp():void
		{
			_instance = new NavigationHistoryLogger();
			_map = new Map();
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[Test]
		public function shouldHaveADefaultSizeOf10():void{
			assertEquals("Default size should be 10", 10, _instance.size);
		}
		
		[Test] 
		public function shouldHaveTheSpecifiedSize():void{
			_instance = new NavigationHistoryLogger(20);
			assertEquals("Size should be equal to constructor param", 20, _instance.size);
		}
		
		[Test]
		public function shouldTellIsAtBeginingAfterInstanciation():void{
			assertTrue("Logger should be at beginning", _instance.isAtBeginning());
		}
		
		[Test]
		public function shouldTellIsAtEndAfterInstanciation():void{
			assertTrue("Logger should be at end", _instance.isAtEnd());
		}
		
		[Test]
		public function shouldLogMapInitialPosition():void{
			_instance.map = _map;
			assertTrue("Logger should be at beginning", _instance.isAtBeginning());
			assertTrue("Logger should be at end", _instance.isAtEnd());	
		}
		
		
		
	}
}