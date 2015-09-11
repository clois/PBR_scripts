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
}

## Process caudate, putamen, thalamus and pallidum:

process_region caudate 10.9 11.1 49.9 50.1 $IS_PATIENT
process_region putamen 11.9 12.1 50.9 51.1 $IS_PATIENT
process_region pallidum  12.9 13.1  51.9 52.1 $IS_PATIENT
process_region thalamus 9.9 10.1 48.9 52.1 $IS_PATIENT

# Delete intermediate files
#rm *_left.nii.gz *_right.nii.gz *_bi.nii.gz *_bi_resliced.nii
