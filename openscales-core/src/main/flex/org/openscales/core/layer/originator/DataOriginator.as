package org.openscales.core.layer.originator
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import org.openscales.core.Trace;
	import org.openscales.core.request.DataRequest;
	import org.openscales.geometry.basetypes.Bounds;

	/**
	 * Instances of DataOriginator are used to keep the informations about the origintor/provider of a Layer 
	 * (name, url, logo and extent and resolution constraint).
	 * 
	 * This DataOriginator class represents informations about the originator of a Layer.
	 * 
	 * @author ajard
	 */ 
	
	public class DataOriginator 
	{
		/**
		 * @private
		 * @default null
		 * The originator name of a Layer.
		 */
		private var _name:String = null;
		
		/**
		 * @private
		 * @default null
		 * The originator url.
		 */
		private var _url:String = null
			
		/**
		 * @private
		 * @default null
		 * The url of the originator logo picture.
		 */
		private var _pictureUrl:String = null;
		
		/**
		 * @private
		 * @default false
		 * is the image loading
		 */
		private var _loading:Boolean = false;

		/**
		 * @Private
		 * @default null
		 * The callback called when image is retrieved
		 */
		private var _callback:Function = null;
		
		/**
		 * @private
		 * @default null
		 * The constraint list of the originator.
		 */
		private var _constraints:Vector.<ConstraintOriginator> = null;
		
		/**
		 * Constructor of the class DataOriginator.
		 * 
		 * @param name The name of the originator (mandatory)
		 * @param url The url of the originator website (mandatory)
		 * @param urlPicture The url to the logo picture originator (mandatory)
		 */ 
		public function DataOriginator(name:String, url:String, pictureUrl:String)
		{
			this._name = name;
			this._url = url;
			this._pictureUrl = pictureUrl;	
			this._constraints = new Vector.<ConstraintOriginator>();
		}
		
		/**
		 * Add a constraint to the originator constraint list.
		 * @param constraint The constraint to add to this originator
		 */
		public function addConstraint(constraint:ConstraintOriginator):void
		{
			
			// Is the input constraint valid ?
			if (! constraint) 
			{
				Trace.debug("DataOriginator.addConstraint: null constraint not added");
				return;
			}
			var i:uint = 0;
			var j:uint = this._constraints.length;
			for (; i<j; ++i) 
			{
				if (constraint == this._constraints[i]) 
				{
					Trace.debug("DataOriginator.addConstraint: this constraint is already registered, not added ");
					return;
				}
			}
			// If the constraint is a new constraint, add it
			if (i == j) 
			{
				Trace.debug("DataOriginator.addConstraint: add a new constraint");
				this._constraints.push(constraint);
			}
		}
		
		/**
		 * Remove a constraint to the originator constraint list.
		 * @param constraint The constraint to add to this originator
		 */
		public function removeConstraint(constraint:ConstraintOriginator):void
		{
			// get the contraint to remove
			var i:int = this._constraints.indexOf(constraint);
					
			if(i!=-1) 
			{
				// remove form the vector
				this._constraints.splice(i,1);
			}
			constraint = null;
		}
		
		/**
		 * Determines if the DataOriginator passed as param is equal to current instance
		 *
		 * @param originator DataOriginator to check equality
		 * @return It is equal or not
		 */
		public function equals(originator:DataOriginator):Boolean {
			return (originator != null && (this.key == originator.key));
		}
		
		/**
		 * This function check for a given extent and resolution is the originator cover the are
		 * Search and check for each constraint for the originator if the area is covered
		 * 
		 * @param extent The extent at which the coverage is checked
		 * @param resolution The resolution at which the coverage is checked
		 */
		public function isCoveredArea(extent:Bounds, resolution:Number):Boolean
		{
			var i:uint = 0;
			var j:uint = this._constraints.length;
			// check for each constraint
			for (; i<j; ++i) 
			{
				// if extent and resolution contain given extent and resolution : covered
				if( this._constraints[i].extent.intersectsBounds(extent) &&
					this._constraints[i].minResolution <= resolution &&
					this._constraints[i].maxResolution >= resolution)
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * This function makes the dataoriginator to retrieve the picture
		 * 
		 * @param callback The callback to call when the loading is finished
		 */
		public function getImage(callback:Function):void {
			if(callback!=null && this._callback!=null && !this._loading) {
				this._loading = true;
				this._callback = callback;
				new DataRequest(this.pictureUrl, this.onLoadEnd, this.onLoadError);
			}
		}
		
		/**
		 * @private
		 * handle image loading end
		 */
		private function onLoadEnd(event:Event):void {
			this._loading = false;
			this._callback(this, event);
		}
		
		/**
		 * @private
		 * handle image loading errors
		 */
		private function onLoadError(event:IOErrorEvent):void {
			Trace.log("Originator image load failure: "+this.pictureUrl);
		}
		
		// getters setters
		
		/**
		 * The originator name of a Layer.
		 */
		public function get name():String
		{
			return this._name;
		}
		/**
		 * @private
		 */
		public function set name(name:String):void 
		{
			this._name = name;
		}
		
		/**
		 * The originator url.
		 */
		public function get url():String
		{
			return this._url;
		}
		/**
		 * @private
		 */
		public function set url(url:String):void 
		{
			this._url = url;
		}
		
		/**
		 * The url of the originator logo picture.
		 */
		public function get pictureUrl():String
		{
			return this._pictureUrl;
		}
		/**
		 * @private
		 */
		public function set pictureUrl(pictureUrl:String):void 
		{
			this._pictureUrl = pictureUrl;
		}
		
		/**
		 * The constraint list of the originator.
		 */
		public function get constraints():Vector.<ConstraintOriginator>
		{
			return this._constraints;
		}
		/**
		 * @private
		 */
		public function set constraints(constraints:Vector.<ConstraintOriginator>):void 
		{
			this._constraints = constraints;
		}
		
		/**
		 * indicates if the image loading
		 */
		public function get loading():Boolean
		{
			return _loading;
		}
		
		/**
		 * indicates the unique key of the originator
		 */
		public function get key():String {
			return this.name+this.url+this.pictureUrl;
		}
	}
}