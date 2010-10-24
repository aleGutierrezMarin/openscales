package org.openscales.core.basetypes.trees
{
	/**
	 * TreeNode implementation : generic node of a tree
	 *
	 * @author aba
	 */
	public class TreeNode implements ITreeNode
	{
		
		private var _nodeValue:Object;
		private var _container:ITree;
		private var _father:ITreeNode = null;
		private var _children:Vector.<ITreeNode>;

		/**
		 * Constructor.
		 * If the conditions on the parameters are not respected, the
		 * "destroy" function is called.
		 * @param c container (NOT null) of the node to create
		 * @param v value (NOT null) of the node to create
		 */
		public function TreeNode(c:ITree, v:Object) {
			try {
				this.container = c;
				this._children = new Vector.<ITreeNode>(this.container.nodeWidth, true);
				this.nodeValue = v;
			} catch (e:Error) {
				throw e;
			}
		}
		
		public function get nodeValue():Object {
			return this._nodeValue;
		}
		/**
		 * The input value can not be null, use "destroy" instead
		 */
		public function set nodeValue(value:Object):void {
			// Check the validity of the input value
			if (value == null) {
				throw new ArgumentError("ArgumentError: a node value can not be null");
				return;
			}
			// Update with the input value
			this._nodeValue = value;
		}
		
		public function getChildValue(pos:uint):Object {
			var child:ITreeNode = this.getChild(pos);
			return (child) ? child.nodeValue : null;
		}
		
		public function setChildValue(pos:uint, value:Object):void {
			var child:ITreeNode = this.getChild(pos);
			if (child) {
				if (value) {
					// Just change the child's node value
					child.nodeValue = value;
				} else {
					// The input value is null, so destroy the child
					child.destroy();
				}
			} else {
				if (value) {
					// The child does not exist, so create if with the not null input value
					var node:ITreeNode = new TreeNode(this.container, value);
					this._children[pos] = node;
				}
				// nothing to do if the child and the input value are both null
			}
		}
		
		/**
		 * Here, only the reference to the nodeValue and to the input object are compared.
		 * For specific kind of nodes with a known type of node values, this function can be overrided
		 */
		public function valueEquals(value:Object):Boolean {
			return (this.nodeValue == value);
		}
		
		public function hasChildValue(value:Object):Boolean {
			for (var i:int=this._children.length-1; i>-1; --i) {
				if (this._children[i].valueEquals(value)) {
					return true;
				}
			}
			return false;
		}
		
		public function hasChild(node:ITreeNode):Boolean {
			for (var i:int=this._children.length-1; i>-1; --i) {
				if (this._children[i] == node) {
					return true;
				}
			}
			return false;
		}
		
		public function get container():ITree {
			return this._container;
		}
		/*private*/public function set container(value:ITree):void {
			// Check the validity of the input value
			if (value == null) {
				throw new ArgumentError("ArgumentError: invalid value, a container can not be null");
				return;
			}
			// Update with the input value
			this._container = value;
		}
		
		public function get father():ITreeNode {
			return this._father;
		}
		/*private*/public function set father(value:ITreeNode):void {
			// Check the validity of the container (and so of the nodeWidth)
			if (value.container != this.container) {
				throw new ArgumentError("ArgumentError: the new father and the node must have the same container");
				return;
			}
			// Check that the node is already defined as a child of the input value
			if (! value.hasChild(this)) {
				throw new ArgumentError("ArgumentError: the new father must have defined this node as a child before to update the node's father");
				return;
			}
			// Unreference this node as a child of its previous father
			if (this.father) {
				this.unReferenceMeFromFather();
			}
			// If this node is the root of the common container, update the root of
			// the container with the ancestor of the input value
			if (this.container.root == this) {
				this.container.clear();
				this.container.root = value.ancestor;
			}
			// Update with the input value
			this._father = value;
		}
		
		/**
		 * Unlink this node from its current father
		 */
		private function unReferenceMeFromFather():void {
			if (this.father == null) {
				return;
			}
			for (var i:int=(this.father as TreeNode)._children.length-1; i>-1; --i) {
				if ((this.father as TreeNode)._children[i] != this) {
					continue;
				}
				(this.father as TreeNode)._children[i] = null;
				break;
			}
			this._father = null;
		}
		
		public function get ancestor():ITreeNode {
			return (this.father) ? this.father : this;
		}
		
		public function getChild(pos:uint):ITreeNode {
			// Check the validity of the index
			if (pos >= this._children.length) {
				throw new ArgumentError("ArgumentError: invalid position for an index of a "+this.container.nodeWidth+"-tree");
				return null;
			}
			return this._children[pos];
		}
		public function setChild(pos:uint, value:ITreeNode):void {
			// Check the validity of the index
			if (pos >= this._children.length) {
				throw new ArgumentError("ArgumentError: invalid position for an index of a "+this.container.nodeWidth+"-tree");
				return;
			}
			// Manage the case of a child setted to null (if exists, the current whole sub-tree will be destroyed)
			if (value == null) {
				if (this._children[pos]) {
					this._children[pos].destroy();
				}
			} else {
				// Check the validity of the container (and so of the nodeWidth)
				if (value.container != this.container) {
					throw new ArgumentError("ArgumentError: invalid container, the new child and the node must have the same container");
					return;
				}
			}
			// Update the child
			this._children[pos] = value;
		}
		
		public function get validChildren():Vector.<ITreeNode> {
			var _validChildren:Vector.<ITreeNode> = new Vector.<ITreeNode>();
			var cl:uint = this._children.length;
			for (var i:int=0; i<cl; ++i) {
				if (this._children[i]) {
					_validChildren.push(this._children[i]);
				}
			}
			return _validChildren;
		}
		
		public function equals(node:ITreeNode):Boolean {
			if (! this.valueEquals(node.nodeValue)) {
				return false;
			}
			for (var i:int=this._children.length-1; i>-1; --i) {
				if (! this._children[i].equals(node.getChild(i))) {
					return false;
				}
			}
			return true;
		}
		
		public function get depth():uint {
			if (this._children.length == 0) {
				return 1;
			} else {
				var _maxdepth:uint=0, _depth:uint;
				for (var i:int=this._children.length-1; i>-1; --i) {
					_depth = (this._children[i]) ? this._children[i].depth : 0;
					if (_depth > _maxdepth) {
						_maxdepth = _depth;
					}
				}
				return 1 + _maxdepth;
			}
		}
		
		public function clear():void {
			// the nodeValue and the container are NOT changed
			this.father = null;
			for (var i:int=this._children.length; i>-1; --i) {
				if (this._children[i]) {
					this._children[i] = null;
				}
			}
		}
		
		public function destroyChildren():void {
			for (var i:int=this._children.length; i>-1; --i) {
				if (this._children[i]) {
					this._children[i].destroy();
					this._children[i] = null; // redundant with the indirect "this._children[i].father = null;" but more safe ;-)
				}
			}
		}
		
		public function destroy():void {
			// Destroy the children
			this.destroyChildren();
			// Clear the node
			this.clear();
			// Destroy the node
			this.nodeValue = null;
			this.container = null;
			//delete this._children;
			this._children = null;
		}
		
	}
}