// Takes unscaled data and scales it to a 10um space. Also converts to 8-bit.
paths = newArray("D:\\TRAILMAP\\Brains\\cPL112623\\210728_cPL112623_640_s3_0_8x_07-46-52\\07-46-52_cPL112623_640_s3_0_8x_UltraII_C00_xyz-Table Z0000.ome.tif");
for (i=0; i<paths.length; i++) {
	path = paths[i];
	run("Image Sequence...", "open=path sort use");
	run("Scale...", "x=0.40625 y=0.40625 z=0.3 interpolation=Bilinear average process create");
	run("8-bit");
	parent = File.getParent(path);
	dir = File.getParent(parent) + File.separator + File.getName(parent) + "_scaled";
	File.makeDirectory(dir);
	name = "10um";
	saveAs("Tiff", dir+File.separator+name);
}
