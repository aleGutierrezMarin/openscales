package org.openscales.core.format.gml.parser
{
	import org.openscales.core.feature.Feature;
	import org.openscales.geometry.Point;
	
	public class GMLParser
	{
		protected var _internalProjSrsCode:String = null;
		protected var _externalProjSrsCode:String = null;
		
		protected var _eXML:String    = "";// it must not have reference at wfs in sthis class
		protected var _eFXML:String   = "";
		protected var _sFXML:String   = "";
		
		private var _dim:Number = 2;
		private var _parseExtractAttributes:Boolean = true;
		
		public function GMLParser()
		{
		}
		
		/**
		 * Read the feature contained in a XML node
		 * 
		 * @Param data the XML node
		 * 
		 * @Return a list of features
		 */
		public function parseFeature(data:XML, lonLat:Boolean=true):Feature {
			return null;
		}
		
		/**
		 * Return an array of coords
		 */ 
		public function parseCoords(xmlNode:XML, lonLat:Boolean=true):Vector.<Number> {
			var x:Number, y:Number, left:Number, bottom:Number, right:Number, top:Number;
			
			if (xmlNode) {
				
				var coordNodes:XMLList = xmlNode..*::posList;
				
				if (coordNodes.length() == 0) { 
					coordNodes = xmlNode..*::pos;
				}    
				
				if (coordNodes.length() == 0) {
					coordNodes = xmlNode..*::coordinates;
				}    
				
				var coordString:String = coordNodes[0].text();
				
				var nums:Array = (coordString) ? coordString.split(/[, \n\t]+/) : [];
				
				while (nums[0] == "") 
					nums.shift();
				
				var j:int = nums.length;
				while (nums[j-1] == "") 
					nums.pop();
				
				j = nums.length;
				// verifies if the dimension of the feature is compatible with the number of coordinates 
				if ( j % dim == 0 ){
					var points:Vector.<Number>  = new Vector.<Number>();
					var i:int;
					for(i = 0; i < j; i = i + this.dim) {
						if(lonLat) {
							x = Number(nums[i]);
							y = Number(nums[i+1]);
						} else {
							x = Number(nums[i+1]);
							y = Number(nums[i]);
						}
						var p:Point = new Point(x, y);
						/*if (this.internalProjSrsCode != null, this.externalProjSrsCode != null) {
							p.transform(this.externalProjSrsCode, this.internalProjSrsCode);
						}*/
						points.push(p.x);
						points.push(p.y);
					}
					return points;
				}
			}
			return null;
		}
		
		/**
		 * Indicates the dimension of the coordinates
		 */
		public function get dim():Number {
			return this._dim;
		}
		/**
		 * @Private
		 */
		public function set dim(value:Number):void {
			this._dim = value;
		}
		
		/**
		 * Indicates if extra attributes should be parsed
		 */
		public function get parseExtractAttributes():Boolean {
			return this._parseExtractAttributes;
		}
		/**
		 * @Private
		 */
		public function set parseExtractAttributes(value:Boolean):void {
			this._parseExtractAttributes = value;
		}
		
		public function get sFXML():String
		{
			return _sFXML;
		}
		
		public function get eFXML():String
		{
			return _eFXML;
		}
		
		public function get eXML():String
		{
			return _eXML;
		}
		
		public function get gml():Namespace {
			return null;	
		}
		
		public function get internalProjSrsCode():String {
			return this._internalProjSrsCode;
		}
		
		public function set internalProjSrsCode(value:String):void {
			this._internalProjSrsCode = value;
		}
		
		public function get externalProjSrsCode():String {
			return this._externalProjSrsCode;
		}
		
		public function set externalProjSrsCode(value:String):void {
			this._externalProjSrsCode = value;
		}
	}
}