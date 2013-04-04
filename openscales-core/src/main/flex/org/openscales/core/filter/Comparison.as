package org.openscales.core.filter
{
	import org.openscales.core.feature.Feature;
	
	/**
	 * A comparison operator is used to form expressions that evaluate 
	 * the mathematical comparison between two arguments. 
	 * If the arguments satisfy the comparison then the expression evaluates to TRUE. 
	 * Otherwise the expression evaluates to FALSE.
	 */ 
	
	
	
	public class Comparison implements IFilter
	{
		private namespace ogcns="http://www.opengis.net/ogc";
		/**
	      * PropertyType: type
	      * {String} type: type of the comparison. This is one of
	      * - @Comparison.EQUAL_TO                 = "==";
	      * - @Comparison.NOT_EQUAL_TO             = "!=";
	      * - @Comparison.LESS_THAN                = "<";
	      * - @Comparison.GREATER_THAN             = ">";
	      * - @Comparison.LESS_THAN_OR_EQUAL_TO    = "<=";
	      * - @Comparison.GREATER_THAN_OR_EQUAL_TO = ">=";
	      * - @Comparison.BETWEEN                  = "..";
	      * - @Comparison.LIKE                     = "~";
	      */
		
		public static var EQUAL_TO:String = "PropertyIsEqualTo";
		public static var NOT_EQUAL_TO:String = "PropertyIsNotEqualTo";
		public static var LESS_THAN:String = "PropertyIsLessThan";
		public static var GREATER_THAN:String = "PropertyIsGreaterThan";
		public static var LESS_THAN_OR_EQUAL_TO:String = "PropertyIsLessThanOrEqualTo";
		public static var GREATER_THAN_OR_EQUAL_TO:String = "PropertyIsGreaterThanOrEqualTo";
		public static var LIKE:String = "PropertyIsLike";
		public static var IS_NULL:String = "PropertyIsNull";
		public static var BETWEEN:String = "PropertyIsBetween";
		public static var WITHIN:String = "in";
		
		private var _type:String;
		
		private var _property:String;
		
		private var _value:Object = null;
		
		private var _matchCase:Boolean = true;
		
		private var _lowerBoundary:Object = null;

		private var _upperBoundary:Object = null;
		
		private var _wildCard:String = null;
		private var _singleChar:String = null;
		private var _escapeChar:String = null;
		
		public function Comparison(property:String, type:String) {
			this._property = property;
			this._type = type;
		}
		
		public function matches(feature:Feature):Boolean {
			var result:Boolean = false;
			var got:Object = feature.attributes[this.property];
			var exp:Object;
			switch(this.type) {
				case EQUAL_TO:
					exp = this.value;
					if(!this.matchCase &&
						got is String && exp is String) {
						result = (got.toUpperCase() == exp.toUpperCase());
					} else {
						result = (got == exp);
					}
					break;
				case NOT_EQUAL_TO:
					exp = this.value;
					if(!this.matchCase &&
						got is String && exp is String) {
						result = (got.toUpperCase() != exp.toUpperCase());
					} else {
						result = (got != exp);
					}
					break;
				case LESS_THAN:
					result = got < this.value;
					break;
				case GREATER_THAN:
					result = got > this.value;
					break;
				case LESS_THAN_OR_EQUAL_TO:
					result = got <= this.value;
					break;
				case GREATER_THAN_OR_EQUAL_TO:
					result = got >= this.value;
					break;
				case BETWEEN:
					result = (got >= this.lowerBoundary) &&
					(got <= this.upperBoundary);
					break;
				case LIKE:
					var value:String = this.value.toString();
					if(this._escapeChar) {
						value.replace("\\","\\\\");
						value.replace(this._escapeChar,"\\");
					}
					if(this._singleChar) {
						value.replace("?","\\?");
						value.replace(this._singleChar,"?");
					}
					if(this._wildCard) {
						value.replace("\.","\\.");
						value.replace(this._wildCard,"?");
					}
					var regexp:RegExp = new RegExp(value, "gi");
					result = regexp.test(got.toString());
					break;
				case IS_NULL:
					result = (got === null);
					break;
			}
			return result;
		}
		
		public function clone():IFilter {
			var res:Comparison = new Comparison(this._property,this._type);
			res._lowerBoundary = this._lowerBoundary;
			res._matchCase = this._matchCase;
			res._upperBoundary = this._upperBoundary;
			res._value = this._value;
			return res;
		}
		
		public function get sld():String {
			if(!this._type || !this._property)
				return "";
			var res:String = "<ogc:Filter>\n";
			res+= "<ogc:"+this._type;
			if(this._escapeChar == "\\")
				res+= " escapeChar=\"\\\"";
			else if(this._escapeChar)
				res+= " escapeChar=\""+this._escapeChar+"\"";
			
			if(this._wildCard == "\\")
				res+= " wildChar=\"\\\"";
			else if(this._wildCard)
				res+= " wildChar=\""+this._wildCard+"\"";
			
			if(this._singleChar == "\\")
				res+= " singleChar=\"\\\"";
			else if(this._singleChar)
				res+= " singleChar=\""+this._singleChar+"\"";
			
			res+=">\n";
			res+= "<ogc:PropertyName>"+this._property+"</ogc:PropertyName>\n";
			if(this._value)
				res+= "<ogc:Literal>"+this._value+"</ogc:Literal>\n";
			if(this._lowerBoundary)
				res+= "<ogc:LowerBoundary><ogc:Literal>"+this._lowerBoundary+"</ogc:Literal></ogc:LowerBoundary>\n";
			if(this._upperBoundary)
				res+= "<ogc:UpperBoundary><ogc:Literal>"+this._upperBoundary+"</ogc:Literal></ogc:UpperBoundary>\n";
			res+= "</ogc:"+this._type+">\n";
			res+= "</ogc:Filter>\n";
			return res;
		}
		public function set sld(sld:String):void {
			use namespace ogcns;
			this._type = null;
			this._property = null;
			this._value = null;
			this._matchCase = true;
			this._lowerBoundary = null;
			this._upperBoundary = null;
			this._wildCard = null;
			this._singleChar = null;
			this._escapeChar = null;
			
			var dataXML:XML = new XML(sld);
			var filter:XMLList = dataXML.children();
			if(filter.length()==0)
				return;
			dataXML = filter[0];
			this._type = dataXML.localName();
			
			var childs:XMLList = dataXML.PropertyName;
			if(childs.length()>0) {
				this._property = childs[0];
			}
			filter = dataXML.children();
			if("PropertyIsBetween" == this._type){
				if(filter.length()>2) {
					this._lowerBoundary = filter[1];
					this._upperBoundary = filter[2];
				}
			}
			else{
				if(filter.length()>1) {
					this._value = filter[1];
				}
			}
			//todo support isbetween and in
		}

		/**
		 * type of the comparison.
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
		 * name of the context property to compare
		 */
		public function get property():String
		{
			return _property;
		}
		
		/**
		 * @private
		 */
		public function set property(value:String):void
		{
			_property = value;
		}

		
		/**
		 * comparison value for binary comparisons. In the case of a String, this
		 * can be a combination of text and propertyNames in the form
		 * "literal ${propertyName}"
		 */
		/**
		 * name of the context property to compare
		 */
		public function get value():Object
		{
			return _value;
		}
		
		/**
		 * @private
		 */
		public function set value(value:Object):void
		{
			_value = value;
		}
		
		/**
		 * Force case sensitive searches for EQUAL_TO and NOT_EQUAL_TO
		 * comparisons.  The Filter Encoding 1.1 specification added a matchCase
		 * attribute to ogc:PropertyIsEqualTo and ogc:PropertyIsNotEqualTo
		 * elements.  This property will be serialized with those elements only
		 * if using the v1.1.0 filter format. However, when evaluating filters
		 * here, the matchCase property will always be respected (for EQUAL_TO
		 * and NOT_EQUAL_TO).  Default is true. 
		 */
		public function get matchCase():Boolean
		{
			return _matchCase;
		}

		/**
		 * @private
		 */
		public function set matchCase(value:Boolean):void
		{
			_matchCase = value;
		}

		/**
		 * Number or String
		 * lower boundary for between comparisons. In the case of a String, this
		 * can be a combination of text and propertyNames in the form
		 * "literal ${propertyName}"
		 */
		public function get lowerBoundary():Object
		{
			return _lowerBoundary;
		}
		
		/**
		 * @private
		 */
		public function set lowerBoundary(value:Object):void
		{
			_lowerBoundary = value;
		}
		
		/**
		 * {Number} or {String}
		 * upper boundary for between comparisons. In the case of a String, this
		 * can be a combination of text and propertyNames in the form
		 * "literal ${propertyName}"
		 */
		public function get upperBoundary():Object
		{
			return _upperBoundary;
		}
		
		/**
		 * @private
		 */
		public function set upperBoundary(value:Object):void
		{
			_upperBoundary = value;
		}
	}
}