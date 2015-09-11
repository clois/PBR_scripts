#!/usr/bin/env bash
##
## TO BE USED AFTER test_ROIs_ivan_allRegions.sh ONLY!! (This version needs some files as inputs that are created running test_ROIs_ivan_allRegions.sh)
#
## Provides MIN AND MAX intensity of pixels within the masked VOI, so that histo range is known. 
## Provides HISTOGRAM values for nbins (50) between min (o.8) and max (1.8)
#

## Subject ID:
SUBJECT_ID=$1 
echo $SUBJECT_ID

## PET data dir and file: 
PET_DIR='/autofs/cluster/hookerlab/Users/Cristina/Huntington_Corrected/PBR/PET_onto_standard'
PET_file=$2

IS_PATIENT=$3

OUTPUT_DIR=${PET_DIR}/${SUBJECT_ID}/ROIs

mkdir -p ${OUTPUT_DIR}
mkdir -p ${PET_DIR}/Histograms

cd  ${OUTPUT_DIR}

process_region()
{
    
    REGION=$1
    LEFTLOWER=$2
    LEFTUPPER=$3
    RIGHTLOWER=$4
    RIGHTUPPER=$5
    IS_PATIENT=$6

    #fslmaths ${OUTPUT_DIR}/aparc+aseg.nii -thr $LEFTLOWER -uthr $LEFTUPPER ${REGION}_left.nii
    #fslmaths ${OUTPUT_DIR}/aparc+aseg.nii -thr $RIGHTLOWER -uthr $RIGHTUPPER ${REGION}_right.nii
    
    ## Add left and right regions to obtain bilateral values, and binarize. 
    #fslmaths ${REGION}_left.nii.gz -add ${REGION}_right.nii.gz -bin ${REGION}_bi.nii 
    
    ## Reslice created file to match MPRAGE (001.mgz) dimensions --(nearest neighbour)
    #tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz -rt nearest ${REGION}_bi.nii.gz ${REGION}_bi_resliced.nii"
    
    ## Eliminate nan values from the image (otherwise the computation of mean and std doesn't work properly and the outputs are nan)
    #fslmaths ${REGION}_bi_resliced.nii -nan ${REGION}_bi_mask.nii
    
    ## Reslice PET image to match MPRAGE dimensions --(trilinear)
    #tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz  ${OUTPUT_DIR}/${PET_file}.nii r${PET_file}.nii"
    
    ## Obtain mean and std of the PET image using the mask created above, and output to a txt file
    #MEAN_AND_STD=`fslstats r${PET_file}.nii -k ${REGION}_bi_mask.nii.gz -m -s`
    #echo ${SUBJECT_ID} ${MEAN_AND_STD} ${IS_PATIENT}>> ${PET_DIR}/ROI_Results/${REGION}_roi_values.txt

## Obtain min and max of the PET image using the mask created above, and output to a txt file
    MIN_AND_MAX=`fslstats r${PET_file}.nii -k ${REGION}_bi_mask.nii.gz -R`
    echo ${SUBJECT_ID} ${MIN_AND_MAX} ${IS_PATIENT}>> ${PET_DIR}/Histograms/${REGION}_min_and_max_values.txt
 }
  
   HISTO=`fslstats r${PET_file}.nii -k pallidum_bi_mask.nii.gz -H 50 0.8 1.8`
    echo ${SUBJECT_ID} ${HISTO} ${IS_PATIENT}>> ${PET_DIR}/Histograms/pallidum_histo_values.txt

   HISTO2=`fslstats r${PET_file}.nii -k putamen_bi_mask.nii.gz -H 50 0.5 1.8`
    echo ${SUBJECT_ID} ${HISTO2} ${IS_PATIENT}>> ${PET_DIR}/Histograms/putamen_histo_values.txt
   
   HISTO3=`fslstats r${PET_file}.nii -k caudate_bi_mask.nii.gz -H 50 0.3 1.5`
    echo ${SUBJECT_ID} ${HISTO3} ${IS_PATIENT}>> ${PET_DIR}/Histograms/caudate_histo_values.txt

   HISTO4=`fslstats r${PET_file}.nii -k thalamus_bi_mask.nii.gz -H 50 0.5 1.9`
    echo ${SUBJECT_ID} ${HISTO4} ${IS_PATIENT}>> ${PET_DIR}/Histograms/thalamus_histo_values.txt



## Process caudate, putamen, thalamus and pallidum:

process_region caudate 10.9 11.1 49.9 50.1 $IS_PATIENT
process_region putamen 11.9 12.1 50.9 51.1 $IS_PATIENT
process_region pallidum  12.9 13.1 51.9 52.1 $IS_PATIENT
process_region thalamus 9.9 10.1 48.9 49.1 $IS_PATIENT


