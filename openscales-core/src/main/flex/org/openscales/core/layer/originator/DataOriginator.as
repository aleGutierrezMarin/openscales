package org.openscales.core.layer.originator
{
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
		private var _urlPicture:String = null;
		
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
		public function DataOriginator(name:String, url:String, urlPicture:String)
		{
			this._name = name;
			this._url = url;
			this._urlPicture = urlPicture;	
		}
		
		/**
		 * Add a constraint to the originator constraint list.
		 * @param constraint The constraint to add to this originator
		 */
		public function addConstraint(constraint:ConstraintOriginator):void
		{
			
			// Is the input constraint valid ?
			if (! constraint) {
				trace("DataOriginator.addConstraint: null constraint not added");
				return;
			}
			var i:uint = 0;
			var j:uint = this._constraints.length;
			for (; i<j; ++i) {
				if (constraint == this._constraints[i]) {
					trace("DataOriginator.addConstraint: this constraint is already registered, not added ");
					return;
				}
			}
			// If the constraint is a new constraint, add it
			if (i == j) {
				trace("DataOriginator.addConstraint: add a new constraint");
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
			if(i!=-1) {
				// remove form the vector
				this._constraints = this._constraints.slice(i,1);
			}
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
		public function get urlPicture():String
		{
			return this._urlPicture;
		}
		/**
		 * @private
		 */
		public function set urlPicture(urlPicture:String):void 
		{
			this._urlPicture = urlPicture;
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
	}
}