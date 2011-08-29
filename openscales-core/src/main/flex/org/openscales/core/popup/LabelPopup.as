package org.openscales.core.popup
{
	import flash.events.MouseEvent;
	
	import mx.managers.PopUpManager;
	
	import org.openscales.core.Map;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import spark.components.VGroup;

	public class LabelPopup extends TitleWindow
	{
		private var _text:TextInput = new TextInput();
		private var _onClose:Function = new Function();
		
		/**
		 * Constructor
		 */
		public function LabelPopup(map:Map, onClose:Function)
		{
			var vg:VGroup = new VGroup();
			var hg1:HGroup = new HGroup();
			var hg2:HGroup = new HGroup();
			var inputLabel:Label = new Label();
			var okButton:Button = new Button();
			var cancelButton:Button = new Button();
			
			this.addElement(vg);
			vg.addElement(hg1);
			vg.addElement(hg2);
			okButton.label = "Valider";
			cancelButton.label = "Annuler";
			inputLabel.text = "Label : ";
			hg1.addElement(inputLabel);
			hg1.addElement(this._text);
			hg2.addElement(okButton);
			hg2.addElement(cancelButton);
			
			//
			okButton.addEventListener(MouseEvent.CLICK, okClick);
			cancelButton.addEventListener(MouseEvent.CLICK, cancelClick);
			this._onClose = onClose;
			
			//
			PopUpManager.addPopUp(this, map, true);
		}
		
		public function cancelClick(evt:MouseEvent):void
		{
			PopUpManager.removePopUp(this);
		}
		
		public function okClick(evt:MouseEvent):void
		{
			this._onClose(this._text.text);
			PopUpManager.removePopUp(this);
		}
	}
}