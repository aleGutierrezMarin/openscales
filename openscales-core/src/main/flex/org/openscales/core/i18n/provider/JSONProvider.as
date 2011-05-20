package org.openscales.core.i18n.provider
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import org.openscales.core.Trace;
	import org.openscales.core.i18n.Catalog;
	import org.openscales.core.i18n.Locale;

	public class JSONProvider implements ILocaleProvider
	{
		public function JSONProvider(locale:Locale, jsonSource:Class){
			
			try {
				var text:String = new jsonSource();
				var obj:Object = JSON.decode(text) as Object;
				var value:String = null;
				for (var key:String in obj) {
					value = obj[key];
					if(value)
						Catalog.setLocalizationForKey(locale,key,value);
				}
			} catch (e:Error) {
				
			}
		}
		

	}
}