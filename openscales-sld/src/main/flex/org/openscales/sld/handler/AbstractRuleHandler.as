package org.openscales.sld.handler
{
	import org.openscales.sld.events.SLDEvent;
	
	import mx.core.UIComponent;
	
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.symbolizer.Symbolizer;
	
	import spark.components.Group;

	public class AbstractRuleHandler extends Group
	{
		private var _displayMode:String = null;
		private var _currentDisplayMode:String = null;
		private var _currentSymbolizer:Symbolizer = null;
		
		private var _canDisplay:Boolean = false;
		
		public function AbstractRuleHandler()
		{
			this.computeDiplay();
		}
		
		protected function computeDiplay():void {
			if(!this._currentDisplayMode || (this._displayMode && this._displayMode != this._currentDisplayMode)) {
				this.display = false;
				return;
			}
			if(this._currentSymbolizer && this.supportedSymbolizers) {
				for each(var type:Class in this.supportedSymbolizers){
					if(this._currentSymbolizer is type){
						this.display = true;
						return;
					}
				}
			}
			this.display = false;
		}
		
		public function get supportedSymbolizers():Vector.<Class> {
			return null;
		}

		protected function refresh(e:SLDEvent):void {
			this.currentSymbolizer = this.currentSymbolizer;
		}
		
		public function get displayMode():String
		{
			return _displayMode;
		}

		public function set displayMode(value:String):void
		{
			_displayMode = value;
		}

		[Bindable]
		public function get currentSymbolizer():Symbolizer
		{
			return _currentSymbolizer;
		}

		public function set currentSymbolizer(value:Symbolizer):void
		{
			if(this._currentSymbolizer) {
				this._currentSymbolizer.removeEventListener(SLDEvent.SYMBOLIZER_UPDATED,this.refresh);
			}
			this._currentSymbolizer = value;
			if(this._currentSymbolizer) {
				this.addEventListener(SLDEvent.SYMBOLIZER_UPDATED,this.refresh);
			}
			this.computeDiplay();
		}

		[Bindable]
		public function get display():Boolean
		{
			return _canDisplay;
		}

		public function set display(value:Boolean):void
		{
			_canDisplay = value;
		}

		[Bindable]
		public function get currentDisplayMode():String
		{
			return _currentDisplayMode;
		}

		public function set currentDisplayMode(value:String):void
		{
			_currentDisplayMode = value;
			this.computeDiplay();
		}


	}
}