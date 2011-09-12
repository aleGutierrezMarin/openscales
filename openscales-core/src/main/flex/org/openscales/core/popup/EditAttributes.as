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
			var hGroup:HGroup = new HGroup();
			var vGroup1:VGroup = new VGroup();
			var vGroup2:VGroup = new VGroup();
			var lb:Label;
			
			// Define the popup properties
			this.x = map.width / 2;
			this.y = map.height / 2;
			this.height = 100;
			this.width = 200;
			this.title = "Edit attributes";
			this.addElement(hGroup);
			hGroup.addElement(vGroup1);
			hGroup.addElement(vGroup2);
			
			// Display the attributes
			for(var i:uint = 0; i < attributes.length; i++){
				lb = new Label();
				lb.text = attributes[i] + " : ";
				vGroup1.addElement(lb);
				lb = new Label();
				lb.text = values[i];
				vGroup2.addElement(lb);
			}
			
			// Register events
			this.addEventListener(CloseEvent.CLOSE, closeClick);
			
			// Display the popup
			PopUpManager.addPopUp(this, map, true);
		}
		
		/**
		 * This function is called when the close button is clicked
		 */
		public function closeClick(evt:Event):void
		{
			PopUpManager.removePopUp(this);
		}
	}
}