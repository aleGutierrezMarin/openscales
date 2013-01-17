package org.openscales.core.control
{
	import flash.events.Event;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.I18NEvent;
	import org.openscales.core.i18n.Catalog;
	import org.openscales.core.i18n.Locale;
	import org.openscales.geometry.basetypes.Pixel;
	

	/**
	 * The language Switcher is a drop down list used to change the language of the application.
	 * This class is the ActionScript code that will control the Map.
	 * 
	 * This is a DropList UI component that show all the languages avaliables.
	 * You don't have to configure the LanguageSwitcher.
	 * It will retrieve the language information and display the availlable languages.
	 * 
	 * @author Maxime Viry
	 */
	public class LanguageSwitcher extends Control
	{
		
	
		/**
		 * @private
		 * Vector containing the languages to show in the drop down list
		 */
		private var _languageList:Vector.<Locale>;
		
		
		/**
		 * LanguageSwitcher constructor
		 * 
		 */
		public function LanguageSwitcher(position:Pixel = null)
		{
			super(position);
			this._languageList = new Vector.<Locale>();			
		}
		
		/**
		 * @private
		 * Callback to actualize the language information when the langage in the map has changed
		 * TODO : Listen to Events.
		 */
		override public function onMapLanguageChange(event:I18NEvent):void
		{
			
		}
		

		/**
		 * The language is the one of the map
		 */
		public function set language(value:String):void
		{
			if(!this.map)
				return;
			var locale:Locale = Locale.getLocaleByKey(value);
			if(locale) {
				this.map.locale = locale.localeKey;
			}
		}
		
		/**
		 * @private
		 */
		public function get language():String
		{
			if(!this.map)
				return null;
			return this.map.locale;
		}
		
		public function get languageList():Vector.<Locale>
		{
			return this._languageList;
		}
		
		override public function set map(value:Map):void {
			super.map = value;
			this._languageList = Catalog.getAvailableLocalizations();
		}
		
	}
}