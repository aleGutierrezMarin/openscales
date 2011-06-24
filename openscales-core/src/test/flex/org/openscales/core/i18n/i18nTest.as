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
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMS;
	
	/**
	 * This class tests the i18n mecanism (get a key in different languages and add keys)
	 * 
	 */ 
	
	public class i18nTest
	{
		
		private var _map:Map;
		
		private var _existingKey:String = "zoombar.state";
		private var _notExistingKey:String = "notexisting";

		
		[Before]
		public function prepareResource():void
		{
			this._map = new Map();
		}
		
		/**
		 * Test an existing key with the default system locale (french)
		 */
		[Test]
		public function testExistingValueWithSystemLocale():void
		{
			Locale.activeLocale= Locale.systemLocale;
			var test:String = Catalog.getLocalizationForKey(this._existingKey);
			
			assertEquals("Région",test);
		}
		
		/**
		 * Test an existing key with a manualy set locale
		 */
		[Test]
		public function testExistingValueWithSetLocale():void
		{
			Locale.activeLocale=Locale.getLocaleByKey("EN");
			var test:String = Catalog.getLocalizationForKey(this._existingKey);
			
			assertEquals("State",test);
		}
		
		/**
		 * Test an non-existing key
		 */
		[Test]
		public function testNonExistingKey():void
		{
			Locale.activeLocale=Locale.getLocaleByKey("EN");
			var test:String = Catalog.getLocalizationForKey(this._notExistingKey);
			
			assertEquals("notexisting",test);
		}
		
		
		/**
		 * Set a key in one language manually and test if it's set
		 */
		[Test]
		public function testAddOneKey():void
		{
			Locale.activeLocale= Locale.systemLocale;
			
			Catalog.setLocalizationForKey(Locale.getLocaleByKey("FR"),"NewKey","MyNewKey");
			
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
			hm.put(Locale.getLocaleByKey("FR"),"MyNewKeyFR");
			hm.put(Locale.getLocaleByKey("EN"),"MyNewKeyEN");
			
			Catalog.setLocalizationsForKey("NewKey",hm);
			
			Locale.activeLocale= Locale.systemLocale;
			var test:String = Catalog.getLocalizationForKey("NewKey");
			assertEquals("MyNewKeyFR",test);
			
			Locale.activeLocale= Locale.getLocaleByKey("EN");
			test = Catalog.getLocalizationForKey("NewKey");
			assertEquals("MyNewKeyEN",test);
		}
		
		/**
		 * Set multiple keys in more than one language manually and test if it's set
		 */
		[Test]
		public function testAddMultipleKeysMultipleLocales():void
		{
			
			
			var hm1:HashMap = new HashMap();
			hm1.put(Locale.getLocaleByKey("FR"),"MyNewKeyFR");
			hm1.put(Locale.getLocaleByKey("EN"),"MyNewKeyEN");
			
			var hm2:HashMap = new HashMap();
			hm2.put(Locale.getLocaleByKey("FR"),"MySecondKeyFR");
			hm2.put(Locale.getLocaleByKey("EN"),"MySecondKeyEN");
			
			var hm:HashMap = new HashMap();
			hm.put("NewKey",hm1);
			hm.put("SecondKey",hm2);
			
			Catalog.setLocalizationsForKeys(hm);
			
			Locale.activeLocale= Locale.systemLocale;
			var test:String = Catalog.getLocalizationForKey("NewKey");
			assertEquals("MyNewKeyFR",test);
			test = Catalog.getLocalizationForKey("SecondKey");
			assertEquals("MySecondKeyFR",test);
			
			Locale.activeLocale= Locale.getLocaleByKey("EN");
			test = Catalog.getLocalizationForKey("NewKey");
			assertEquals("MyNewKeyEN",test);
			test = Catalog.getLocalizationForKey("SecondKey");
			assertEquals("MySecondKeyEN",test);
		}
	}
}