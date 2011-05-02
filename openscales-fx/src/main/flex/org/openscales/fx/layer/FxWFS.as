package org.openscales.fx.layer
{
	import flash.display.DisplayObject;
	
	import mx.core.IVisualElement;
	
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WFS;
	import org.openscales.fx.feature.FxStyle;
	
	/**
	 * <p>WFS Flex wrapper.</p>
	 * <p>To use it, declare a &lt;WFS /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class FxWFS extends FxFeatureLayer
	{
		private var _url:String;
		
		private var _typename:String;
		
		private var _version:String;
		
		private var _useCapabilities:Boolean = false;
		
		private var _capabilitiesVersion:String = "1.1.0";
		
		
		public function FxWFS() {
			super();
		}
		
		override public function init():void {
			this._layer = new WFS("", "", "");
			this._layer.visible=true
			if(this._projection != null)
				this._layer.projSrsCode = this._projection;
			(this._layer as WFS).useCapabilities=_useCapabilities;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			for(var i:int=0; i < this.numElements ; i++) {
				var child:IVisualElement = this.getElementAt(i);
				if(child is FxStyle) {
					this.style = (child as FxStyle).style;
				}
			}
		}
		
		override public function get layer():Layer {
			if (this.style != null) {
				(this._layer as WFS).style = this.style;
			}
			
			(this._layer as WFS).url = this._url;
			(this._layer as WFS).typename = this._typename;
			(this._layer as WFS).useCapabilities = this._useCapabilities;
			(this._layer as WFS).capabilitiesVersion = this._capabilitiesVersion;
			
			return this._layer;
		}
		
		public function set url(value:String):void {
			this._url = value;
		}
		
		public function set typename(value:String):void {
			this._typename = value;
		}
		
		public function set version(value:String):void {
			this._version = value;
		}
		
		public function set useCapabilities(value:Boolean):void {
			this._useCapabilities = value;
		}
		
		public function set capabilitiesVersion(value:String):void {
			this._capabilitiesVersion = value;
		}
		
		public function get capabilitiesVersion():String {
			return this.capabilitiesVersion;
		}
		
	}
}