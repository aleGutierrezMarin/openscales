package org.openscales.core.i18n
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.i18n.Catalog;
	import org.openscales.core.i18n.Locale;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMS;
	
	/**
	 * This class tests the i18n mecanism (get a key in different languages and add keys)
	 * 
	 */ 
	
	public class i18nTest
	{
		
		private var _map:Map = new Map();
		
		private var _existingKey:String = "zoombar.state";
		private var _notExistingKey:String = "notexisting";
		
		private var _locale:Locale = Locale.getLocaleByKey("EN");
		private var _frenchLocale:Locale = Locale.getLocaleByKey("FR");

		public function i18nTest() {}
		
		[Before]
		public function prepareResource():void
		{
			Locale.activeLocale = _locale;
		}
		
		/**
		 * Test an existing key with a manualy set locale
		 */
		[Test]
		public function testExistingValueWithSetLocale():void
		{
			Locale.activeLocale = _locale;
			var test:String = Catalog.getLocalizationForKey(this._existingKey);
			
			assertEquals("State",test);
		}
		
		/**
		 * Test an non-existing key
		 */
		[Test]
		public function testNonExistingKey():void
		{
			Locale.activeLocale = _locale;
			var test:String = Catalog.getLocalizationForKey(this._notExistingKey);
			
			assertEquals("notexisting",test);
		}
		
		
		/**
		 * Set a key in one language manually and test if it's set
		 */
		[Test]
		public function testAddOneKey():void
		{
			Locale.activeLocale = _locale;
			
			Catalog.setLocalizationForKey(_locale,"NewKey","MyNewKey");
			
			var test:String = Catalog.getLocalizationForKey("NewKey");
			
			assertEquals("MyNewKey",test);
		}
		
		/**
		 * Set a key in more than one language manually and test if it's set
		 */
		[Test]
		public function testAddOneKeyMultipleLocales():void
		{
			var hm:HashMap = new HashMap();
			hm.put(_locale,"MyNewKeyEN");
			hm.put(_frenchLocale,"MyNewKeyFR");
			
			
			Catalog.setLocalizationsForKey("NewKey",hm);
			
			Locale.activeLocale = _locale;
			var test:String = Catalog.getLocalizationForKey("NewKey");
			assertEquals("MyNewKeyEN",test);
			
			Locale.activeLocale = _frenchLocale;
			test = Catalog.getLocalizationForKey("NewKey");
			assertEquals("MyNewKeyFR",test);
		}
		
		/**
		 * Set multiple keys in more than one language manually and test if it's set
		 */
		[Test]
		public function testAddMultipleKeysMultipleLocales():void
		{
			
			
			var hm1:HashMap = new HashMap();
			hm1.put(_locale,"MyNewKeyEN");
			hm1.put(_frenchLocale,"MyNewKeyFR");
			
			
			var hm2:HashMap = new HashMap();
			hm2.put(_locale,"MySecondKeyEN");
			hm2.put(_frenchLocale,"MySecondKeyFR");
			
			var hm:HashMap = new HashMap();
			hm.put("NewKey",hm1);
			hm.put("SecondKey",hm2);
			
			Catalog.setLocalizationsForKeys(hm);
			
			Locale.activeLocale = _locale;
			test = Catalog.getLocalizationForKey("NewKey");
			assertEquals("MyNewKeyEN",test);
			test = Catalog.getLocalizationForKey("SecondKey");
			assertEquals("MySecondKeyEN",test);
			
			Locale.activeLocale = _frenchLocale;
			var test:String = Catalog.getLocalizationForKey("NewKey");
			assertEquals("MyNewKeyFR",test);
			test = Catalog.getLocalizationForKey("SecondKey");
			assertEquals("MySecondKeyFR",test);
			
		}
	}
}