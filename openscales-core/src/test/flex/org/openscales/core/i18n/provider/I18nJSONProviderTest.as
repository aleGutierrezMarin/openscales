package org.openscales.core.i18n.provider
{
	import flexunit.framework.Assert;
	
	import org.openscales.core.i18n.Catalog;
	import org.openscales.core.i18n.Locale;
	
	public class I18nJSONProviderTest
	{
		[Embed(source="/assets/i18n/TEST.json", mimeType="application/octet-stream")]
		private const TESTLocale:Class;
		
		[Embed(source="/assets/i18n/NEWLOCALE.json", mimeType="application/octet-stream")]
		private const NEWLOCALELocale:Class;
		
		[Embed(source="/assets/i18n/INCORRECT.json", mimeType="application/octet-stream")]
		private const INCORRECT:Class;
		
		public function I18nJSONProviderTest() {}
		
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
		 * Test the addition of translation with a Json source and an existing Locale
		 *
		 * Given a json source (Embed Class)
		 * When the addTranslation method is called
		 * Then all the translation are on the Catalog
		 *
		 */
		[Test]
		public function shouldAddTranslationWithJSonSourceAndExistingLocale():void
		{
			// Given a json source (Embed Class)
			
			// When the addTranslation method is called
			I18nJSONProvider.addTranslation(TESTLocale);
			Locale.activeLocale = Locale.getLocaleByKey("en");
			
			// Then all the translation are on the Catalog
			Assert.assertEquals("Incorrect value for key one translation", Catalog.getLocalizationForKey("test.translateone"), "One");
			Assert.assertEquals("Incorrect value for key one translation", Catalog.getLocalizationForKey("test.translatetwo"), "Two");
			Assert.assertEquals("Incorrect value for key one translation", Catalog.getLocalizationForKey("test.translatethree"), "Three");
			Assert.assertEquals("Incorrect value for key one translation", Catalog.getLocalizationForKey("test.translatefour"), "Four");
			Assert.assertEquals("Incorrect value for key one translation", Catalog.getLocalizationForKey("test.translatefive"), "Five");
		}
		
		/**
		 * Test the addition of translation with a Json source and a new Locale
		 *
		 * Given a json source (Embed Class) and a new Locale
		 * When the addTranslation method is called
		 * Then all the translation are on the Catalog
		 *
		 */
		[Test]
		public function shouldAddTranslationWithJSonSourceWithANewLocale():void
		{
			// Given a json source (Embed Class)
			
			// When the addTranslation method is called
			I18nJSONProvider.addTranslation(NEWLOCALELocale);
			Locale.activeLocale = Locale.getLocaleByKey("TEST");
			
			// Then all the translation are on the Catalog
			Assert.assertEquals("Incorrect value for key one translation", Catalog.getLocalizationForKey("newlocale.translateone"), "One");
			Assert.assertEquals("Incorrect value for key two translation", Catalog.getLocalizationForKey("newlocale.translatetwo"), "Two");
			Assert.assertEquals("Incorrect value for key three translation", Catalog.getLocalizationForKey("newlocale.translatethree"), "Three");
			Assert.assertEquals("Incorrect value for key four translation", Catalog.getLocalizationForKey("newlocale.translatefour"), "Four");
			Assert.assertEquals("Incorrect value for key five translation", Catalog.getLocalizationForKey("newlocale.translatefive"), "Five");
		}
		
		/**
		 * Test the non addition of translation with incorrect json source
		 *
		 * Given an invalid json source (Embed Class) and a new Locale
		 * When the addTranslation method is called
		 * Then all the translation are not on the Catalog
		 *
		 */
		[Test]
		public function shouldNotAddTranslationWithIncorrectJSonSource():void
		{
			// Given an invalid json source (Embed Class) and a new Locale
			
			// When the addTranslation method is called
			I18nJSONProvider.addTranslation(INCORRECT);
			Locale.activeLocale = Locale.getLocaleByKey("en");
			
			// Then all the translation are not on the Catalog
			Assert.assertEquals("Incorrect value for key one translation", Catalog.getLocalizationForKey("incorrect.translateone"), "incorrect.translateone");
			Assert.assertEquals("Incorrect value for key two translation", Catalog.getLocalizationForKey("incorrect.translatetwo"), "incorrect.translatetwo");
			Assert.assertEquals("Incorrect value for key three translation", Catalog.getLocalizationForKey("incorrect.translatethree"), "incorrect.translatethree");
			Assert.assertEquals("Incorrect value for key four translation", Catalog.getLocalizationForKey("incorrect.translatefour"), "incorrect.translatefour");
			Assert.assertEquals("Incorrect value for key five translation", Catalog.getLocalizationForKey("incorrect.translatefive"), "incorrect.translatefive");
		}
	}
}