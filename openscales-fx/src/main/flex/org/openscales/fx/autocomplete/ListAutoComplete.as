package org.openscales.fx.autocomplete
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import spark.components.List;
	
	/**
	 * This list is used in AutoCompleteSkin.
	 * keyDownHandler is overridden so that the list can handle keyboard events for navigation.  
	 */	
	public class ListAutoComplete extends List
	{
		
		public function ListAutoComplete()
		{
			super();
			super.setStyle('horizontalScrollPolicy', 'ScrollPolicy.OFF');
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void {
			
			super.keyDownHandler(event);
			
			if (!dataProvider || !layout || event.isDefaultPrevented())
				return;
			
			adjustSelectionAndCaretUponNavigation(event); 
			
		}
	}
}