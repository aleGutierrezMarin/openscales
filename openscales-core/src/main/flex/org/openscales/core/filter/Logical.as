package org.openscales.core.filter
{
	import org.openscales.core.feature.Feature;
	
	public class Logical implements IFilter
	{
		public static var AND:String = "AND";
		public static var OR:String = "OR";
		public static var NOT:String = "NOT";
		
		private var _filters:Vector.<IFilter>;
		private var _type:String;
		
		public function Logical(type:String, filters:Vector.<IFilter>)
		{
			this._type = type;
			this._filters = filters;
		}
		
		public function matches(feature:Feature):Boolean
		{
			if(!this.filters||this.filters.length==0)
				return false;
			
			var i:uint, len:uint;
			switch(this.type) {
				case AND:
					for (i=0, len=this.filters.length; i<len; i++) {
						if (this.filters[i].matches(feature) == false) {
							return false;
						}
					}
					return true;
					
				case OR:
					for (i=0, len=this.filters.length; i<len; i++) {
						if (this.filters[i].matches(feature) == true) {
							return true;
						}
					}
					return false;
					
				case NOT:
					for (i=0, len=this.filters.length; i<len; i++) {
						if (this.filters[i].matches(feature)) {
							return false;
						}
					}
					return true;
			}
			return false;
		}
		
		public function clone():IFilter
		{
			//TODO
			return null;
		}
		
		public function get sld():String
		{
			//TODO
			return null;
		}
		
		public function set sld(sld:String):void
		{
			//TODO
		}

		/**
		 * type of logical operator.
		 */
		public function get type():String
		{
			return _type;
		}

		/**
		 * @private
		 */
		public function set type(value:String):void
		{
			_type = value;
		}

		/**
		 * Child filters for this filter.
		 */
		public function get filters():Vector.<IFilter>
		{
			return _filters;
		}

		/**
		 * @private
		 */
		public function set filters(value:Vector.<IFilter>):void
		{
			_filters = value;
		}


	}
}