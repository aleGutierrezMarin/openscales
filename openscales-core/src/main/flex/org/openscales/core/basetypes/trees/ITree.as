package org.openscales.core.basetypes.trees
{
	/**
	 * Tree interface.
	 * Interface describing a generic tree.
	 *
	 * @author aba
	 */
	public interface ITree
	{
		
		/**
		 * Maximum number of children for each node (>0)
		 */
		/*static*/ function get nodeWidth():uint;
		
		/**
		 * Root of the tree.
		 * Changing the root of the tree will destroy the nodes of the old tree.
		 * Use the "clear" function before if you do not want to destroy the "old" nodes.
		 */
		function get root():ITreeNode;
		function set root(value:ITreeNode):void;
		
		/**
		 * Depth of the tree
		 */
		function get depth():uint;
		
		/**
		 * Clear the tree: the nodes are NOT affected
		 */
		function clear():void;
		
		/**
		 * Destroy the tree and all these nodes
		 */
		function destroy():void;
		
		/**
		 * Test the equality of this tree with a given tree
		 * @param tree a tree with which to compare this node
		 */
		function equals(tree:ITree):Boolean;
		
	}
}
