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
			var x:uint = map.width / 2;
			var y:uint = map.height / 2;
			this.height = 150;
			this.width = 250;
			this.title = "Edit attributes";
			hGroup.paddingTop = 5;
			hGroup.paddingLeft = 5;
			this.addElement(hGroup);
			hGroup.addElement(vGroup1);
			hGroup.addElement(vGroup2);
			
			// Display the attributes
			for(var i:uint = 0; i < attributes.length; i++){
				lb = new Label();
				lb.text = attributes[i];
				vGroup1.addElement(lb);
				lb = new Label();
				if(values[i])
					lb.text = " : " + values[i];
				else
					lb.text = " : NOT FILLED IN";
				vGroup2.addElement(lb);
			}
			
			// Register events
			this.addEventListener(CloseEvent.CLOSE, closeClick);
			
			// Display the popup
			PopUpManager.addPopUp(this, map, true);
			this.x = x;
			this.y = y;
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