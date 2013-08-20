package org.openscales.core.filter
{
	
	/**
	 * A comparison operator is used to form expressions that evaluate 
	 * the mathematical comparison between two arguments. 
	 * If the arguments satisfy the comparison then the expression evaluates to TRUE. 
	 * Otherwise the expression evaluates to FALSE.
	 */ 
	
	
	
	public class Comparison
	{
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
		public static var NULL:String = "PropertyIsNull";
		public static var BETWEEN:String = "PropertyIsBetween";
		public static var WITHIN:String = "Within";
		
		
	}
}