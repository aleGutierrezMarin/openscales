package org.openscales.sld.ui
{
	import org.openscales.sld.handler.AbstractRuleHandler;
	
	import mx.collections.ArrayCollection;
	import mx.core.IDeferredInstance;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;

	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.utils.Trace;
	
	import org.openscales.sld.skin.DefaultHandlersManagerSkin;
	
	import spark.components.SkinnableContainer;
	
	public class HandlersManager extends SkinnableContainer
	{
		private var _currentSymbolizer:Symbolizer = null;
		private var _currentFeatureType:String = null;
		private var _currentDisplayMode:String = null;
		
		private var _elements:ArrayCollection = new ArrayCollection();
		private var _contentElements:ArrayCollection = new ArrayCollection();
		
		/**
		 *  @private
		 *  Flag that indicates whether or not the content has been created.
		 */
		private var mxmlContentCreated:Boolean = false;
		/** 
		 *  @private
		 *  Backing variable for the contentFactory property.
		 */
		private var _mxmlContentFactory:IDeferredInstance;
		private var _deferredContentCreated:Boolean;
		
		
		public function HandlersManager()
		{
			super();
			this.setStyle("skinClass",DefaultHandlersManagerSkin);
			this.refresh();
		}

		[Bindable]
		public function get currentSymbolizer():Symbolizer
		{
			return _currentSymbolizer;
		}

		public function set currentSymbolizer(value:Symbolizer):void
		{
			_currentSymbolizer = value;
			this.refresh();
		}
		
		[Bindable]
		public function get currentFeatureType():String
		{
			return _currentFeatureType;
		}
		
		public function set currentFeatureType(value:String):void
		{
			_currentFeatureType = value;
			this.refresh();
		}
		
		[Bindable]
		public function get currentDisplayMode():String
		{
			return _currentDisplayMode;
		}
		
		public function set currentDisplayMode(value:String):void
		{
			_currentDisplayMode = value;
			this.refresh();
		}
		
		[Bindable]
		public function get contentElements():ArrayCollection {
			return _contentElements;
		}
		public function set contentElements(value:ArrayCollection):void {
			this._contentElements=value;
			this.refresh();
		}
		
		/**
		*  A factory object that creates the initial value for the
		*  <code>content</code> property.
		*  
		*  @langversion 3.0
		*  @playerversion Flash 10
		*  @playerversion AIR 1.5
		*  @productversion Flex 4
		*/
		override public function set mxmlContentFactory(value:IDeferredInstance):void
		{
			if (value == _mxmlContentFactory)
				return;
			
			_mxmlContentFactory = value;
			mxmlContentCreated = false;
			
			super.mxmlContentFactory = value;
		}
		
		override public function createDeferredContent():void
		{
			if (!mxmlContentCreated)
			{
				mxmlContentCreated = true;
				
				if (_mxmlContentFactory)
				{
					var deferredContent:Object = _mxmlContentFactory.getInstance();
					var a:Array = deferredContent as Array;
					var i:uint = a.length;
					for(;i>0;--i) {
						if(!(a[i-1] is AbstractRuleHandler)) {
							a.splice(i-1,1);
						} else {
							(a[i-1] as AbstractRuleHandler).currentSymbolizer = this.currentSymbolizer;
							(a[i-1] as AbstractRuleHandler).currentDisplayMode = this.currentDisplayMode;
							this._elements.addItem(a[i-1]);
						}
					}
					mxmlContent = a;
					_deferredContentCreated = true;
					dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CREATION_COMPLETE));
				}
			}
			this.refresh();
		}
		
		private function refresh():void {
			var rulehandler:AbstractRuleHandler;
			this.contentElements.removeAll();
			for each(var element:Object in this._elements) {
				if(element is AbstractRuleHandler) {
					rulehandler = element as AbstractRuleHandler;
					rulehandler.currentSymbolizer = this.currentSymbolizer;
					rulehandler.currentDisplayMode = this.currentDisplayMode;
					if(rulehandler.display) {
						this.contentElements.addItem(rulehandler);
					}
				}
			}
			this.contentElements.refresh();
		}
	}
}