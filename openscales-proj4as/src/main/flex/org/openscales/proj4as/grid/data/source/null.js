Proj4js.grids["null"]={
    "ll": [-3.14159265, -1.57079633],   // lower-left coordinates in radians (longitude, latitude):
    "del":[ 3.14159265,  1.57079633],   // cell's size in radians (longitude, latitude):
    "lim":[ 3, 3],                      // number of nodes in longitude, latitude (including edges):
    "count":9,                          // total number of nodes
    "cvs":[                             // shifts : in ntv2 reverse order : lon, lat in radians ...
        [0.0, 0.0], [0.0, 0.0], [0.0, 0.0], // for (lon= 0; lon<lim[0]; lon++) {
        [0.0, 0.0], [0.0, 0.0], [0.0, 0.0], //   for (lat= 0; lat<lim[1]; lat++) { p= cvs[lat*lim[0]+lon]; }
        [0.0, 0.0], [0.0, 0.0], [0.0, 0.0]  // }
    ]
};