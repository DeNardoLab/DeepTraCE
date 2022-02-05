// Takes transformix output and converts to 10um .tif file
paths = newArray("D:\\TRAILMAP\\Brains\\cPL112623_scaled\\result.mhd", "D:\\TRAILMAP\\Brains\\cPL117251_scaled\\result.mhd", "D:\\TRAILMAP\\Brains\\cPL117252_scaled\\result.mhd", "D:\\TRAILMAP\\Brains\\cPLF_scaled\\result.mhd", "D:\\TRAILMAP\\Brains\\NAc326F_scaled\\result.mhd", "D:\\TRAILMAP\\Brains\\NAc326M_scaled\\result.mhd", "D:\\TRAILMAP\\Brains\\NAc132502_4_scaled\\result.mhd", "D:\\TRAILMAP\\Brains\\NAc1325023_scaled\\result.mhd", "D:\\TRAILMAP\\Brains\\VTA_1_Laser50_scaled\\result.mhd", "D:\\TRAILMAP\\Brains\\VTA325F_scaled\\result.mhd", "D:\\TRAILMAP\\Brains\\VTA1129M_scaled\\result.mhd", "D:\\TRAILMAP\\Brains\\VTA11291F_scaled\\result.mhd");
for (i=0; i<paths.length; i++) {
	path = paths[i];
	open(path);
	run("8-bit");
	parent = File.getParent(path);
	dir = File.getParent(parent) + File.separator + File.getName(parent) + "/";
	name = "FP_cort.tif";
	saveAs("Tiff", dir+name);
}