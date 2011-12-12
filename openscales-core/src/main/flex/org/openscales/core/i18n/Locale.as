package org.openscales.core.i18n
{
	import flash.system.Capabilities;
	
	import org.openscales.core.basetypes.maps.HashMap;
	
	/**
	 * This class defines the available languages for components in OS.
	 * It should not be instanciated directly. The class is a singleton
	 * 
	 * @example The following code explains how to add a vector of components :
	 * 
	 * <listing version="3.0">
	 * 
	 *  var om = Locale.genLocale("fr","French","Français")
	 * 
	 * </listing>
	 * 
	 * @author javocale
	 */
	public class Locale
	{
		/**
		 * Default locale to use
		 */
		static public var DEFAULT_LOCALE_CODE:String = "en";

		
		static private var KNOWNLOCALES:HashMap = new HashMap();
		static private var _activeLocale : Locale;
		static private var _systemLocale : Locale;
		
		
		private var _localeKey : String;
		private var _localeName : String;
		private var _localizedName : String;
		
		/**
		 * Known supported flash locales
		 */
		static private var _flashLocales:Object = {
			"en":new Array("English","English"),
			"es":new Array("Spanish","Español"),
			"fr":new Array("French","Français"),
			"de":new Array("German","Deutsch"),
			"pt":new Array("Portuguese","Português"),
			"nl":new Array("Dutch","Nederlandse"),
			"cs":new Array("Czech","České"),
			"da":new Array("Danish","Danske"),
			"fi":new Array("Finnish","Suomalainen"),
			"hu":new Array("Hungarian","Magyar"),
			"it":new Array("Italian","Italiano"),
			"ja":new Array("Japanese","Japanese"),
			"ko":new Array("Korean","Korean"),
			"no":new Array("Norwegian","Norske"),
			"pl":new Array("Polish","Polska"),
			"ru":new Array("Russian","Россию"),
			"zh-cn":new Array("Chinese","Chinese"),
			"sv":new Array("Swedish","Svenska"),
			"zh-tw": new Array("Chinese","Chinese"),
			"tr": new Array("Turkish","Türk")
		};
		
		/**
		 * Constructor
		 * 
		 * Should not be used directly
		 */
		public function Locale(localeKey:String, localeName:String, localizedName:String)
		{
			this._localeKey=localeKey.toLowerCase();
			this._localeName=localeName;
			this._localizedName=localizedName;
			if(!Locale.KNOWNLOCALES.containsKey(localeKey))
				Locale.KNOWNLOCALES.put(localeKey,this);
		}
		
		/**
		 * Generate a locale object
		 * 
		 * @Param localeKey the locale key code
		 * @Param localeName the locale name in english
		 * @Param localizedName the locale name in the corresponding language
		 * 
		 * @Return a locale object if the localeKey is valid else null
		 */
		static public function genLocale(localeKey:String, localeName:String, localizedName:String):Locale {
			
			if(!localeKey || localeKey=="")
				return null;
			
			var locale:Locale = Locale.KNOWNLOCALES.getValue(localeKey.toLowerCase()) as Locale;
			if(!locale){
				locale = new Locale(localeKey.toLowerCase(),localeName,localizedName);
				Locale.KNOWNLOCALES.put(locale.localeKey,locale);
			}
			
			return locale;
		}
		
		/**
		 * return the locale corresponding to the specified key
		 * 
		 * @param localKey the locale key code
		 * 
		 * @return the corresponding locale
		 */
		static public function getLocaleByKey(localeKey:String):Locale {
			if(!localeKey)
				return null;
			var locale:Locale = Locale.KNOWNLOCALES.getValue(localeKey.toLowerCase()) as Locale;
			if(!locale && Locale._flashLocales[localeKey.toLowerCase()])
				locale = Locale.genLocale(localeKey.toLowerCase(),
					Locale._flashLocales[localeKey.toLowerCase()][0],
					Locale._flashLocales[localeKey.toLowerCase()][1]);
			return locale;
		}
		
		/**
		 * Indicates the active locale
		 */
		static public function get activeLocale():Locale {
			if(!Locale._activeLocale) {
				Locale._activeLocale = Locale.systemLocale;
			}
			return Locale._activeLocale;
		}
		/**
		 * @Private
		 */
		static public function set activeLocale(value:Locale):void {
			if(!value || !value.localeKey || value.localeKey=="")
				return;
			
			if(!Locale.getLocaleByKey(value.localeKey)) {
				
			}
			Locale._activeLocale = value;
		}
		
		/**
		 * Indicates the locale of the system
		 */
		static public function get systemLocale():Locale {
			if(!Locale._systemLocale){
				var localeKey:String = Capabilities.language.toLowerCase();
				var locale:Locale = Locale.getLocaleByKey(localeKey);
				if(!locale)
					locale = Locale.getLocaleByKey(Locale.DEFAULT_LOCALE_CODE);
				Locale._systemLocale = locale;
			}
			return Locale._systemLocale;
		}
		
		/**
		 * Indicates the locale key code
		 */
		public function get localeKey():String {
			return this._localeKey;
		}
		/**
		 * Indicates the locale name in english
		 */
		public function get localeName():String
		{
			return _localeName;
		}
		/**
		 * Indicates the locale name in the corresponding language
		 */
		public function get localizedName():String
		{
			return _localizedName;
		}

		
	}
}