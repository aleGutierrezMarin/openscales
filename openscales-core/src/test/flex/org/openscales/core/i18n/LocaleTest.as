package org.openscales.core.i18n
{
	import flash.system.Capabilities;
	
	import flashx.textLayout.conversion.ConversionType;
	
	import flexunit.framework.Assert;
	
	import org.openscales.core.i18n.Locale;
	import org.openscales.core.ns.os_internal;
	
	use namespace os_internal;
	
	public class LocaleTest
	{
		public function LocaleTest() {}
		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		/**
		 * Test the Locale correct creation
		 * 
		 * Given parameters for Locale creation
		 * When the Locale object is created with this parameters
		 * Then the object is created correctly
		 * 
		 */
		[Test]
		public function shouldInitializeLocale():void
		{
			// Given parameters for Locale creation
			var localeKey:String = "tt";
			var localeName:String = "Test";
			var localizedName:String = "Test";
			
			// When the Locale object is created with this parameters
			var locale:Locale = new Locale(localeKey, localeName, localizedName);
			
			// Then the object is created correctly
			Assert.assertEquals("Incorrect value for localeKey", locale.localeKey, localeKey);
			Assert.assertEquals("Incorrect value for localeName", locale.localeName, localeName);
			Assert.assertEquals("Incorrect value for localizedName", locale.localizedName, localizedName);
		}
		
		/**
		 * Test the genLocale static method
		 * 
		 * Given params for a new Locale definition
		 * When the static genLocale function is called with those params
		 * Then the Locale must contain the new Locale
		 * 
		 */
		[Test]
		public function shouldGenerateNewLocale():void
		{
			// Given params for a new Locale definition
			var key:String = "NEWL";
			var name:String = "New Language";
			var localizedName:String = "New Language";
			
			// When the static genLocale function is called with those params
			Locale.addLocale(key, name, localizedName);
			
			// Then the Locale must contain the new Locale
			Assert.assertNotNull("Incorrect value for Locale ",Locale.getLocaleByKey(key)); 
		}
		
		
		/**
		 * Test the setter of the active locale
		 * 
		 * Given a Locale
		 * When the locale is set as activeLocale
		 * Then the get activeLocale should return the given locale
		 *
		 */
		[Test]
		public function shouldSetActiveLocale():void
		{
			
			// Given a Locale
			var myLocale:Locale = Locale.getLocaleByKey("DA");
			
			// When the locale is set as activeLocale
			Locale.activeLocale = myLocale;
			
			// Then the get activeLocale should return the given locale
			Assert.assertEquals("Incorrect active locale value ", Locale.activeLocale.localeKey, myLocale.localeKey);
		}
		
		/**
		 * Test the setter of the active locale with null value given
		 * 
		 * Given the Locale Class
		 * When null is set as activeLocale
		 * Then the get activeLocale should not change
		 *
		 */
		[Test]
		public function shouldSetActiveLocaleWithNullValue():void
		{
			
			// Given the Locale Class
			var current:Locale = Locale.activeLocale;
			
			// When null is set as activeLocale
			Locale.activeLocale = null;
			
			// Then the get activeLocale should not change
			Assert.assertEquals("Incorrect active locale value ", Locale.activeLocale.localeKey, current.localeKey);
		}
		
		/**
		 * Test if the active locale is correctly get
		 * 
		 * Given the Locale Class
		 * When the get activeLocale method is called
		 * Then return value has to be equals to the SystemLocale
		 */
		[Test]
		public function shouldReturnCorrectActiveLocaleOnStaticMethodActiveLocaleCalled():void
		{
			// Given the Locale Class
			// When the systemLocale method is called
			Locale.activeLocale = Locale.systemLocale;
			var locale:Locale = Locale.activeLocale;
			
			// Then the key corresponding to its return value has to be equal to the systemLocale Key;
			Assert.assertEquals("Incorrect value for localeKey", locale.localeKey, Locale.systemLocale.localeKey);
		}
		
		
		/**
		 * Test if the system Locale is correctly define and get
		 * 
		 * Given the Locale Class
		 * When the systemLocale method is called
		 * Then the key corresponding to its return value has to be equal to Capabilities.language.toUpperCase();
		 */
		[Test]
		public function shouldReturnCorrectSystemLocaleOnStaticMethodSystemLocaleCalled():void
		{
			// Given the Locale Class
			// When the systemLocale method is called
			var locale:Locale = Locale.systemLocale;
			
			// Then the key corresponding to its return value has to be equal to Capabilities.language;
			Assert.assertEquals("Incorrect value for localeKey", locale.localeKey, Capabilities.language);
		}
	}
}