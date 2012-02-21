package org.openscales.core.request.csw
{
	import org.openscales.core.request.XMLRequest;
	
	public class GetRecordsById extends XMLRequest
	{
		public function GetRecordsById(url:String, onComplete:Function, onFailure:Function=null, method:String=null)
		{
			super(url, onComplete, onFailure, method);
		}
	}
}