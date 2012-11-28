package org.openscales.proj4as.grid
{
public class ProjGridNULL {
static public function grid():Object {
 var myreturn:Object ={
"ll":[-3.14159265,-1.57079633],//lower-leftcoordinatesinradians(longitude,latitude):
"del":[3.14159265,1.57079633],//cell'ssizeinradians(longitude,latitude):
"lim":[3,3],//numberofnodesinlongitude,latitude(includingedges):
"count":9,//totalnumberofnodes
"cvs":[//shifts:inntv2reverseorder:lon,latinradians...
[0.0,0.0],
[0.0,0.0],
[0.0,0.0],//for(lon=0;lon<lim[0];lon++){
[0.0,0.0],
[0.0,0.0],
[0.0,0.0],//for(lat=0;lat<lim[1];lat++){p=cvs[lat*lim[0]+lon];}
[0.0,0.0],
[0.0,0.0],
[0.0,0.0]//}
]
};return myreturn;
}
}
}