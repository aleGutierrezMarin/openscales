package org.openscales.fx.control.drawing.popup
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import org.openscales.core.Map;
	import org.openscales.core.feature.Feature;
	import org.openscales.fx.control.skin.ScrollableContainerSkin;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import spark.components.VGroup;
	import spark.layouts.VerticalLayout;
	
	public class ChangeAttributes extends TitleWindow
	{
		private var _callback:Function;
		private var _textInputArray:Array = new Array();
		
		/**
		 * Constructor
		 */
		public function ChangeAttributes(map:Map, attributes:Array, feature:Feature, callback:Function)
		{
			var hGroup:HGroup = new HGroup();
			var vGroup:VGroup = new VGroup();
			var okButton:Button = new Button();
			var lb:Label;
			var ti:TextInput;
			
			// Define the popup properties
			var x:uint = map.width / 2;
			var y:uint = map.height / 2;
			this.height = 300;
			this.width = 220;
			this.title = "Change attributes";
			hGroup.height = this.height;
			hGroup.width = this.width;
			hGroup.paddingTop = 5;
			hGroup.paddingLeft = 5;
			hGroup.clipAndEnableScrolling = true;
			this.addElement(hGroup);
			hGroup.addElement(vGroup);
			
			for(var i:uint = 0; i < attributes.length; i++){
				
				lb = new Label();
				lb.text = attributes[i] + " : ";
				vGroup.addElement(lb);
				ti = new TextInput();
				ti.width = 200;
				if(feature.attributes[attributes[i]])
					ti.text = feature.attributes[attributes[i]];
				else
					ti.text = "";
				vGroup.addElement(ti);
				_textInputArray.push(ti);
				lb = new Label();
				lb.text = "";
				vGroup.addElement(lb);
			}
			
			okButton.label = "OK";
			vGroup.addElement(okButton);
			
			// Register events
			this.addEventListener(CloseEvent.CLOSE, closeClick);
			okButton.addEventListener(MouseEvent.CLICK, okClick);
			this._callback = callback;
			
			// Display the popup
			PopUpManager.addPopUp(this, map, true);
			this.x = x;
			this.y = y;
		}
		
		/**
		 * This function is called when the close button is clicked
		 */
		private function closeClick(evt:Event):void
		{
			PopUpManager.removePopUp(this);
		}
		
		/**
		 * This function is called when the ok button is clicked
		 */
		private function okClick(evt:MouseEvent):void
		{
			this._callback(_textInputArray);
			PopUpManager.removePopUp(this);
		}
	}
}