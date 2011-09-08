package org.openscales.core.popup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import org.openscales.core.Map;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import spark.components.VGroup;
	
	public class EditAttributes extends TitleWindow
	{
		
		/**
		 * Constructor
		 */
		public function EditAttributes(map:Map, attributes:Array, values:Array)
		{
			var vg:VGroup = new VGroup();
			var textArea:TextArea = new TextArea();
			
			// Define the popup properties
			this.x = map.width / 2;
			this.y = map.height / 2;
			this.height = 100;
			this.width = 200;
			this.title = "Attributes";
			this.addElement(vg);
			vg.addElement(textArea);
			
			// Register events
			this.addEventListener(CloseEvent.CLOSE, closeClick);
			
			//
			for(var i:uint = 0; i < attributes.length; i++){
				textArea.text += attributes[i] + ":" + values[i] + "\n";
			}
			
			// Display the popup
			PopUpManager.addPopUp(this, map, true);
		}
		
		public function closeClick(evt:Event):void
		{
			PopUpManager.removePopUp(this);
		}
	}
}