#!/usr/bin/env bash

##
##This script projects the Oxford-Subthalamic-connectivity Atlas into Subject Space using flirt & fnirt
##
## It WORKS ONLY after running pet_onto_standard.sh (as we need some of the files created there)
## I already have the linear transformations (flirt) T1 to MNI152 and the inverse (T1_lin_MNI152.mat and MNI152_lin_T1.mat), and also the non-linear transformation  (fnirt) of T1 to MNI152 (T1_nl_MNI152.reg)
##

## Subject:
SUBJECT_ID=$1 
echo $SUBJECT_ID

## PET data dir and file: 
PET_DIR='/autofs/cluster/hookerlab/Users/Cristina/Huntington_Corrected/PBR/PET_onto_standard'

cd ${PET_DIR}/${SUBJECT_ID}/PET-2-standard/

## I need to calculate the inverse transf., ie, MNI to T1:

#echo 'calculating the transformation MNI to T1....'
invwarp --ref=T1-2mm_orientOK.nii --warp=T1_nl_MNI152.reg --out=MNI152_nl_T1.reg

## And then apply that transf to the Atlas I want in subject space:
#echo 'applying the transformation to the Atlas....'

applywarp --ref=T1-2mm_orientOK.nii --in=/autofs/cluster/hookerlab/Users/Cristina/Atlases/Thalamus/Thalamus-maxprob-thr50-2mm.nii.gz --warp=MNI152_nl_T1.reg --out=Thalamus-maxprob-thr50-2mm_in_T1_space --interp=nn

mri_convert Thalamus-maxprob-thr50-2mm_in_T1_space.nii.gz Thalamus-maxprob-thr50-2mm_in_T1_space.nii 
