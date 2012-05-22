package org.openscales.core.layer.originator
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.request.DataRequest;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;

	/**
	 * Instances of DataOriginator are used to keep the informations about the origintor/provider of a Layer 
	 * (name, attribution, url, logo and extent and resolution constraint).
	 * 
	 * This DataOriginator class represents informations about the originator of a Layer.
	 * 
	 * @author ajard
	 */ 
	
	public class DataOriginator 
	{
		private var _name:String = null;
		
		private var _attribution:String = null;
		
		private var _url:String = null
			
		private var _pictureUrl:String = null;
		
		private var _loading:Boolean = false;

		/**
		 * @Private
		 * The callback called when image is retrieved
		 */
		private var _callback:Function = null;
		
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
			this._attribution = name;
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
				return;
			}
			var i:uint = 0;
			var j:uint = this._constraints.length;
			for (; i<j; ++i) 
			{
				if (constraint == this._constraints[i]) 
				{
					return;
				}
			}
			// If the constraint is a new constraint, add it
			if (i == j) 
			{
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
		public function isCoveredArea(extent:Bounds, resolution:Resolution):Boolean
		{
			var i:uint = 0;
			var j:uint = this._constraints.length;
			var constraint:ConstraintOriginator = null;
			var minRes:Resolution = null;
			var maxRes:Resolution = null;
			// check for each constraint
			for (; i<j; ++i) 
			{
				constraint = this._constraints[i];
				minRes = constraint.minResolution.reprojectTo(resolution.projection);
				maxRes = constraint.maxResolution.reprojectTo(resolution.projection);
				
				// if extent and resolution contain given extent and resolution : covered
				if( constraint.extent.intersectsBounds(extent,false) &&
					minRes.value <= resolution.value &&
					maxRes.value >= resolution.value)
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
		 * indicates the unique key of the originator
		 */
		public function get key():String {
			return this._name;
		}

		/**
		 * The originator name of a Layer (eg.: "ign")
		 * @default null
		 */
		public function get name():String
		{
			return _name;
		}

		/**
		 * @private
		 */
		public function set name(value:String):void
		{
			_name = value;
		}

		/**
		 * The originator url.
		 * 
		 * @default null
		 */
		public function get url():String
		{
			return _url;
		}

		/**
		 * @private
		 */
		public function set url(value:String):void
		{
			_url = value;
		}

		/**
		 * 
		 * The url of the originator logo picture.
		 * 
		 * @default null
		 */
		public function get pictureUrl():String
		{
			return _pictureUrl;
		}

		/**
		 * @private
		 */
		public function set pictureUrl(value:String):void
		{
			_pictureUrl = value;
		}

		/**
		 * Is the image loading
		 * 
		 * @default false
		 */
		public function get loading():Boolean
		{
			return _loading;
		}

		/**
		 * The constraint list of the originator.
		 * @default null
		 */
		public function get constraints():Vector.<ConstraintOriginator>
		{
			return _constraints;
		}

		/**
		 * @private
		 */
		public function set constraints(value:Vector.<ConstraintOriginator>):void
		{
			_constraints = value;
		}

		/**
		 * The entity this originator is attributed to (eg. "Institut National de l'Information géographique et forestière"). This is basically a human readable name, it also could be an i18n key.
		 * @default The value of <code>name</code> property
		 */
		public function get attribution():String
		{
			return _attribution;
		}

		/**
		 * @private
		 */
		public function set attribution(value:String):void
		{
			_attribution = value;
		}


	}
}