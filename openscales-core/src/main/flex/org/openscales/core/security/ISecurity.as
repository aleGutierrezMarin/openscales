package org.openscales.core.security
{
	import flash.net.URLRequest;
	
	import org.openscales.core.request.AbstractRequest;

	/**
	 * Represent a security mecanism that will use remote services to authenticate and retreive a token.
	 * Secured layer will use the security parameter to request their data.
	 */
	public interface ISecurity
	{
		/**
		 * Intialize this security, and dispatch a SecurityEvent.SECURITY_INITIALIZED event
		 */
		function initialize():void;
		
		/**
		 * Return true if the security has been initilized, else false.
		 */
		function get initialized():Boolean;

		/**
		 * Update this security, and dispatch a SecurityEvent.SECURITY_UPDATED event
		 */
		function update():void;
		
		/**
		 * Logout and dispatch a SecurityEvent.SECURITY_LOGOUT event
		 */
		function logout():void;

		/**
		 * Return the string that will be appended to the request in order to make it autenticated
		 */
		function get securityParameter():String;

		/**
		 * Register/Remove waiting requests
		 */
		function addWaitingRequest(request:AbstractRequest):void;
		function removeWaitingRequest(request:AbstractRequest):void;
		
		/**
		 * destroy the security
		 */
		function destroy():void;
		
		/**
		 * Computes finalURL for a request 
		 */
		function getFinalUrl(baseUrl:String):String;
		
		
		/**
		 * This method allows to set special headers for a request
		 */
		function addCustomHeaders(urlRequest:URLRequest):URLRequest;
	}
}

