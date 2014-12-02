package org.openscales.core.format.gml.writer
{
	import org.openscales.core.feature.Feature;

	public interface IGMLWriter
	{
		function write(featureCol:Vector.<Feature>,
					   geometryNamespace:String,
					   featureType:String,
					   geometryName:String):XML;
	}
}