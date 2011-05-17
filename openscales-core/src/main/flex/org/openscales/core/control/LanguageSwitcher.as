package org.openscales.core.control
{
	import flash.events.Event;
	
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
		private var _languageList:Vector.<String>;
		
		/**
		 * Temporary variable
		 */
		private var _toRemoveMapLanguage:String = "French";
		
		
		/**
		 * LanguageSwitcher constructor
		 * 
		 */
		public function LanguageSwitcher(position:Pixel = null)
		{
			super(position);
			this._languageList = new Vector.<String>();
			this._languageList = getLanguageInformations();			
		}
		
		/**
		 * @private
		 * Return the languages informations in a Vector with the String name of the Language
		 * 
		 * TODO : To link with the service that will provide languages informations
		 */
		private function getLanguageInformations():Vector.<String>
		{
			var languages:Vector.<String> = new Vector.<String>();
			languages.push("French","English","Japanese");
			return languages;
		}
		
		/**
		 * @private
		 * Callback to actualize the language information when the langage in the map has changed
		 * TODO : Listen to Events.
		 */
		private function onMapLanguageChange(event:Event):void
		{
			
		}
		

		/**
		 * The language is the one of the map
		 */
		public function set language(value:String):void
		{
			if (_languageList.indexOf(value) != -1)
			{
				this._toRemoveMapLanguage = value;
			}
		}
		
		/**
		 * @private
		 */
		public function get language():String
		{
			return this._toRemoveMapLanguage;
		}
		
		public function get languageList():Vector.<String>
		{
			return this._languageList;
		}
		
	}
}