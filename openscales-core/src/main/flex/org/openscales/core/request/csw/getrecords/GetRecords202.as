package org.openscales.core.request.csw.getrecords
{
	import org.openscales.core.request.XMLRequest;
	
	public class GetRecords202 extends XMLRequest
	{
		
		/**
		 * Service name used for the query
		 */
		private var _service:String = "CSW";
		
		/**
		 * Version number name used for the query
		 */
		private var _version:String = "2.0.2";
		
		/**
		 * Result type used for the query
		 */
		private var _resultType:String = "results";
		
		/**
		 * Output format used for the query
		 */
		private var _outputFormat:String = "application/xml";
		
		/**
		 * Output schema used for the query
		 */
		private var _outputSchema:String = "http://www.opengis.net/cat/csw/2.0.2";
		
		/**
		 * Filter encoding version
		 */
		private var _filterEncodingVersion:String = "1.1.0";
		
		public function GetRecords202(url:String, onComplete:Function, onFailure:Function=null, method:String=null)
		{
			super(url, onComplete, onFailure, method);
		}
		
		
		/**
		 * Method that will build the post content according to the configuration
		 */
		public function buildQuery(filter:XML = null, startPosition:int = 0, maxRecords:int = 10, elementSet:String = "brief"):void
		{
			var post:XML = new XML("<GetRecords></GetRecords");
			post.@service = _service;
			post.@version = _version;
			post.@maxRecords = maxRecords;
			post.@startPosition = startPosition;
			post.@resultType = _resultType;
			post.@outputFormat = _outputFormat;
			post.@outputSchema = _outputSchema;
			
			var query:XML = new XML("<Query></Query>")
			query.@typeNames = "csw:Record";
			post.appendChild(query);
			
			
			var elementSetName:XML = new XML("<ElementSetName>"+elementSet+"</ElementSetName>")
			elementSetName.@typeNames = "";
			query.appendChild(elementSetName);
				
			 if (filter)
			 {
				var constraint:XML = new XML("<Constraint></Constraint>")
				constraint.@version = _filterEncodingVersion;
				query.appendChild(constraint);
				constraint.appendChild(filter);
			 }
			 
			 this.postContent = post;
			 this.postContentType = "application/xml";
		}
	}
}