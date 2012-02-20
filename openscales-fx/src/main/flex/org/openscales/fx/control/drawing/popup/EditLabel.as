package org.openscales.fx.control.drawing.popup
{
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.I18NEvent;
	import org.openscales.core.i18n.Catalog;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import org.openscales.fx.control.drawing.popup.skin.EditLabelSkin;
	
	public class EditLabel extends TitleWindow
	{
		
		
		[SkinPart(required="true")]
		public var input:TextInput;
		
		[SkinPart(required="true")]
		public var okButton:Button;
		
		[SkinPart]
		public var cancelButton:Button; 
		
		[SkinPart]
		public var inputLabel:Label
		
		private var _map:Map;
		
		public function EditLabel()
		{
			super();
			setStyle("skinClass", EditLabelSkin);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		/**
		 * Configures the popup
		 */ 
		protected function onCreationComplete(event:FlexEvent):void{
			this.x = (parent.width-this.width)/2;
			this.y = (parent.height-this.height)/2;
			
			if(_map){
				_map.addEventListener(I18NEvent.LOCALE_CHANGED,localize);
			}
			localize();
			input.setFocus();
		}
		
		/**
		 * @inheritDoc
		 */ 
		override protected function partAdded(partName:String, instance:Object):void{
			super.partAdded(partName,instance);
			if(instance == cancelButton){
				cancelButton.addEventListener(MouseEvent.CLICK, closePopup);
				this.cancelButton.label = Catalog.getLocalizationForKey("editfeatureattributes.discard");
			}
			else if(instance == okButton){
				okButton.addEventListener(MouseEvent.CLICK, closePopup);
			}
			else if(instance == inputLabel){
				this.inputLabel.text=Catalog.getLocalizationForKey('editlabel.label');
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partRemoved(partName:String, instance:Object):void{
			super.partRemoved(partName,instance);
			if(instance == cancelButton){
				cancelButton.removeEventListener(MouseEvent.CLICK, closePopup);
			}
			else if(instance == okButton){
				okButton.removeEventListener(MouseEvent.CLICK, closePopup);
			}
			
		}
		
		/**
		 * @private
		 */
		protected function localize(e:I18NEvent=null):void {
			this.title = Catalog.getLocalizationForKey("editlabel.title");
			if(this.inputLabel)this.inputLabel.text=Catalog.getLocalizationForKey('editlabel.label');
			this.okButton.label = Catalog.getLocalizationForKey("editfeatureattributes.valid");
			if(this.cancelButton)this.cancelButton.label = Catalog.getLocalizationForKey("editfeatureattributes.discard");
		}
		
		/**
		 * Closes popup
		 */ 
		public function closePopup(event:MouseEvent=null):void{
			if(_map) _map.removeEventListener(I18NEvent.LOCALE_CHANGED,this.localize);
			PopUpManager.removePopUp(this);
		}
		
		/**
		 * The map where this popup is displayed
		 */ 
		public function get map():Map
		{
			return _map;
		}
		
		/**
		 * @private
		 */ 
		public function set map(value:Map):void
		{
			if(!value && _map)_map.removeEventListener(I18NEvent.LOCALE_CHANGED,localize);
			_map = value;
			if(_map)_map.addEventListener(I18NEvent.LOCALE_CHANGED,localize);
		}
	}
}