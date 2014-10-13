package org.openscales.core.utils
{
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	
	import org.openscales.core.events.TraceEvent;
	
	/**
	 * Class which allows to show trace messages in the classical flex logger
	 * but also in a flex component and in the firebug console if exists.
	 *
	 * To that goal, we have to use one of its static methods: log(), info(),
	 * warning(), error() or debug() instead of the trace native method.
	 * It does three things : call trace native method, dispatch a Trace event
	 * through the map in order to be able to catch it elsewhere, and display in
	 * the firebug console if exists.
	 *
	 * According to the trace level (info, warning, error or debug), the
	 * flex component will show it in a diffrent color.
	 * 
	 * More functionnalities are provided for the firebug console :
	 *  - fbConsole_startGroup(msg): start a group 
	 *  - fbConsole_endGroup(): end a group
	 *  - fbConsole_startTiming(msg): start a timer
	 *  - fbConsole_endTiming(msg): end a timer
	 */
	public class Trace
	{

		public static var useFireBugConsole:Boolean = false;
		
		private static var _stage:Stage = null; 

		public static function get stage():Stage {
			return _stage;
		}

		public static function set stage(value:Stage):void	{
			_stage = value;
		}

		
		/**
		 * Constructor
		 */
		public function Trace() {
			// Nothing to do
		}
		
		/**
		 * Display a log
		 */
		public static function log(text:String):void {
			if (_stage != null) {
				_stage.dispatchEvent(new TraceEvent(TraceEvent.LOG,text));					
			}
			fbConsoleLog(FB_LOG, text);
			trace(text);
		}
		
		/**
		 * Display an information
		 */
		public static function info(text:String):void {
			if (_stage != null) {
				_stage.dispatchEvent(new TraceEvent(TraceEvent.INFO,text));					
			}
			fbConsoleLog(FB_INFO, text);
			trace(text);
		}
		
		/**
		 * Display an warning
		 */
		public static function warn(text:String):void {
			if (_stage != null) {
				_stage.dispatchEvent(new TraceEvent(TraceEvent.WARNING,text));					
			}
			fbConsoleLog(FB_WARN, text);
			trace(text);
		}
		
		/**
		 * Display an error
		 */
		public static function error(text:String):void {
			if (_stage != null) {
				_stage.dispatchEvent(new TraceEvent(TraceEvent.ERROR,text));					
			}
			fbConsoleLog(FB_ERROR, text);
			trace(text);
		}
		
		/**
		 * Display a debug information
		 */
		public static function debug(text:String):void {
			if (_stage != null) {
				_stage.dispatchEvent(new TraceEvent(TraceEvent.DEBUG,text));					
			}
			fbConsoleLog(FB_DEBUG, text);
			trace(text);
		}
		
		
		// Firebug functionnalities
		
		// Available display modes for using the firebug console
		// See http://getfirebug.com/logging.html for more details
		private static const FB_LOG:String = "console.log";
		private static const FB_INFO:String = "console.info";
		private static const FB_WARN:String = "console.warn";
		private static const FB_ERROR:String = "console.error"; 
		private static const FB_DEBUG:String = "console.debug";
		
		/**
		 * Send a log to the Firebug console using the selected mode
		 */
		private static function fbConsoleLog(jsFunction:String, text:String) :void {
			if (useFireBugConsole && ExternalInterface.available) {
				ExternalInterface.call(jsFunction, text);
			}
		}
		
		/**
		 * Start a group in a firebug console
		 */
		public static function fbConsoleStartGroup(text:String):void {
			if (useFireBugConsole && ExternalInterface.available) {
				ExternalInterface.call("console.group", text);
			}
		}
		
		/**
		 * End a group in a firebug console
		 */
		public static function fbConsoleEndGroup():void {
			if (useFireBugConsole && ExternalInterface.available) {
				ExternalInterface.call("console.groupEnd");
			}
		}
		
		/**
		 * Start a timer in a firebug console
		 */
		public static function fbConsoleStartTiming(text:String):void {
			if (useFireBugConsole && ExternalInterface.available) {
				ExternalInterface.call("console.time", text);
			}
		}
		
		/**
		 * Stop and display the timer in a firebug console
		 */
		public static function fbConsoleEndTiming(text:String):void {
			if (useFireBugConsole && ExternalInterface.available) {
				ExternalInterface.call("console.timeEnd", text);
			}
		}
		
	}
}
