package org.openscales.proj4as {
	
	import org.openscales.proj4as.grid.*;

	public class ProjGrid {

		static public function get(gridname:String):Object{
			switch(gridname)
			{
				case "null":
				{
					return ProjGridNULL.grid();
					break;
				}
				case "ntf_r93.gsb":
				{
					return ProjGridNTF_R93GSB.grid();
					break;
				}
				default:
				{
					
					trace("ProjGrid: "+gridname+" not found!");
					return null;
					break;
				}
			}
		}
		
		
	}
}