package org.openscales.core.i18n
{
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import org.openscales.core.Map;
	import org.openscales.core.Trace;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.I18NEvent;
	import org.openscales.core.i18n.Catalog;
	import org.openscales.core.i18n.Locale;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMS;
	import org.osmf.events.TimeEvent;
	
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
		
		private var _timer:Timer = null;
		private const THICK_TIME:uint = 5000;
		private var _handler:Function = null;
		
		
		public function i18nTest() {}
		
		[Before]
		public function prepareResource():void
		{
			Locale.activeLocale = _locale;
			_timer = new Timer(THICK_TIME, 1);
		}
		
		[After]
		public function tearDown():void{
			if(this._handler!=null)
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, this._handler);
			_timer.stop();
			_timer=null;
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
		
		/**
		 * Validate that the Catalog dispatch an event LOCALE_ADDED when a new Locale is added on the catalog
		 */
		[Test(async)]
		public function testDispatchEventOnNewLocaleAdded():void
		{
			// Given a Catalog and a function linked to the LOCALE_ADDED event
			var catalog:Catalog = Catalog.catalog;
			
			catalog.addEventListener(I18NEvent.LOCALE_ADDED, this.onLocaleAdded);
			
			// When a new locale with translations is added
			this._handler = this.assertDispatchEventOnNewLocaleAdded;
			this._timer.addEventListener(TimerEvent.TIMER_COMPLETE, this._handler, false, 0, true );
			
			this._timer.start();
			
		}
		
		/**
		 * Then the function linked to the LOCALE_ADDED event is called
		 */
		private function onLocaleAdded(event:I18NEvent):void
		{
			// Then the function linked to the LOCALE_ADDED event is called
			if(this._timer)
			{
				this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE, this._handler);
				this._timer.stop();
				this._timer = null;
			}
		}
		
		private function assertDispatchEventOnNewLocaleAdded(event:TimeEvent = null, obj:Object = null):void
		{
			if(this._timer)
				fail("The LOCALE_ADDED event has not been dispatched");
		}
	}
}