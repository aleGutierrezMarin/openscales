package org.openscales.core.basetypes
{
	
	import org.flexunit.Assert;
	import org.flexunit.asserts.assertEquals;
	import org.openscales.core.basetypes.trees.*;
	
	public class TreeTest
	{
		
		[Test]
		public function testBinaryTree() : void {
			// Check the state of the tree at the creation
			/*
			var tree:ITree = new BinaryTree();
			Assert.assertNotNull(tree);
			Assert.assertEquals(tree.nodeWidth, 2);
			Assert.assertNull(tree.root);
			Assert.assertEquals(tree.depth, 0);
			
			// Create nodes using the tree as their container
			var node1:TreeNode = new TreeNode(tree, 14);
			Assert.assertEquals(node1.container, tree);
			Assert.assertEquals(node1.nodeValue, 14);
			var node2:TreeNode = new TreeNode(tree, 8);
			Assert.assertNull(tree.root);
			Assert.assertEquals(tree.depth, 0);
			
			// Define and change the root of the tree
			tree.root = node1;
			Assert.assertEquals(tree.root, node1);
			Assert.assertEquals(tree.depth, 1);
			tree.clear();
			Assert.assertNull(tree.root);
			Assert.assertEquals(tree.depth, 0);
			tree.root = node1;
			tree.root = node2; // previous tree.root will be destroyed
			Assert.assertEquals(tree.root, node2);
			Assert.assertEquals(tree.depth, 1);
			Assert.assertEquals(node1.nodeValue, null);
			
			// Check the state of the tree after destroy
			tree.destroy();
			Assert.assertEquals(tree.nodeWidth, 2);
			Assert.assertNull(tree.root);
			Assert.assertEquals(tree.depth, 0);
			Assert.assertEquals(node2.nodeValue, null);
			
			// Define an other tree and a node in its container to test the independency of the two trees
			var tree2:ITree = new BinaryTree();
			var node3:TreeNode = new TreeNode(tree2, -3);
			Assert.assertEquals(node3.container, tree2);
			tree.root = node3;
			Assert.assertNull(tree.root);
			Assert.assertEquals(node3.container, tree2);
			
			// Move a node from a tree to an other tree
			tree2.root = node3;
			Assert.assertEquals(tree2.root, node3);
			node3.container = tree;
			Assert.assertNull(tree2.root);
			Assert.assertEquals(node3.container, tree);
			tree.root = node3;
			Assert.assertEquals(tree.root, node3);*/
		}
		
		[Test]
		public function testTreeNode() : void {
			// TODO
		}
		
		[Test]
		public function testQuadTree() : void {
			// TODO
		}
		
	}
}