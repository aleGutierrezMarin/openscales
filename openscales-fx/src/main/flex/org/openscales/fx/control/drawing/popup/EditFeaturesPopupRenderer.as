package org.openscales.fx.control.drawing.popup
{
	import assets.fxg.ButtonCloseOver;
	import assets.fxg.ButtonCloseUp;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.engine.FontWeight;
	
	import mx.graphics.SolidColorStroke;
	
	import org.openscales.core.events.I18NEvent;
	import org.openscales.core.i18n.Catalog;
	import org.openscales.fx.control.IconButton;
	import org.openscales.fx.popup.FxPopup;
	import org.openscales.fx.popup.renderer.IFxPopupRenderer;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.RichText;
	import spark.components.Scroller;
	import spark.components.TextInput;
	import spark.components.VGroup;
	import spark.primitives.Path;

	public class EditFeaturesPopupRenderer implements IFxPopupRenderer
	{
		/**
		 * Popup that have to be rendered
		 */
		private var _fxpopup:FxPopup=null;
		
		/**
		 * Popup content, can be html content
		 */
		private var _content:String="";
		
		/**
		 * Popup title content (simple string)
		 */
		private var _titleContent:String="";
		
		private static var DEFAULT_W:Number = 300;
		private static var DEFAULT_H:Number = 250;
		private var _attrInput:Vector.<TextInput> = null;
		private var _btnValid:Button = null;
		private var _btnDiscard:Button = null;
		private var _labelTextInput:TextInput;
		private var _firstTextInput:TextInput;
		protected var _vgroup:VGroup = null;
		private var scroller:Scroller;
		
		public function EditFeaturesPopupRenderer(){}
		
		public function draw():void{
			if(this._fxpopup.feature.layer && this._fxpopup.feature.layer.map && this._fxpopup.feature.layer.attributesId.length>0)
				this._fxpopup.feature.layer.map.addEventListener(I18NEvent.LOCALE_CHANGED,this.localize);
			
			if(_fxpopup.relativePosition == "tl" || _fxpopup.relativePosition == "tr"){
				_fxpopup.popupContentGroup.top = 7;
			}
			else if(_fxpopup.relativePosition == "bl" || _fxpopup.relativePosition == "br"){
				_fxpopup.popupContentGroup.top = 11;
			}
			
			var title:RichText = new RichText();
			title.width = _fxpopup.WIDTH - 28;
			title.height = 13;
			title.setStyle("lineBreak","toFit");
			title.maxDisplayedLines=1;
			title.setStyle("backgroundAlpha",0);
			title.setStyle("fontWeight",FontWeight.BOLD);
			title.setStyle("fontSize",14);
			if(_titleContent){
				title.text = _titleContent;
				title.toolTip = _titleContent;	
			}
			
			var closeButton:IconButton = new IconButton();
			closeButton.setStyle("icon", new ButtonCloseUp());
			closeButton.setStyle("iconOver", new ButtonCloseOver());
			closeButton.setStyle("iconDown", new ButtonCloseOver());
			closeButton.addEventListener(MouseEvent.MOUSE_UP,_fxpopup.destroy);
			
			var titleAndCloseButton:HGroup = new HGroup();
			titleAndCloseButton.paddingLeft=5;
			titleAndCloseButton.verticalAlign="middle";
			titleAndCloseButton.addElement(title);
			titleAndCloseButton.addElement(closeButton);
			
			var path:Path = new Path();
			path.data="M0 0 300 0";
			var stroke:SolidColorStroke = new SolidColorStroke();
			stroke.weight=0.1;
			stroke.scaleMode="none";
			stroke.caps="none";
			stroke.pixelHinting=true;
			stroke.color=0x959595;
			path.stroke = stroke;
			
			var structure:VGroup=new VGroup();
			structure.setStyle("contentBackgroundAlpha",0);
			structure.gap=5;
			
			structure.addElement(titleAndCloseButton);
			structure.addElement(path);
			

			_vgroup = new VGroup();
			_vgroup.gap = 10;
			_vgroup.top = 5;
			_vgroup.width = DEFAULT_W - 16;
			_vgroup.height = DEFAULT_H - 4;
			structure.addElement(_vgroup);
			
			scroller = new Scroller();
			scroller.percentWidth = 100;
			scroller.viewport = _vgroup;
			structure.addElement(scroller);
			
			if(!this._attrInput)
				this._attrInput = new Vector.<TextInput>();
			
			var group:HGroup;
			var j:uint = this.fxpopup.feature.layer.attributesId.length;
			var isSetFirstTextInput:Boolean = false;
			for(var i:uint = 0 ;i<j;++i) {
				var key:String = this.fxpopup.feature.layer.attributesId[i];
				//If key is popupContentHTML, don't show it
				if(key != "popupContentHTML" && key != "id") {
					group = new HGroup();
					group.verticalAlign = "middle";
					group.gap = 10;
					group.paddingLeft = 5;
					group.paddingRight = 5;
					group.paddingTop = 5;
					_vgroup.addElement(group);
					var lb:Label = new Label();
					lb.width = 100;
					lb.text = key;
					group.addElement(lb);
					var input:TextInput = new TextInput();
					input.id = key;
					if(this.fxpopup.feature.attributes[key])
						input.text = this.fxpopup.feature.attributes[key];
					else
						input.text = "";
					
					//We set the fistTextInput if not already set
					if(!isSetFirstTextInput) {
						_firstTextInput = input;
						isSetFirstTextInput = true;
					}
					
					group.addElement(input);
					_attrInput.push(input);
				}
			}
			
			group = new HGroup();
			group.gap = 10;
			group.horizontalAlign = "right";
			_vgroup.addElement(group);
			
			group = new HGroup();
			group.gap = 10;
			group.horizontalAlign = "right";
			_vgroup.addElement(group);
			
			if(!this._btnValid) {
				this._btnValid = new Button();
				this._btnValid.addEventListener(MouseEvent.CLICK, valid);
				this._btnValid.label = Catalog.getLocalizationForKey("editfeatureattributes.valid");
			}
			if(!this._btnDiscard) {
				this._btnDiscard = new Button();
				this._btnDiscard.addEventListener(MouseEvent.CLICK, close);
				this._btnDiscard.label = Catalog.getLocalizationForKey("editfeatureattributes.discard");
			}
			
			group.addElement(this._btnValid);
			group.addElement(this._btnDiscard);
			
			if(_fxpopup.popupContentGroup && _fxpopup.popupContentGroup.initialized){
				_fxpopup.popupContentGroup.addElement(structure);
			}
			
			_fxpopup.visible=true;
			_firstTextInput.setFocus();
		}
		
		private function localize(e:I18NEvent=null):void {
			this._titleContent = Catalog.getLocalizationForKey("editfeatureattributes.title");
			this._btnValid.label = Catalog.getLocalizationForKey("editfeatureattributes.valid");
			this._btnDiscard.label = Catalog.getLocalizationForKey("editfeatureattributes.discard");
		}
		
		public function close(event:Event=null):void {
			this.clearAttrInputVector();
			this._attrInput = null;
			fxpopup.destroy(event);
		}
		
		private function clearAttrInputVector():void {
			if(_attrInput)
				while(_attrInput.pop()) {}
		}
		
		private function valid(e:Event):void {
			if(_attrInput && _attrInput.length>0) {
				var ti:TextInput;
				while(ti = _attrInput.pop())
					this.fxpopup.feature.attributes[ti.id] = ti.text;
			}
			
			this.close(null);
		}
		
		/**
		 * Destroy the popupRenderer
		 */
		public function destroy():void{
			_titleContent=null;
			_content=null;
			_fxpopup=null;
		}
		
		public function set fxpopup(value:FxPopup):void{
			_fxpopup = value;
		}
		
		public function get fxpopup():FxPopup{
			return _fxpopup;
		}
		
		public function get content():String{
			return this._content;
		}
		
		public function set content(value:String):void {
			this._content = value;
		}
		
		public function get titleContent():String{
			return this._titleContent;
		}
		
		public function set titleContent(value:String):void {
			this._titleContent = value;
		}
		
		public function get firstTextInput():TextInput{
			return this._firstTextInput;
		}
		
		public function set firstTextInput(value:TextInput):void {
			this._firstTextInput = value;
		}
	}
}