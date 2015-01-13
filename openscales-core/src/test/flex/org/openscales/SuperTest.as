package org.openscales
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mockolate.runner.MockolateRule;
	
	import org.flexunit.asserts.assertTrue;

	/**
	 * A base class for test that provide a timer for asynchronous tests
	 */ 
	public class SuperTest
	{	
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		protected var _timer:Timer;
		
		public function SuperTest()
		{
		}
		
		[Before]
		public function setUp():void
		{
			
			_timer = new Timer( 200, 1 );		
		}
		
		[After]
		public function tearDown():void
		{
			if( _timer )_timer.stop();
			_timer = null;
		}
		
		[Test]
		[Ignore]
		public function shouldFlexMojoBeADumbass():void{
			var flexMojoIsADumbass:Boolean = true;
			assertTrue("FlexMojo cant understand that this class has no tests, hence here is one",flexMojoIsADumbass);
		}
	}
}