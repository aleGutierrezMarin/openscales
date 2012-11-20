package org.openscales.core.style.graphic
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.filter.expression.IExpression;

	public class Graphic
	{
		private namespace sldns="http://www.opengis.net/sld";
		
		private var _size:Object;
		private var _opacity:Number;
		private var _rotation:int;
		private var _graphics:Vector.<IGraphic>;
		
		public function Graphic(size:Object = 6, opacity:Number=1, rotation:int=0, graphics:Vector.<IGraphic>=null) {
			this._size = size;
			this._opacity = opacity;
			this._rotation = rotation;
			if(graphics)
				this._graphics = graphics;
			else
				this._graphics = new Vector.<IGraphic>();
		}
		
		public function clone():Graphic {
			var ret:Graphic = new Graphic(this._size,this._opacity,this._rotation);
			if(this._graphics) {
				for each(var igraph:IGraphic in this._graphics)
					ret.graphics.push(igraph.clone());
			}
			return ret;
		}
		public function getDisplayObject(feature:Feature):DisplayObject {
			var ret:Sprite = new Sprite();
			if(this._graphics) {
				for each(var igraph:IGraphic in this._graphics) {
					var mark:DisplayObject = igraph.getDisplayObject(feature,this.getSizeValue(feature));
					if(mark)
						ret.addChild(mark);
				}
			}
			ret.alpha = this.opacity;
			ret.rotation = this.rotation;
			return ret;
		}
		
		/**
		 * Evaluates the size value for given feature
		 */
		public function getSizeValue(feature:Feature=null):Number {
			
			if (this._size && feature) {
				
				if (this._size is IExpression) {
					
					return ((this._size as IExpression).evaluate(feature) as Number);
				} else {
					
					return (this._size as Number);
				}
			}
			
			return 6;
		}
		
		public function get sld():String {
			var ret:String = "<sld:Graphic>\n";
			if(this._graphics) {
				var subsld:String;
				for each(var graph:IGraphic in this._graphics) {
					subsld = graph.sld;
					if(subsld)
						ret+=subsld;
				}
			}
			ret+="<sld:Size>"+getSizeValue()+"</sld:Size>\n";
			ret+="<sld:Rotation>"+this._rotation+"</sld:Rotation>\n";
			ret+="<sld:Opacity>"+this._opacity+"</sld:Opacity>\n";
			ret+="</sldGraphic>\n";
			return ret;
		}
		public function set sld(value:String):void {
			use namespace sldns;
			var dataXML:XML = new XML(value);
			this._opacity = 1;
			this._size = 6;
			this._rotation = 0;
			if(!this._graphics)
				this._graphics = new Vector.<IGraphic>();
			else
				for(var i:uint = 0;i<this._graphics.length;++i)
					this._graphics.pop();
			
			if(dataXML.Size[0])
				this.size = Number(dataXML.size[0].toString());
			if(dataXML.Opacity[0])
				this.opacity = Number(dataXML.Opacity[0].toString());
			if(dataXML.Rotation[0])
				this.rotation = Number(dataXML.Rotation[0].toString());
			
			var childs:XMLList = dataXML.children();
			var graph:IGraphic = null;
			for each(dataXML in childs) {
				switch (dataXML.localName()) {
					case "Mark":
						graph = new Mark();
						break;
					case "ExternalGraphic":
						graph = new ExternalGraphic();
						break;
				}
				if(graph) {
					graph.sld = dataXML.toString();
					this._graphics.push(graph);
					graph = null;
				}
			}
		}
		public function get size():Object {
			return this._size;
		}
		public function set size(value:Object):void {
			this._size = value;
		}

		public function get opacity():Number
		{
			return _opacity;
		}

		public function set opacity(value:Number):void
		{
			_opacity = value;
		}

		public function get rotation():int
		{
			return _rotation;
		}

		public function set rotation(value:int):void
		{
			_rotation = value;
		}

		public function get graphics():Vector.<IGraphic>
		{
			return _graphics;
		}

		public function set graphics(value:Vector.<IGraphic>):void
		{
			_graphics = value;
		}

		
	}
}