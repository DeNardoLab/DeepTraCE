# DeepTraCE


![trailmap_fig2_tophalf](https://user-images.githubusercontent.com/52982623/150889628-e079e5a2-8d12-432c-a969-20b63e1525d3.png)
![Figure2_bottomhalf](https://user-images.githubusercontent.com/52982623/150889800-59ff6e0c-d8fa-4727-bf64-eb5243fc120b.png)

**DeepTraCE** is a deep-learning based pipeline for analysis of whole-brain light sheet microscopy images. Our pipeline is optimized for recognition of cortical axons and largely builds on TRAILMAP (Friedmann et. al., 2020). The final output of this pipeline includes skeletonized images of the axon segmentations from each brain, which have been transformed to a common atlas, as well as quantifications of labeling density in each brain region.

**This is for the original step-by-step version of DeepTraCE. A streamlined version of the pipeline, all in python, is available at https://github.com/jcouto/DeepTraCE/tree/gui

Code written by Michael Gongwer and Drew Friedmann.

Models can be found at https://ucla.box.com/s/zc4ib0mo297h3wdbbjdd237r2mzd1crf

Sample data can be found at https://ucla.box.com/s/2bm6disejkwrmspugh8s4bmc3yq4p531

**DeepTraCE Pipeline**


**Step 1: Imaging**

In our protocol, we image axons in the 640nm channel and autofluorescence in the 488nm channel. This generates two stacks of individual TIF images separated into two folders, one for each channel (examples below). We will be using the 640nm channel to extract the axons and the 488nm channel to align the brains to an atlas, which allows automated quantification by brain region.

<pre>
488nm (autofluorescence)	         640nm (axons)        
<img src="https://user-images.githubusercontent.com/52982623/150884325-964e3445-2c41-4307-a399-f067f617367b.png" width="200">               <img src="https://user-images.githubusercontent.com/52982623/150884307-d6850d3c-bff5-4dc4-8e40-d672646ae1c2.png" width="200">
</pre>

**Step 2: TRAILMAP**

TRAILMAP is the Deep-Learning pipeline used to convert the raw 640nm image stack to an image stack of the same size containing a map of the probability that each pixel contains an axon.  Pixel values of 1 indicate high likelihood that an axon is contained in that region, and pixel values of 0 indicate low likelihood. This probability is calculated using a 3D convolutional network that has been trained to recognize axons.

<pre>
640nm (axons) 			    	 Probability map (TRAILMAP output)        
<img src="https://user-images.githubusercontent.com/52982623/150884307-d6850d3c-bff5-4dc4-8e40-d672646ae1c2.png" width="200">               <img src="https://user-images.githubusercontent.com/52982623/150887072-0f8c9b11-595d-415d-9779-f373741df6d2.png" width="200">
</pre>


In the DeepTraCE pipeline, we perform this segmentation three times, once each with three models optimized to recognize axons in varying levels of depth in the tissue. The segmentation from these three models will be concatenated in a later step.

1. Install TRAILMAP & install necessary dependencies (if this is already done skip to part b)
   1. Clone GitHub repository to drive
   1. Open Anaconda Prompt (install Anaconda if not already installed)
   1. Create an environment for TRAILMAP and install dependencies using the following line:

conda create -n trailmap\_env tensorflow-gpu=2.1 opencv=3.4.2 pillow=7.0.0

\*for troubleshooting see readme on github

1. Select model to use for axon segmentation
   1. From the GitHub repository, open segment\_brain\_batch.py in a python editor and in line 18 change the path to the location of the model weights you would like to use
1. Activate TRAILMAP environment & enter TRAILMAP directory
   1. Open Anaconda prompt
   1. Activate environment using the following line:

conda activate trailmap\_env

1. Enter directory using the following, using the actual directory in place of the one shown:

cd *C:/Users/Michael/Documents/TRAILMAP*

1. Run TRAILMAP inference step on the 640nm channel of the brain of interest
   1. Enter the following line, replacing input\_folder1+ with the directories for the brain(s):

python segment\_brain\_batch.py *input\_folder1 input\_folder2 input\_folder3*

1. This outputs the axon probability map to the same directory as the original folder, but with “seg-” added to the beginning of the folder name.
1. Repeat segmentation with other models
   1. Change the name of the segmentation folders so they are not overwritten when you re-segment the brain with a new model (example: change name of the folder “seg-640\_NAc1” to “model1\_seg-640\_NAc1”)
   1. Repeat steps b through d above using a the other models

NOTE: In windows explorer, to copy the path of a file, use Shift+RightClick and select “copy as path”

**Step 3: Scale brain to a 10μm space and convert to 8-bit using ImageJ**

From this point forward, we will want our brains in a 10μm space (where each voxel is 10μmx10μmx10μm), as this is the resolution of the atlas we use for registration. We perform this downscaling step in ImageJ using values calculated based on our imaging parameters, and if you would like to do this in batch we have provided a macro for this purpose. In addition, this macro converts the files to 8bit as opposed to 16- or 32- bit, as 8-bit images are best compatible with future steps. If you would like to do this manually, use the Image->Scale and Image->Type functions in ImageJ, but the instructions below are for the use of a macro.

These steps must be performed on both the 488nm raw channel and the probability map from trailmap, as these are the two images that will feed into the next step of the pipeline.

1. Open ImageJ (NOTE: our macros are compatible with ImageJ v1.52 but not v1.53)
1. Click “plugins” → “macros” → “edit” and open the macro file for brain scaling (macro 1)
1. In line 2, add the path for the first **.tif file** of each brain you want to analyze to the array, separating them by commas
   1. You will want to scale both the TRAILMAP output and the 488nm channel for each brain. If you are planning to concatenate multiple models, you will need to do this for all of the probability maps.
   1. NOTE: macros are very finicky; you may need to change all the \ in the directories to \\
1. Run the macro using ctrl-R
1. This will output the brain to a separate folder in the same directory, with “\_scaled” on the end

**Step 3b (optional step to improve alignment): Manually rotate each brain in ImageJ**

We have found that elastix, the program used to align the brain with an atlas, particularly struggles with alignment of brains that require large degrees of rotation around the X, Y, or Z axis. To account for this, we incorporated a step where we manually rotate the brains to be flush with the atlas using an ImageJ plugin called TransformJ. In our imaging protocol, we image slightly past the midline, which allows visualization of blood vessels along the midline in the autofluorescence channel. Our goal in this rotation is to make those midline veins all appear in the same z plane, thus making the brain flush with the atlas.

1. Install ImageScience’s TransformJ (<https://imagescience.org/meijering/software/transformj/>)
   1. In ImageJ, go to help->update
   1. Click “add update site,” check “ImageScience,” and close. After restarting ImageJ, TransformJ should be installed.
1. Open 10um scaled 488nm image in ImageJ
1. Assess rotation of image by scrolling to the midline and checking whether all blood vessels are visible in the same z plane or if they are rotated. If they are rotated, assess which direction the image needs to be rotated to flatten them into a single plan. 
1. Click plugins->ImageScience->TransformJ->TransformJ Rotate
1. Select approximate degrees of rotation for each axis. 
   1. Positive rotation in the X axis brings top of screen toward you
   1. Positive rotation in the Y axis brings right side of screen towards you
   1. Positive rotation in the Z axis brings top of screen to the right (clockwise)
1. Click “ok” to run the rotation. Check if the blood vessels are now aligned. If not, repeat the process with different angles of rotation until they all appear in the same plane. **Record the angles of rotation used for the final image.**
1. Make a substack of the rotated image in the z plane (image->stacks->tools->create substack) to crop out black borders that do not contain brain tissue. **Record the slices that were included in the substack.**
1. Save the image as “10umrc.tif” (10um image, rotated and cropped).
1. Open the 10um segmented 640nm image in ImageJ and apply the **exact same transformation**.

<pre>
Midline blood vessels before alignment		Midline blood vessels after manual alignment     
<img src="https://user-images.githubusercontent.com/52982623/150887306-a08a53c4-1e93-45a0-b090-d32f319173b9.png" width="200">                       <img src="https://user-images.githubusercontent.com/52982623/150887325-a3164309-9258-4619-861f-f236a6552d8d.png" width="200">
</pre>




**Step 4: Register brain autofluorescence channel (488nm) to atlas using Elastix**

Alignment/registration is the process of taking your raw data and warping it such that it is aligned with a standardized reference atlas. This is performed in a command-line-based program called Elastix (<https://elastix.lumc.nl/>). The first step involves aligning the autofluorescence channel to an atlas image, and the next step involves applying the exact same transformation to the channel containing the label of interest, which is done in Transformix (a subsection of the Elastix program). Once your brain is aligned to an atlas, you then know which groups of pixels correspond to each brain region, and this information can be used for quantification and visualization.

1. Open Command Prompt. If elastix is not installed, follow the directions in the elastix manual.
1. Ensure that you have the 10um cropped atlas and the affine and bspline parameter files
1. Run the following command, replacing the placeholders with the correct path, using affine as parameter 1 and bspline as parameter 2

elastix -f *directory/fixedImage.ext* -m *directory/movingImage.ext* -out *outputDirectory* -p *directory/parameterFile1.txt* -p *directory/parameterFile2.txt*

1. The fixed image is the cropped 10um atlas, and the moving image is the scaled, rotated, and cropped 488nm channel. The “moving” image will be registered to match the fixed image.
1. This will output a registered brain as well as some new parameter files to the specified directory.
1. Verify alignment by opening “result.mhd” alongside the average\_template file and checking to see that the aligned 488nm channel looks the same as the average template.


<pre>
Pre-alignment				   Post-alignment  
<img src="https://user-images.githubusercontent.com/52982623/150887733-22cc6e67-eb54-44fc-bfaf-4d6d437d27a4.jpg" width="200">                <img src="https://user-images.githubusercontent.com/52982623/150887767-31aaef83-daaf-4333-aa89-05d46afb669a.jpg" width="200">
</pre>

**Step 5: Register the TRAILMAP output (probability map) to the atlas using Transformix**

As previously mentioned, once our autofluorescence channel is aligned to the atlas, we must then align the probability map(s) to the atlas as well. We do this in **Transformix**, a subsection of the Elastix program,** by applying the exact same transformation to the probability map(s) as we did the autofluorescence channel.

1. Locate the “TransformParameters.0.txt” file in the elastix output directory
1. Within the command prompt, run the following command, replacing the placeholders with the correct path

transformix -in *directory/inputImage.ext* -out *outputDirectory* -tp *directory/TransformParameters.0.txt*

1. The input image is the scaled, rotated, and cropped TRAILMAP output file. If you are planning to concatenate multiple models, you will need to perform this on the probability map of each model.
1. This will output the transformed axon probability map as “result.mhd”

<pre>
Pre-alignment				   Post-alignment  
<img src="https://user-images.githubusercontent.com/52982623/150889034-671234a8-7196-4b03-b552-410220ffea23.jpg" width="200">                <img src="https://user-images.githubusercontent.com/52982623/150889052-ce6c7bb8-81c1-4ccc-a622-285b94362fc1.jpg" width="200">
</pre>


**Step 6: Convert .mhd file to 8-bit .tif file using ImageJ**

This is a simple image processing step to put the file in a matlab-friendly format (.tif). This step is also an optimal time to adjust all the models such that their brightness levels are comparable. If you elect to do this, use the same brightness parameters across all images from a single model. For example, in our protocol we readjust the min/max intensity values (using ctrl-shift-c) of Model 1 (for superficial regions) to 0 and 200 then click “apply” to adjust the values. If you would like to skip this step and use a macro instead, instructions are below.

1. Open ImageJ
1. Click “plugins” → “macros” → “edit” and open the macro file for this step (macro 2)
1. In line 2, add the path to the **.mhd file** from the transformix output of each brain to the array, separating them by commas
   1. NOTE: macros are very finicky; you may need to change all the \ in the directories to \\
1. Run the macro using ctrl-R
1. This will output the brain as FP.tif to the same folder as the .mhd file

**Step 7: Concatenate model segmentations**

This step is only necessary if you are using different models to segment different brain regions. To do this, we take advantage of the fact that each coordinate in all of our transformed images now corresponds with a particular brain region, which is contained in the annotation file from the atlas. From this, we can assign pixels from each of the three segmentations to a final image in which a single segmentation is used for each brain region.


<pre>
Single Model				   Concatenated Models
<img src="https://user-images.githubusercontent.com/52982623/150889190-36e07e25-dc32-47db-8ab4-46e225ee2043.png" width="200">                <img src="https://user-images.githubusercontent.com/52982623/150889207-2141b2b1-e3e4-4742-a3b5-9692baa5e5ad.png" width="200">
</pre>


		
1. Arrange model segmentations such that they are all in the same folder for each brain with consistent file names.
1. Open concatenate-models.m in MATLAB
1. Change “regions” in line 7 to match the file path of the atlas .nrrd file
1. Change “folders” in line 10 to the directory containing the three model segmentations
1. Change line 27 to the file name of the segmentation you would like to use as the default (in our case, model 2. Change lines 33 and 39 to the segmentations you would like to apply to defined brain regions. Indicate the regions where you would like to apply these respective models in lines 48 and 53.
1. Click run. This will output FP\_comb to the same directory as your non-concatenated model segmentations.

**Step 8: Create initial skeletons of the concatenated image in python**

Next, we begin the process of skeletonizing the axon segmentations. We incorporate this skeletonization step because upon light sheet imaging, the size of small fluorescent objects such as axons are amplified and thus occupy more pixels in the raw image data than they truly occupy in reality. Skeletonizing reduces the tracts of individual axons down to single-voxel thickness, accounting for this amplification. It is important that we complete this process at the latest possible step, as any transformation after this point would risk losing information from one-pixel-thick labeling.

The first step of this process involves binarizing the image, after which the binary image can be reduced down to single-voxel skeletons in 3D. To preserve variability in intensity values from the segmentation, we perform this skeletonization after binarizing at 8 different thresholds. The 8 resulting skeletons are then combined in the next step.


<pre>
Pre-skeletonization			   Post-skeletonization
<img src="https://user-images.githubusercontent.com/52982623/150889207-2141b2b1-e3e4-4742-a3b5-9692baa5e5ad.png" width="200">                <img src="https://user-images.githubusercontent.com/52982623/150889292-6cdf8646-5564-4600-a7b6-84838afddfc8.png" width="200">
</pre>


1. Open Anaconda Prompt
1. Enter the directory containing skeletonize\_data\_batch\_2.py with the following command, using the actual directory in place of the one shown:

cd */home/USERNAME/Documents/TRAILMAP*

3. Enter the following line, replacing input\_folder1+ with the folder containing FP\_comb.tif for each brain:

python skeletonize\_data\_batch\_2.py *input\_folder1 input\_folder2 input\_folder3*

4. This will output a series of folders to the folder containing FP\_comb.tif for each brain, which will be used in the following step.

**Step 9: Combine these skeletons using MATLAB**

Now that we have 8 folders for each brain, each using a different threshold for skeletonization, we must combine these skeletons into a single skeleton, with brighter pixels corresponding to the axons that met higher binarization thresholds. This preserves the ability to use different thresholds even after data is skeletonized. 

Another part of this code removes small objects from the skeletonized image. Given that the axons of interest are typically long and would span several pixels throughout a whole-brain image, an effective technique for removing artifacts that are unlikely to be axons is the removal of skeletonized objects under a particular length. This is incorporated into this matlab step. 

1. Open skeletoncombiner.m in MATLAB
1. Change the directory in “folders” in line 7 to the folder containing FP\_comb.tif
1. Click run. This should output the combined skeleton into a folder called “sizeCut\_slices”

**Step 10: Adjust pixel values to 15 specific numbers using ImageJ**

For the sake of simplifying our quantification and visualization code, we found it useful to set each skeletonized image such that only 15 specific pixel values were used. This step includes an imagej macro that performs this automatically.

1. Open ImageJ
1. Click “plugins” → “macros” → “edit” and open the macro file for this step (macro 3)
1. In line 2, add the path for the first **.tif file** of each brain you want to analyze to the array, separating them by commas
   1. NOTE: macros are very finicky; you may need to change all the \ in the directories to \\
1. Run the macro using ctrl-R
1. This will output the brain as “FP\_skel.tif” to the same folder as FP.tif


**Step 11: Quantify the Axon Counts by region**

We now have our final transformed images with skeletonized axons. We can thus extract the number of pixels in each brain region that contain a skeletonized axon above a particular intensity threshold. This step provides an excel file with the raw pixel count by region in addition to data normalized in three different ways: normalized solely by region volume, normalized by total fluorescence across the brain, and normalized by both region volume and total fluorescence (which is what we use for our analyses).

1. Open regionQuant.m in MATLAB
1. Change “regions” and “annotated” in lines 7 and 11 to match the file paths of the atlas .nrrd file and the annotation .csv file, respectively.
1. Change “folders” in line 26 to the directory containing FP\_skel.tif from the previous step
1. If you’d like to change the threshold, change lines 74, 85, and 95
1. Click run. This will output AxonCounts.xlsx to the same directory as FP\_skel.tif
