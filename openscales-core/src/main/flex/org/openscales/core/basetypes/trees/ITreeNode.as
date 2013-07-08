package org.openscales.core.basetypes.trees
{
	/**
	 * TreeNode interface
	 * Interface to describe a generic node of a tree
	 *
	 * @author aba
	 */
	public interface ITreeNode
	{
		
		/**
		 * Value of the node
		 */
		function get nodeValue():Object;
		function set nodeValue(value:Object):void;
		
		/**
		 * Get the value of one of the children of the node.
		 * Similar to getChild(pos).nodeValue but created for more convenience (no need to test the existence of the child).
		 */
		function getChildValue(pos:uint):Object;
		/**
		 * Get the value of one of the children of the node.
		 * Similar to getChild(pos).nodeValue=value if the child already exist and if the input value is not null.
		 * If the child does not exist, it is created automatically.
		 * It the input value is null, the sub-tree defined by the child is automatically destroyed.
		 */
		function setChildValue(pos:uint, value:Object):void;
		
		/**
		 * Test the equality of the value of this node with a given object
		 * @param value an object with which to compare this node 
		 */
		function valueEquals(value:Object):Boolean;
		
		function hasChild(node:ITreeNode):Boolean;
		function hasChildValue(value:Object):Boolean;
		
		/**
		 * The tree or the list containing the node
		 */
		function get container():ITree;
		
		/**
		 * The father of the node (null if this node is the root of the container).
		 * If the tree is a list (container.nodeWidth==1), this function returns
		 * the previous node of the list.
		 */
		function get father():ITreeNode;
		
		/**
		 * The ancestor of the node (this if the node has no father) ; it should be
		 * the root of the container when all the nodes are in a stable state).
		 */
		function get ancestor():ITreeNode;
		
		/**
		 * One of the children of the node.
		 * A child can not be setted to null, use "destroy" instead
		 * @param pos position of the child to get/set 
		 */
		function getChild(pos:uint):ITreeNode;
		function setChild(pos:uint, value:ITreeNode):void;
		
		/**
		 * Vector of valid (not null) children of the node
		 */
		function get validChildren():Vector.<ITreeNode>;
		
		/**
		 * Test the equality of this node with a given node
		 * @param node a node with which to compare this node 
		 */
		function equals(node:ITreeNode):Boolean;
		
		/**
		 * The depth of the subtree from this node.
		 * If the tree is a list (container.nodeWidth==1), this function returns
		 * the length of the sub-list.
		 */
		function get depth():uint;
		
		/**
		 * Cleanup the link with other nodes (NOT recursive) but the nodeValue
		 * and the container are NOT changed
		 */
		function clear():void;
		
		/**
		 * Destroy (NOT just clear) the children
		 */
		function destroyChildren():void;
		
		/**
		 * Destroy the children then cleanup the node and destroy it.
		 * The nodeValue is NOT deleted, it is just setted to null.
		 * Be careful, after that the node will be in an invalid state and it
		 * will can not be reused !
		 * Consider to use "clear" instead.
		 */
		function destroy():void;
		
	}
}