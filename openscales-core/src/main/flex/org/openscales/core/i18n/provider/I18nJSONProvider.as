package org.openscales.core.i18n.provider
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	
	import org.openscales.core.Trace;
	import org.openscales.core.i18n.Catalog;
	import org.openscales.core.i18n.Locale;

	public class I18nJSONProvider implements Ii18nProvider
	{
		public function I18nJSONProvider(){
		}
		
		/**
		 * add a translation based on a json file.
		 * it should at least includes the three following keys:
		 *   - locale.key
         *   - locale.localeName
         *   - locale.localizedName
		 * 
		 * @param jsonSource a class representing the JSON file to parse
		 */
		static public function addTranslation(jsonSource:Class):void {
			try {
				var text:String = new jsonSource();
				var obj:Object = JSON.decode(text) as Object;
				if(!obj["locale.key"]
					|| obj["locale.key"] == ''
					|| !obj["locale.name"]
					|| obj["locale.name"] == ''
					|| !obj["locale.localizedName"]
					|| obj["locale.localizedName"] == ''
				)
					return;
				var locale:Locale = Locale.genLocale(obj["locale.key"] as String,
													 obj["locale.name"] as String,
													 obj["locale.localizedName"] as String);
				var value:String = null;
				for (var key:String in obj) {
					value = obj[key];
					if(value
					   && value != "locale.key"
					   && value != "locale.name"
					   && value != "locale.localizedName")
						Catalog.setLocalizationForKey(locale,key,value);
				}
			} catch (e:Error) {
				Trace.debug("invalid json");
			}
		}
	}
}