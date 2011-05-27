package org.openscales.core.events
{
	import org.openscales.core.i18n.Locale;

	/**
	 * Event related to a layer.
	 */
	public class I18NEvent extends OpenScalesEvent
	{
		/**
		 * Layer concerned by the event.
		 */
		private var _locale:Locale = null;

		/**
		 * Event type dispatched when the locale is changed.
		 */ 
		public static const LOCALE_CHANGED:String="openscales.localeChanged";

		public function I18NEvent(type:String, locale:Locale, bubbles:Boolean=false,cancelable:Boolean=false)
		{
			this._locale = locale;
			super(type, bubbles, cancelable);
		}
		
		/**
		 * Layer concerned by the event.
		 */
		public function get locale():Locale {
			return this._locale;
		}
		public function set locale(value:Locale):void {
			this._locale = value;	
		}



	}
}

