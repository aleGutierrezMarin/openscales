package org.openscales.core.format
{
	
	import org.openscales.core.filter.Comparison;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;
	public class FilterEncodingFormat extends Format
	{
	
		
		protected var _ogcprefix:String = "ogc";
		protected var _ogcns:String = "http://www.opengis.net/ogc";


		public function FilterEncodingFormat()
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
		
		public function getRootFilter():XML
		{
			var filterNode:XML = new XML("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"     +
				"<" + this._ogcprefix + ":Filter xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\"></" + this._ogcprefix + ":Filter>");
			return filterNode;
		}
	
		 public function addComparisonFilter(parentNode:XML, PropertyType:String,PropertyName:String,LiteralValue:String):XML{
			/* var filterNode:XML = new XML("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"     +
				 "<" + this._ogcprefix + ":Filter xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\"></" + this._ogcprefix + ":Filter>");*/
			 var and:XML = new XML(
				 "<" + this._ogcprefix + ":And xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\"></" + this._ogcprefix + ":And>");
			 switch (PropertyType) {
				 case Comparison.EQUAL_TO:
					 and.appendChild(this.equalTo(PropertyName,LiteralValue));
					 break;
				 case Comparison.NOT_EQUAL_TO:
					 and.appendChild(this.notEqualTo(PropertyName,LiteralValue));
					 break;
				 case Comparison.LESS_THAN:
					 and.appendChild(this.lessThan(PropertyName,LiteralValue));
					 break;
				 case Comparison.GREATER_THAN:
					 and.appendChild(this.greaterThan(PropertyName,LiteralValue));
					 break;
					 }
			 parentNode.appendChild(and);
			 return parentNode;
		 }
		 
	     public function filterWithBbox(filter:XML,geom:String,bboxNodeGml:XML):XML{
			var filterWith:XML = filter.copy();
			filterWith.children()[0] = this.bbox(filterWith.children()[0], geom, bboxNodeGml);
			 return  filterWith;
		 }
		 /**
		  * Generate a propertyType @Comparison.EQUAL_TO xmlNode
		  *
		  * @param PropertyName:String
		  * @param LiteralValue:String
		  */
		 public function equalTo(PropertyName:String,LiteralValue:String):XML {
			 var equalNode:XML = new XML("<" + this._ogcprefix + ":PropertyIsEqualTo xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\">" +				
				 "</" + this._ogcprefix + ":PropertyIsEqualTo>");
			
			 equalNode.appendChild(this.propertyName(PropertyName));
			 equalNode.appendChild(this.literalValue(LiteralValue));
			 return equalNode;
		 }
		 
		 /**
		  * Generate a propertyType @Comparison.EQUAL_TO xmlNode
		  *
		  * @param PropertyName:String
		  * @param LiteralValue:String
		  */
		 public function within(PropertyName:String,gml:XML):XML {
			 var equalNode:XML = new XML("<" + this._ogcprefix + ":Within xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\">" +				
				 "</" + this._ogcprefix + ":Within>");
			 
			 equalNode.appendChild(this.propertyName(PropertyName));
			 equalNode.appendChild(gml);
			 return equalNode;
		 }
		 
		 public function bbox(parentNode:XML, PropertyName:String,gml:XML):XML {
			/* var filterNode:XML = new XML("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"     +
				 "<" + this._ogcprefix + ":Filter xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\">"+
				 "</" + this._ogcprefix + ":Filter>");*/
			 
			 var equalNode:XML = new XML("<" + this._ogcprefix + ":BBOX xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\">" +				
				 "</" + this._ogcprefix + ":BBOX>");
			 
			 equalNode.appendChild(this.propertyName(PropertyName));
			 equalNode.appendChild(gml);
			 parentNode.appendChild(equalNode);
			 return parentNode;
		 }
		 
		 public function getBbox(bounds:Bounds):XML {
			 
			 var bboxNode:XML = new XML("<" + this._ogcprefix + ":BBOX xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\">" +				
				 "</" + this._ogcprefix + ":BBOX>");
			 var propertyName:XML = new XML("<"+ this._ogcprefix +":PropertyName xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\">"+"ows:BoundingBox"+"</"+this._ogcprefix+":PropertyName>");
			 bboxNode.appendChild(propertyName);
			 var envelope:XML = new XML("<gml:Envelope xmlns:gml=\"http://www.opengis.net/gml\"></gml:Envelope>") 
			 bboxNode.appendChild(envelope);
			 var lowercorner:XML = new XML("<gml:lowerCorner xmlns:gml=\"http://www.opengis.net/gml\">"+ bounds.left +" "+ bounds.bottom +"</gml:lowerCorner>");
			 var upperCorner:XML = new XML("<gml:upperCorner xmlns:gml=\"http://www.opengis.net/gml\">"+ bounds.right +" "+ bounds.top +"</gml:upperCorner>");
			 envelope.appendChild(lowercorner);
			 envelope.appendChild(upperCorner);
			 return bboxNode;
		 }
		 
		 
		 /**
		  * Generate a propertyType @Comparison.NOT_EQUAL_TO xmlNode
		  *
		  * @param PropertyName:String
		  * @param LiteralValue:String
		  */
		 public function notEqualTo(PropertyName:String,LiteralValue:String):XML {
			 var notEqualNode:XML = new XML("<" + this._ogcprefix + ":PropertyIsNotEqualTo xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\">" +				
				 "</" + this._ogcprefix + ":PropertyIsNotEqualTo>");
			 
			 notEqualNode.appendChild(this.propertyName(PropertyName));
			 notEqualNode.appendChild(this.literalValue(LiteralValue));
			 return notEqualNode;
		 }
		 
		 /**
		  * Generate a propertyType @Comparison.LESS_THAN xmlNode
		  *
		  * @param PropertyName:String
		  * @param LiteralValue:String
		  */
		 public function lessThan(PropertyName:String,LiteralValue:String):XML {
			 var lessThanNode:XML = new XML("<" + this._ogcprefix + ":PropertyIsLessThan xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\">" +				
				 "</" + this._ogcprefix + ":PropertyIsLessThan>");
			 
			 
			 lessThanNode.appendChild(this.propertyName(PropertyName));
			 lessThanNode.appendChild(this.literalValue(LiteralValue));
			 
			 return lessThanNode;
		 }
		 
		 /**
		 * Generate a and node and return it
		 */
		 public function getAnd():XML
		 {
			 var and:XML = new XML(
				 "<" + this._ogcprefix + ":And xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\"></" + this._ogcprefix + ":And>");
		 	return and;
		 }
		 
		 /**
		  * Generate a Or node and return it
		  */
		 public function getOr():XML
		 {
			 var or:XML = new XML(
				 "<" + this._ogcprefix + ":Or xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\"></" + this._ogcprefix + ":Or>");
			 return or;
		 }
		 
		 /**
		 * Generate a islike node with the propertyName and return it
		 */
		 public function getIslikeNode(propertyName:String, literalValue:String, wildCard:String ="%", singleChar:String="_", escapeChar:String="\\"):XML{
			 var islike:XML = new XML("<" + this._ogcprefix + ":PropertyIsLike xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\">" +				
				 "</" + this._ogcprefix + ":PropertyIsLike>");
			 islike.@wildCard = wildCard;
			 islike.@singleChar = singleChar;
			 islike.@escapeChar = escapeChar;
			 islike.appendChild(this.propertyName(propertyName));
			 islike.appendChild(this.literalValue(literalValue));
			 return islike;
		 }
		 
		 /**
		  * Generate a propertyType @Comparison.GREATER_THAN xmlNode
		  *
		  * @param PropertyName:String
		  * @param LiteralValue:String
		  */
		 public function greaterThan(PropertyName:String,LiteralValue:String):XML {
			 var greaterThanNode:XML = new XML("<" + this._ogcprefix + ":PropertyIsGreaterThan xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\">" +				
				 "</" + this._ogcprefix + ":PropertyIsGreaterThan>");
			 greaterThanNode.appendChild(this.propertyName(PropertyName));
			 greaterThanNode.appendChild(this.literalValue(LiteralValue));
			 
			 return greaterThanNode;
		 }
		 /**
		  * Generate a filter params xmlNode
		  *
		  * @param PropertyName:String
		  * @param LiteralValue:String
		  */
		 public function propertyName(PropertyName:String):XML {
			 var propertyNameNode:XML = new XML(
				 "<" + this._ogcprefix + ":PropertyName xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\">" +
				 PropertyName +
				 "</" + this._ogcprefix + ":PropertyName>")
			 return propertyNameNode;
		 }
		 
		 public function literalValue(LiteralValue:String):XML {
			 var literalValueNode:XML = new XML("<" + this._ogcprefix + ":Literal " +
				 " xmlns:" + this._ogcprefix + "=\"" + this._ogcns + "\" >" +
				 LiteralValue +
				 "</" + this._ogcprefix + ":Literal>");
			 return literalValueNode;
		 }
	}
}