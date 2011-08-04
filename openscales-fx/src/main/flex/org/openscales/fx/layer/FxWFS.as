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
		
		private var _version:String = "1.0.0";
		
		private var _useCapabilities:Boolean = true;
		
		// Constructor
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
		
		public function get layer():Layer
		{
			return this.nativeLayer;
		}
		
		override public function get nativeLayer():Layer {
			if (this.style != null) {
				(this._layer as WFS).style = this.style;
			}
			
			(this._layer as WFS).url = this._url;
			(this._layer as WFS).typename = this._typename;
			(this._layer as WFS).useCapabilities = this._useCapabilities;
			(this._layer as WFS).version = this._version;
			
			return this._layer;
		}
		
		public function set url(value:String):void {
			this._url = value;
			if(this.nativeLayer)
				(this._layer as WFS).url = this._url;
		}
		
		public function get url():String{
			return this._url;
		}
		
		public function set typename(value:String):void {
			this._typename = value;
		}
		
		public function get typename():String{
			return this._typename;
		}
		
		public function set version(value:String):void {
			this._version = value;
			if(this.nativeLayer)
				(this._layer as WFS).version = value;
		}
		public function get version():String{
			return this._version;
		}
		
		public function set useCapabilities(value:Boolean):void {
			this._useCapabilities = value;
		}
		
		public function get useCapabilities():Boolean{
			return this._useCapabilities;
		}
		
		public override function set projection(value:String):void
		{
			super.projection = value;
			//super.maxExtent = super.maxExtent;
			super.configureLayer();
		}
		
	}
}
