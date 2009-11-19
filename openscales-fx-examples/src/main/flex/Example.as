package
{
	import mx.containers.Canvas;
	
	import org.openscales.core.Map;

	/**
	 * Abstract example classes used to put common example elements
	 */
	public class Example extends Canvas
	{
		public function Example()
		{
			super();
		}
		
		[Bindable] protected var map:Map = null;
		
		[Bindable] private var _displayTrace:Boolean = true;
		
		[Bindable] private var _displayFirebugTrace:Boolean = true;
		
		[Bindable]
		public function get displayTrace():Boolean {
			return _displayTrace;
		}
		public function set displayTrace(value:Boolean):void {
			_displayTrace = value;
		}
		
		[Bindable]
		public function get displayFirebugTrace():Boolean {
			return _displayFirebugTrace;
		}
		public function set displayFirebugTrace(value:Boolean):void {
			_displayFirebugTrace = value;
		}
		
	}
}