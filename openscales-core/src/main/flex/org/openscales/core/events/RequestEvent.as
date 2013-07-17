package org.openscales.core.events
{
	import flash.events.Event;
	
	public class RequestEvent extends Event
	{
		private var _url:String = null;
		private var _target:Object = null;
		
		public function RequestEvent(type:String, url:String, target:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._url = url;
			this._target = target;
		}
		
		override public function clone():Event {
			return new RequestEvent(this.type,this.url,this.bubbles,this.cancelable);
		}

		public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			_url = value;
		}
		
		override public function get target():Object {
			return this._target;
		}

	}
}