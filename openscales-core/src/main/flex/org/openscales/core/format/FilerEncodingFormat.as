package org.openscales.core.format
{
	import org.openscales.core.Trace;
	import org.openscales.core.filter.Comparison;
	import org.openscales.core.layer.ogc.WFS;

	public class FilerEncodingFormat extends Format
	{
	
		
		protected var _ogcprefix:String = "ogc";
		protected var _ogcns:String = "http://www.opengis.net/ogc";


		public function FilerEncodingFormat()
		{
			super();
		}
		
		
		override public function read(data:Object):Object {
			Trace.warn("Read not implemented.");
			return null;
		}
		
		override public function write(features:Object):Object {
			Trace.warn("Write not implemented.");
			return null;
		}
	
		 public function addComparisonFilter(PropertyType:String,PropertyName:String,LiteralValue:String):XML{
			 var filterNode:XML = new XML("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"     +
				 "<" + this._ogcprefix + ":Filter xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\">"+
				 "</" + this._ogcprefix + ":Filter>");
			 switch (PropertyType) {
				 case Comparison.EQUAL_TO:
					 filterNode.appendChild(this.equalTo(PropertyName,LiteralValue));
					 break;
				 case Comparison.NOT_EQUAL_TO:
					 filterNode.appendChild(this.notEqualTo(PropertyName,LiteralValue));
					 break;
				 case Comparison.LESS_THAN:
					 filterNode.appendChild(this.lessThan(PropertyName,LiteralValue));
					 break;
				 case Comparison.GREATER_THAN:
					 filterNode.appendChild(this.greaterThan(PropertyName,LiteralValue));
					 break;
			 }
			 return filterNode;
		 }
	
		 /**
		  * Generate a propertyType @Comparison.EQUAL_TO xmlNode
		  *
		  * @param PropertyName:String
		  * @param LiteralValue:String
		  */
		 public function equalTo(PropertyName:String,LiteralValue:String):XML {
			 var equalNode:XML = new XML("<" + this._ogcprefix + ":PropertyIsEqualTo>" +				
				 "</" + this._ogcprefix + ":PropertyIsEqualTo>");
			
			 equalNode.appendChild(this.filterParams(PropertyName,LiteralValue));
			 return equalNode;
		 }
		 
		 /**
		  * Generate a propertyType @Comparison.NOT_EQUAL_TO xmlNode
		  *
		  * @param PropertyName:String
		  * @param LiteralValue:String
		  */
		 public function notEqualTo(PropertyName:String,LiteralValue:String):XML {
			 var notEqualNode:XML = new XML("<" + this._ogcprefix + ":PropertyIsNotEqualTo>" +				
				 "</" + this._ogcprefix + ":PropertyIsNotEqualTo>");
			 
			 notEqualNode.appendChild(this.filterParams(PropertyName,LiteralValue));
			 return notEqualNode;
		 }
		 
		 /**
		  * Generate a propertyType @Comparison.LESS_THAN xmlNode
		  *
		  * @param PropertyName:String
		  * @param LiteralValue:String
		  */
		 public function lessThan(PropertyName:String,LiteralValue:String):XML {
			 var lessThanNode:XML = new XML("<" + this._ogcprefix + ":PropertyIsLessThan>" +				
				 "</" + this._ogcprefix + ":PropertyIsLessThan>");
			 
			 lessThanNode.appendChild(this.filterParams(PropertyName,LiteralValue));
			 return lessThanNode;
		 }
		 
		 /**
		  * Generate a propertyType @Comparison.GREATER_THAN xmlNode
		  *
		  * @param PropertyName:String
		  * @param LiteralValue:String
		  */
		 public function greaterThan(PropertyName:String,LiteralValue:String):XML {
			 var greaterThanNode:XML = new XML("<" + this._ogcprefix + ":PropertyIsGreaterThan>" +				
				 "</" + this._ogcprefix + ":PropertyIsGreaterThan>");
			 
			 greaterThanNode.appendChild(this.filterParams(PropertyName,LiteralValue));
			 return greaterThanNode;
		 }
		 /**
		  * Generate a filter params xmlNode
		  *
		  * @param PropertyName:String
		  * @param LiteralValue:String
		  */
		 public function filterParams(PropertyName:String,LiteralValue:String):XML {
			 var filterParamsNode:XML = new XML(
				 "<" + this._ogcprefix + ":PropertyName>" +
				 PropertyName +
				 "</" + this._ogcprefix + ":PropertyName>"+
				 "<" + this._ogcprefix + ":Literal>" +
				 LiteralValue +
				 "</" + this._ogcprefix + ":Literal>");
			 return filterParamsNode;
		 }
	}
}