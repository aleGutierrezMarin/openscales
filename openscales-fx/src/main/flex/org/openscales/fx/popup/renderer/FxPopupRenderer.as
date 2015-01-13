package org.openscales.fx.popup.renderer
{
	import assets.fxg.ButtonCloseOver;
	import assets.fxg.ButtonCloseUp;
	
	import flash.events.MouseEvent;
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.conversion.TextConverter;
	
	import mx.graphics.SolidColorStroke;
	import mx.rpc.events.HeaderEvent;
	import mx.states.SetStyle;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.fx.control.IconButton;
	import org.openscales.fx.control.skin.IconButtonSkin;
	import org.openscales.fx.popup.skin.PopupPanelSkinBL;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	import spark.components.HGroup;
	import spark.components.Panel;
	import spark.components.RichText;
	import spark.components.TextArea;
	import spark.components.VGroup;
	import spark.primitives.Path;
	import org.openscales.fx.popup.FxPopup;
	
	public class FxPopupRenderer implements IFxPopupRenderer
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
		
		
		public function FxPopupRenderer(){}
		
		public function draw():void{
			if(_fxpopup.relativePosition == "tl" || _fxpopup.relativePosition == "tr"){
				_fxpopup.popupContentGroup.top = 7;
			}
			else if(_fxpopup.relativePosition == "bl" || _fxpopup.relativePosition == "br"){
				_fxpopup.popupContentGroup.top = 11;
			}
			
			var title:RichText = new RichText();
			title.width = _fxpopup.WIDTH - 28;
			title.height = 14;
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
			
			var textArea:TextArea = new TextArea();
			textArea.setStyle("borderVisible", false);
			textArea.setStyle("contentBackgroundAlpha",0);
			textArea.left=5;
			textArea.height=_fxpopup.HEIGHT - title.height - 35;
			textArea.width=300;
			textArea.textFlow = TextConverter.importToFlow(_content, TextConverter.TEXT_FIELD_HTML_FORMAT);
			
			var structure:VGroup=new VGroup();
			structure.setStyle("contentBackgroundAlpha",0);
			structure.gap=1;
			structure.addElement(titleAndCloseButton);
			structure.addElement(path);
			structure.addElement(textArea);
			
			if(_fxpopup.popupContentGroup && _fxpopup.popupContentGroup.initialized){
				_fxpopup.popupContentGroup.addElement(structure);
			}
			
			_fxpopup.visible=true;
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
		
	}
}
