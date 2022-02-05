# -*- coding: utf-8 -*-
"""
Created on Thu Jul 23 20:42:45 2020

@author: Michael
"""

import os
import sys
import matplotlib.pyplot as plt
from skimage.morphology import skeletonize, skeletonize_3d
import scipy.io as sio
import glob
import argparse
import tifffile as tiff
import numpy as np
from tqdm import tqdm 

parent = sys.argv[1:]

for directory in parent:
        # print(directory)
        # fnp = '/*tif*'
        # fns = glob.glob(directory+fnp)
        # fns = np.sort(fns)
        # n = len(fns)
        # print('read %d files'%n)
        
        # #read imgs and store it in f
        # for i,fn in tqdm(enumerate(fns)):
        #     f0 = tiff.imread(fn)
        #     if i ==0:
        #         f = np.zeros((f0.shape[0],f0.shape[1],n))
        #     f[:,:,i] = f0.copy()
        
        fn = directory+'/10um.tif'
        f = tiff.imread(fn)
        f = f.transpose(1,2,0)

    
        #create binary matrices and skeletonize them
        nbins = 8
        ii = np.linspace(3,nbins+2,nbins)
        bw = np.zeros((f.shape[0],f.shape[1],f.shape[2]),dtype = np.bool)
        subsetBin = np.zeros_like(f,dtype = np.bool)
        
        def savefile(directory,thres,bw):
            n = bw.shape[2]
            directory1 = directory + '/thres_%f'%thres
            if os.path.exists(directory1) ==0:
                os.mkdir(directory1)
            for i in tqdm(range(f.shape[2])):
                tiff.imsave(directory1+'/%05d.tif'%i,np.int8(bw[:,:,i]))
            return True
        
        for i in tqdm(range(nbins)):
            j = ii[nbins-1-i]
            thres = (j-1.)/(nbins+2)
            subsetBin[f/255>thres] = 1
            bw = skeletonize_3d(subsetBin)
            savefile(directory,thres,bw)