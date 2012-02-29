package org.openscales.core.request.csw.getrecordbyid
{
	import org.openscales.core.request.XMLRequest;

	public class GetRecordByIdRequest202 extends XMLRequest
	{
		
		/**
		 * Service name used for the query
		 */
		private var _service:String = "CSW";
		
		/**
		 * Version number name used for the query
		 */
		private var _version:String = "2.0.2";
		
		public function GetRecordByIdRequest202(url:String, onComplete:Function, onFailure:Function=null, method:String=null)
		{
			super(url, onComplete, onFailure, method);
		}
		
		
		/**
		 * Method that will build the url according to the configuration
		 */
		public function buildQuery(recordId:String, elementSet:String = "brief"):void
		{
			this.url = this.url +"?service="+this._service+"&version="+this._version+"&request=GetRecordById&Id="+recordId+"&ElementSetName="+elementSet;
		}
	}
}