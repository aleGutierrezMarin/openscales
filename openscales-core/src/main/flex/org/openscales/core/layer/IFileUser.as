package org.openscales.core.layer
{
	
	/**
	 * Classes that implement the IFileUser interface are classes that may manipulate files. 
	 */ 
	public interface IFileUser
	{
		/**
		 * The extensions that may be accepted for the file (xml, rss, ...)
		 */ 
		function get acceptedFileExtensions():Vector.<String>;
	}
}