package org.openscales.geometry.utils
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;

	public class StringUtilsTest
	{
		public function StringUtilsTest()
		{
		}
		
		[Test]
		public function testStartWith():void{
			assertTrue("'foobar' starts with 'foo'",StringUtils.startsWith('foobar','foo'));
			assertFalse("'foobar' does not starts with 'bar'",StringUtils.startsWith('foobar','bar'));
			assertTrue("'foobar' starts with ''",StringUtils.startsWith('foobar',''));
			assertFalse("'' does not starts with 'bar'",StringUtils.startsWith('','bar'));
		}
		
		[Test]
		public function testContains():void{
			assertTrue("'foobar' contains 'foo'",StringUtils.contains('foobar','foo'));
			assertTrue("'foobar' contains 'bar'",StringUtils.contains('foobar','bar'));
			assertTrue("'foobar' contains ''",StringUtils.contains('foobar',''));
			assertFalse("'' does not contains 'bar'",StringUtils.contains('','bar'));
		}
		
		[Test]
		public function testCamelize():void{
			assertEquals("Camelize 'chicken-head'",'chickenHead',StringUtils.camelize('chicken-head'));
			assertEquals("Camelize '-chicken-head'",'ChickenHead',StringUtils.camelize('-chicken-head'));
		}
		
		[Test]
		public function testTrim():void{
			assertEquals("Trim ' chicken head'",'chicken head',StringUtils.trim(' chicken head'));
			assertEquals("Camelize '-ch cken-head     '",'-ch cken-head',StringUtils.trim('-ch cken-head     '));
		}
	}
}