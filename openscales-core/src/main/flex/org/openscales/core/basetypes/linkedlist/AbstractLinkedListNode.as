package org.openscales.core.basetypes.linkedlist
{
	/**
	 * AbstractLinkedListNode
	 * To prevent many duplicate code.
	 *
	 * @author slopez
	 */
	public class AbstractLinkedListNode implements ILinkedListNode
	{
		private var _previous:ILinkedListNode = null;
		private var _next:ILinkedListNode = null;
		private var _uid:String = null;

		public function AbstractLinkedListNode() {
			// Nothing to do
		}

		public function get previousNode():ILinkedListNode {
			return this._previous;
		}
		
		public function set previousNode(value:ILinkedListNode):void {
			this._previous = value;
			// TODO: ensure that value.nextNode == this
		}
		
		public function get nextNode():ILinkedListNode {
			return this._next;
		}
		
		public function set nextNode(value:ILinkedListNode):void {
			this._next = value;
			// TODO: ensure that value.previousNode == this
		}
		
		public function set uid(value:String):void {
			this._uid = value;
		}
		
		public function get uid():String {
			return this._uid;
		}
		
		public function equals(o:Object):Boolean {
			return false;
		}
		
		public function clear():void {
			this._next = null;
			this._previous = null;
		}
		
	}
}