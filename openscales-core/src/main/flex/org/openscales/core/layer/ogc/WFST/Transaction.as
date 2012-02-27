package org.openscales.core.layer.ogc.WFST
{
	import org.openscales.core.utils.UID;
	import org.openscales.core.feature.Feature;

	public class Transaction
	{
		/**
		 * to easy use the di of transation is the same that it feature;
		 * */
		private var _id:String;
		
		private var _type:String;
		
		private var _state:String;
		
		private var _feature:Feature;
		
		public static var SUCCESS:String = "sucess";
		public static var FAIL:String = "fail";
		public static var NOTSEND:String = "notsend";
		
		
		
		public function Transaction(type:String,feature:Feature)
		{
			_type = type;
			_id = feature.name;
			_feature = feature;
			
			/*if(id == null){
				_id =  generateIDTemp(type);
			}*/
			_state = NOTSEND;
		}
		
		public function get state():String
		{
			return _state;
		}

		public function set state(value:String):void
		{
			_state = value;
		}

		

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			_id = value;
		}

		public function get feature():Feature
		{
			return _feature;
		}

		public function set feature(value:Feature):void
		{
			_feature = value;
		}

		
	}
}