// Takes combined skeletons from a brain and converts to a single 8-bit .tif file with specific pixel values compatible with quantification & visualization code.
paths = newArray("D:\\TRAILMAP\\Brains\\cPL112623\\cPL112623_scaled\\skel_combined\\a_00000.tif");
for (i=0; i<paths.length; i++) {
	path = paths[i];
	run("Image Sequence...", "open=path sort");
	run("Brightness/Contrast...");
	setMinAndMax(0, 15);
	run("Apply LUT", "stack");
	run("Scale...", "x=- y=- z=- width=120 height=120 depth=100 interpolation=None process create");
	parent = File.getParent(path);
	dir = File.getParent(parent) + "/";
	name = "FP_skel.tif";
	saveAs("Tiff", dir+name);
}