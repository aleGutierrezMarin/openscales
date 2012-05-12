package org.openscales.core.i18n
{
	import flexunit.framework.Assert;
	
	import org.openscales.core.basetypes.maps.HashMap;
	
	public class CatalogTest
	{
		public function CatalogTest() {}
		
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
		 * Test the setting of a new translation (setLocalizationForKey)
		 * 
		 * Given the activeLocale, a key and a translation
		 * When the new localisation is set
		 * Then the key and translation are defined for the given Locale
		 */
		[Test]
		public function shouldSetLocalizationForKey():void
		{
			// Given the activeLocale, a key and a translation
			var locale:Locale = Locale.activeLocale;
			var key:String = "new.key";
			var translate:String = "translation";
			
			// When the new localisation is set
			Catalog.setLocalizationForKey(locale, key, translate);
			
			// Then the key and translation are defined for the given Locale
			Assert.assertEquals("Incorrect value for key translation", Catalog.getLocalizationForKey('new.key'), translate);
		}
		
		/**
		 * Test the setting of a new translation (setLocalizationForKey)
		 * 
		 * Given a new Locale, a key and a translation
		 * When the new Locale is generate and the activeLocale set to the new Locale
		 * Then the key and translation are defined for the given Locale
		 */
		[Test]
		public function shouldSetLocalizationForKeyForNewLocale():void
		{
			// Given a Locale, a key and a translation
			var localeKey:String = "KT";
			var localeName:String = "KeyTest";
			var localeLocalized:String = "test";
			var key:String = "another.key";
			var translate:String = "translation";
			
			// When the new localisation is set and the activeLocale set to the new Locale
			Locale.addLocale(localeKey, localeName, localeLocalized);
			Catalog.setLocalizationForKey(Locale.getLocaleByKey(localeKey), key, translate);
			Locale.activeLocale = Locale.getLocaleByKey(localeKey);
			
			// Then the key and translation are defined for the given Locale
			Assert.assertEquals("Incorrect value for key translation", Catalog.getLocalizationForKey(key), translate);
		}
		
		
		/**
		 * Test the setting of several new translations for a same key (setLocalizationsForKey)
		 * 
		 * Given a HashMap with Locale as key and translations as value
		 * When the localisations are set
		 * Then they are in the current Catalog
		 */
		[Test]
		public function shouldSetLocalizationsForKey():void
		{
			// Given a HashMap with Locale as key and translations as value
			var hashMap:HashMap = new HashMap();	
			
			hashMap.put(Locale.getLocaleByKey("en"),"one set");
			hashMap.put(Locale.getLocaleByKey("fr"),"un set");
			
			// When the localisations are set
			Catalog.setLocalizationsForKey("key.oneSet", hashMap);
			
			// Then they are in the current Catalog
			Assert.assertEquals("Incorrect value for key one translation", Catalog.getLocalizationForLocaleAndKey(Locale.getLocaleByKey("en"), "key.oneSet"), "one set");
			Assert.assertEquals("Incorrect value for key two translation", Catalog.getLocalizationForLocaleAndKey(Locale.getLocaleByKey("fr"), "key.oneSet"), "un set");
		}
		
		/**
		 * Test the setting of several translations for several keys (setLocalizationsForKeys)
		 * 
		 * Given a Hashpmap that contains key and a hashmap with locale and translation
		 * When the hashmap is given to the setLocalizationsForKeys method
		 * Then all the translations have been on the Catalog
		 *
		 */
		[Test]
		public function shouldSetLocalizationsForKeys():void
		{
			// Given a Hashpmap that contains key and a hashmap with locale and translation
			var hashMapOne:HashMap = new HashMap();	
			hashMapOne.put(Locale.getLocaleByKey("en"),"one");
			hashMapOne.put(Locale.getLocaleByKey("fr"),"un");
			
			var hashMapTwo:HashMap = new HashMap();	
			hashMapTwo.put(Locale.getLocaleByKey("en"),"two");
			hashMapTwo.put(Locale.getLocaleByKey("fr"),"deux");
			
			var mainHashMap:HashMap = new HashMap();
			mainHashMap.put("key.one", hashMapOne);
			mainHashMap.put("key.two", hashMapTwo);
			
			// When the hashmap is given to the setLocalizationsForKeys method
			Catalog.setLocalizationsForKeys(mainHashMap);
			
			// Then all the translations have been on the Catalog
			Assert.assertEquals("Incorrect value for key one translation", Catalog.getLocalizationForLocaleAndKey(Locale.getLocaleByKey("en"), "key.one"), "one");
			Assert.assertEquals("Incorrect value for key two translation", Catalog.getLocalizationForLocaleAndKey(Locale.getLocaleByKey("fr"), "key.one"), "un");
			Assert.assertEquals("Incorrect value for key one translation", Catalog.getLocalizationForLocaleAndKey(Locale.getLocaleByKey("en"), "key.two"), "two");
			Assert.assertEquals("Incorrect value for key two translation", Catalog.getLocalizationForLocaleAndKey(Locale.getLocaleByKey("fr"), "key.two"), "deux");
		}
		
		/** Test if the return value for a given locale and key is correct
		 * 
		 * Given the Catalog class with a translation on it
		 * When a the localization is get with a Locale and key
		 * Then the correct translation value is get
		 *
		 */
		[Test]
		public function shouldGetLocalizationForLocaleAndKey():void
		{
			// Given the Catalog class with a translation on it
			var locale:Locale = new Locale("KT", "KeyTest", "test");
			var key:String = "new.keyForTest";
			var translate:String = "translation";
			
			Catalog.setLocalizationForKey(locale, key, translate);
			
			// When a the localization is get with a Locale and key
			var result:String = Catalog.getLocalizationForLocaleAndKey(locale, key);
			
			// Then the key and translation are defined for the given Locale
			Assert.assertEquals("Incorrect value for key translation", result, translate);
		}
		
		/** 
		 * Test if the return value for the active locale and a given key is correct
		 * 
		 * Given the Catalog class with a translation on it (for activeLocale)
		 * When a the localization is get with a key
		 * Then the correct translation value is get
		 *
		 */
		[Test]
		public function shouldGetLocalizationForKey():void
		{
			// Given the Catalog class with a translation on it (for activeLocale)
			var key:String = "new.keyTranslation";
			var translate:String = "translation";
			Catalog.setLocalizationForKey(Locale.activeLocale, key, translate);
			
			// When a the localization is get with a key
			var result:String = Catalog.getLocalizationForKey(key);
			
			// Then the key and translation are defined for the given Locale
			Assert.assertEquals("Incorrect value for key translation", result, translate);
		}
		
		/** 
		 * Test if the return value for the active locale and a given key is correct
		 * 
		 * Given the Catalog class
		 * When a the localization is get with a key that doesn't exist
		 * Then the getLocalizationForKey method should return the key value
		 *
		 */
		[Test]
		public function shouldReturnKeyOnGetLocalizationForInexistantKey():void
		{
			// Given the Catalog class with a translation on it (for activeLocale)
			var key:String = 'key.inexistant';
			// When a the localization is get with a key
			var result:String = Catalog.getLocalizationForKey(key);
			
			// Then the key and translation are defined for the given Locale
			Assert.assertEquals("Incorrect value for key translation", result, key);
		}
	}
}