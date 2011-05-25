package org.openscales.core.i18n
{
	import org.openscales.core.basetypes.maps.HashMap;

	/**
	 * This class represent an abstration to the Json files used to store the keys.
	 * The class is used to read and write association key - values.
	 * It should never be instanciated but used as a static class.
	 * 
	 * 
	 * @author javocale
	 */
	
	public class Catalog
	{
		static private var _hmCatalog:HashMap = new HashMap();
		
		public function Catalog()
		{
		}
		
		/**
		 * Insert a translation associated to a given locale and a given key
		 * 
		 * @param locale the locale to request
		 * @param key key to translate
		 * @param translation translation corresponding to the key
		 * 
		 */
		static public function setLocalizationForKey(locale:Locale, key:String, translation:String):void{
			var hmTmp:HashMap=null;
			//The language already exists, then replace its hashmap with the completed one
			if(_hmCatalog.containsKey(locale.localeKey)){
				hmTmp = _hmCatalog.getValue(locale.localeKey);
			}
			else{ // the language doesn't exist, create it and put the key value
				hmTmp = new HashMap();
				_hmCatalog.put(locale.localeKey, hmTmp);
			}
			hmTmp.put(key,translation);
		}
		
		
		/**
		 * Insert a translation associated to a given locale and a given key
		 */
		static public function setLocalizationsForKey(key:String, translations:HashMap):void{
			
			var locales:Array = translations.getKeys();
			var i:uint = locales.length;
			
			//iterate on each locale to add
			for(i;i>0;i--){
				var locale:Locale = locales[i-1] as Locale;
				Catalog.setLocalizationForKey(locale,key,translations.getValue(locale));
			}
			
		}
		
		/**
		 * Insert a translation associated to a given locale and a given key
		 */
		static public function setLocalizationsForKeys(hm:HashMap):void{
			var keys: Array = hm.getKeys();
			var i:uint = keys.length;
			
			//iterate on each key to add
			for(i;i>0;--i){
				var key:String = keys[i-1] as String;
				var hmTranslations: HashMap = hm.getValue(key);
				
				Catalog.setLocalizationsForKey(key,hmTranslations);
				
			}
		}
		
		/**
		 * Find the translation associated to a given locale and a given key
		 * 
		 * @param locale the locale to request
		 * @param key key to translate
		 * 
		 * @return the translation of the key in the requested locale
		 */
		static public function getLocalizationForLocaleAndKey(locale:Locale,key:String):String{
			var hmLanguage: HashMap = null;
			//try to find the key in the requested language
			if(_hmCatalog.containsKey(locale.localeKey)){
				hmLanguage = _hmCatalog.getValue(locale.localeKey);
				if(locale.localeKey != Locale.DEFAULT_LOCALE_CODE
					&& !hmLanguage.containsKey(key)) {
					hmLanguage = null;
				}
			}
			if(!hmLanguage && _hmCatalog.containsKey(Locale.DEFAULT_LOCALE_CODE)){
				hmLanguage = _hmCatalog.getValue(Locale.DEFAULT_LOCALE_CODE);
			}
			if(hmLanguage && hmLanguage.containsKey(key))
				return hmLanguage.getValue(key);
			//the key doesn't exist in the requested language nor the default language	
			return key;
		}
		
		/**
		 * Find the translation associated to a given key in the active locale
		 * 
		 * @param key key to translate
		 * 
		 * @return the translation of the key in the active locale
		 */
		static public function getLocalizationForKey(key:String):String{
			return Catalog.getLocalizationForLocaleAndKey(Locale.activeLocale,key);
		}
		
		static public function getAvailableLocalizations():Vector.<Locale> {
			var keys:Array = _hmCatalog.getKeys();
			var locales:Vector.<Locale> = new Vector.<Locale>();
			var locale:Locale;
			for(var key:String in keys) {
				locale = Locale.getLocaleByKey(keys[key]);
				if(locale)
					locales.push(locale);
			}
			return locales;
		}
	}
}