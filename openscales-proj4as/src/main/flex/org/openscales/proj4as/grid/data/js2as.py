#!/usr/bin/python

import re
import os

def make(rezDirectory,catName,targetDirectory):
    
    gdName=catName.replace(".js","");
    objName=gdName.replace(".","");
    objName=objName.upper();
    pjCatFilename = os.path.join(rezDirectory, catName);
    pjCat = open(pjCatFilename,'r');

    l = pjCat.readline()
    newline_fn = os.path.join(targetDirectory, "ProjGrid"+objName+".as")
    file_cont = 'package org.openscales.proj4as.grid\n'
    file_cont=file_cont+"{\npublic class ProjGrid"+objName;
    file_cont=file_cont+" {\nstatic public function grid():Object {\n var myreturn:Object =" 
    while len(l) != 0:
        
        l=l.replace("Proj4js.grids[", "")
        l=l.replace("]=", "")
        l=l.replace(gdName,"");
        l=l.replace(" ", "")
        l=l.replace("],[", "],\n[")
        l=l.replace(",\"", ",\n\"")
        l=l.replace("\"\"", "") 
        file_cont=file_cont+l
        l = pjCat.readline()
    file_cont=file_cont+"return myreturn;\n}\n}\n}";
    file(newline_fn,'w').write(file_cont)
    pjCat.close()

import sys
sys.path.append(".")

SUFFIX_JAVASCRIPT = ".js"

resourcesDirectory = "source"
targetDirectory = ".."

if len(sys.argv) > 1:
    resourcesDirectory = sys.argv[1]

if len(sys.argv) > 2:
    targetDirectory = sys.argv[2]

print "Generating Proj4as grids."


resourcesDirectory_name_len = len(resourcesDirectory)
for root, dirs, filenames in os.walk(resourcesDirectory):
      for filename in filenames:
            if filename.endswith(SUFFIX_JAVASCRIPT) and not filename.startswith("."):
                  filepath = os.path.join(root, filename)[resourcesDirectory_name_len+1:]
                  filepath = filepath.replace("\\", "/")
                  make(resourcesDirectory,filepath,targetDirectory)
                
print "Done."

