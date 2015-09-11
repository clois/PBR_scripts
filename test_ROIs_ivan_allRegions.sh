#!/usr/bin/env bash
##
## USE FS LABELS to OBTAIN ROI PET VALUES
## Generate FS segmented labels with FS recon -all
## This generates in the ...\FS\subjects\SubjectID\mri directory several files, including aparc+aseg.mgz

## FS subjects dir and subject:
SUBJECT_ID=$1 
echo $SUBJECT_ID
SUBJECTS_DIR='/autofs/cluster/hookerlab/collaborators/PBR/Rosas/PBR/FS/subjects'
#setenv SUBJECTS_DIR /autofs/cluster/hookerlab/collaborators/PBR/Rosas/PBR/FS/subjects

## PET data dir and file: 
PET_DIR='/autofs/cluster/hookerlab/Users/Cristina/Huntington_Corrected/PBR/PET_onto_standard'
PET_file=$2

IS_PATIENT=$3

OUTPUT_DIR=${PET_DIR}/${SUBJECT_ID}/ROIs

# Make dir for this subject, copy the labels, MPRAGE and PET niftis file there, and move to that directory
mkdir -p ${OUTPUT_DIR}
mkdir -p ${PET_DIR}/ROI_Results
cp ${SUBJECTS_DIR}/${SUBJECT_ID}/mri/orig/001.mgz ${OUTPUT_DIR}

# Load_the Freesurfer env
FREESURFER="/usr/local/freesurfer/nmr-stable53-env"
if !([ -e $FREESURFER ]); then
     echo "Freesurfer not found at $FREESURFER."
     exit 1
fi

tcsh -c "source $FREESURFER; mri_convert ${PET_DIR}/${SUBJECT_ID}/PET-2-standard/${PET_file}.nii.gz ${OUTPUT_DIR}/${PET_file}.nii; 
mri_convert ${SUBJECTS_DIR}/${SUBJECT_ID}/mri/aparc+aseg.mgz ${OUTPUT_DIR}/aparc+aseg.nii"

## Obtain a mask for the region from aparc+aseg.mgz VOI file (different VOI regions are assigned different values, so we obtain the one of interest using appropriate lower and upper thresholds. These can be obtained from the FreeSurferColorLUT tables or opening the VOI fie with any image viewer)

cd ${OUTPUT_DIR}

process_region()
{
    
    REGION=$1
    LEFTLOWER=$2
    LEFTUPPER=$3
    RIGHTLOWER=$4
    RIGHTUPPER=$5
    IS_PATIENT=$6

    fslmaths ${OUTPUT_DIR}/aparc+aseg.nii -thr $LEFTLOWER -uthr $LEFTUPPER ${REGION}_left.nii
    fslmaths ${OUTPUT_DIR}/aparc+aseg.nii -thr $RIGHTLOWER -uthr $RIGHTUPPER ${REGION}_right.nii
    
    ## Add left and right regions to obtain bilateral values, and binarize. 
    fslmaths ${REGION}_left.nii.gz -add ${REGION}_right.nii.gz -bin ${REGION}_bi.nii 
    
    ## Reslice created file to match MPRAGE (001.mgz) dimensions --(nearest neighbour)
    tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz -rt nearest ${REGION}_bi.nii.gz ${REGION}_bi_resliced.nii"
    
    ## Eliminate nan values from the image (otherwise the computation of mean and std doesn't work properly and the outputs are nan)
    fslmaths ${REGION}_bi_resliced.nii -nan ${REGION}_bi_mask.nii
    
    ## Reslice PET image to match MPRAGE dimensions --(trilinear)
    tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz  ${OUTPUT_DIR}/${PET_file}.nii r${PET_file}.nii"
    
    ## Obtain mean and std of the PET image using the mask created above, and output to a txt file
    MEAN_AND_STD=`fslstats r${PET_file}.nii -k ${REGION}_bi_mask.nii.gz -m -s`
    echo ${SUBJECT_ID} ${MEAN_AND_STD} ${IS_PATIENT}>> ${PET_DIR}/ROI_Results/${REGION}_roi_values.txt

    ####################################################
    ## If left and right wanted separately:
    ## Binarize regions 
	fslmaths ${REGION}_left.nii.gz -bin ${REGION}_left_bin.nii
	fslmaths ${REGION}_right.nii.gz -bin ${REGION}_right_bin.nii

    ## Reslice created file to match MPRAGE (001.mgz) dimensions --(nearest neighbour)
    tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz -rt nearest ${REGION}_left_bin.nii.gz ${REGION}_left_bin_resliced.nii"
    tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz -rt nearest ${REGION}_right_bin.nii.gz ${REGION}_right_bin_resliced.nii"
    
    ## Eliminate nan values from the image (otherwise the computation of mean and std doesn't work properly and the outputs are nan)
    fslmaths ${REGION}_left_bin_resliced.nii -nan ${REGION}_left_mask.nii
    fslmaths ${REGION}_right_bin_resliced.nii -nan ${REGION}_right_mask.nii
   
    ## Obtain mean and std of the PET image using the mask created above, and output to a txt file
    MEAN_AND_STD=`fslstats r${PET_file}.nii -k ${REGION}_left_mask.nii.gz -m -s`
    echo ${SUBJECT_ID} ${MEAN_AND_STD} ${IS_PATIENT}>> ${PET_DIR}/ROI_Results/${REGION}_left_roi_values.txt
    MEAN_AND_STD=`fslstats r${PET_file}.nii -k ${REGION}_right_mask.nii.gz -m -s`
    echo ${SUBJECT_ID} ${MEAN_AND_STD} ${IS_PATIENT}>> ${PET_DIR}/ROI_Results/${REGION}_right_roi_values.txt
    ########################################################
}

## Process caudate, putamen, thalamus and pallidum:

process_region caudate 10.9 11.1 49.9 50.1 $IS_PATIENT
process_region putamen 11.9 12.1 50.9 51.1 $IS_PATIENT
process_region pallidum  12.9 13.1 51.9 52.1 $IS_PATIENT
process_region thalamus 9.9 10.1 48.9 49.1 $IS_PATIENT

#process other regions

#process_region white_matter 1.9 2.1 40.9 41.1 $IS_PATIENT
#process_region cerebral_cortex 2.9 3.1 41.9 42.1 $IS_PATIENT
process_region hippocampus 16.9 17.1 52.9 53.1 $IS_PATIENT
process_region amigdala 17.9 18.1 53.9 54.1 $IS_PATIENT
process_region insula 18.9 19.1 54.9 55.1 $IS_PATIENT
process_region brainstem 15.9 16.1 15.9 16.1 $IS_PATIENT

# Cortical regions from aparc

process_region caudalanteriorcingulate 1001.9 1002.1 2001.9 2002.1 $IS_PATIENT00
#process_region caudalmiddlefrontal 1002.9 1003.1 2002.9 2003.1 $IS_PATIENT
#process_region cuneus 1004.9 1005.1 2004.9 2005.1 $IS_PATIENT
#process_region entorhinal 1005.9 1006.1 2005.9 2006.1 $IS_PATIENT
process_region fusiform 1006.9 1007.1 2006.9 2007.1 $IS_PATIENT
#process_region inferiorparietal 1007.9 1008.1 2007.9 2008.1 $IS_PATIENT
#process_region inferiortemporal 1008.9 1009.1 2008.9 2009.1 $IS_PATIENT
#process_region isthmuscingulate 1009.9 1010.1 2009.9 2010.1 $IS_PATIENT
#process_region lateraloccipital 1010.9 1011.1 2010.9 2011.1 $IS_PATIENT
process_region lateralorbitofrontal 1011.9 1012.1 2011.9 2012.1 $IS_PATIENT

process_region precentral 1023.9 1024.1 2023.9 2024.1 $IS_PATIENT
process_region precuneus 1024.9 1025.1 2024.9 2025.1 $IS_PATIENT
process_region rostralanteriorcingulate 1025.9 1026.1 2025.9 2026.1 $IS_PATIENT
process_region rostralmiddlefrontal 1026.9 1027.1 2026.9 2027.1 $IS_PATIENT

# Delete intermediate files
rm *_left.nii.gz *_right.nii.gz *_bi.nii.gz *_bi_resliced.nii
