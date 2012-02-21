package org.openscales.core.request.csw
{
	import org.openscales.core.request.XMLRequest;
	
	public class GetRecordsByIdRequest extends XMLRequest
	{
		public function GetRecordsByIdRequest(url:String, onComplete:Function, onFailure:Function=null, method:String=null)
		{
			super(url, onComplete, onFailure, method);
		}
	}
}