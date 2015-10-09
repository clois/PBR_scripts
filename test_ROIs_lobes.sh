#!/usr/bin/env bash
##
## USE FS LABELS to OBTAIN ROI PET VALUES
## Generate FS segmented labels with FS recon -all
## This generates in the ...\FS\subjects\SubjectID\mri directory several files, including aparc+aseg.mgz

## FS subjects dir and subject:
SUBJECT_ID=$1 
echo $SUBJECT_ID
SUBJECTS_DIR='/autofs/cluster/hookerlab/collaborators/PBR/Rosas/FDG/FS/subjects'
#setenv SUBJECTS_DIR /autofs/cluster/hookerlab/collaborators/PBR/Rosas/PBR/FS/subjects

## PET data dir and file: 
PET_DIR='/autofs/cluster/hookerlab/Users/Cristina/Huntington_Corrected/FDG/PET_onto_standard'
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
	
}

process_region frontal1 1002.9 1003.1 2002.9 2003.1 $IS_PATIENT
process_region frontal2 1011.9 1012.1 2011.9 2012.1 $IS_PATIENT
process_region frontal3 1013.9 1014.1 2013.9 2014.1 $IS_PATIENT
process_region frontal4 1016.9 1020.1 2016.9 2020.1 $IS_PATIENT
process_region frontal5 1023.9 1024.1 2023.9 2024.1 $IS_PATIENT
process_region frontal6 1026.9 1028.1 2026.9 2028.1 $IS_PATIENT
process_region frontal7 1031.9 1032.1 2031.9 2032.1 $IS_PATIENT

process_region parietal1 1007.9 1008.1 2007.9 2008.1 $IS_PATIENT
process_region parietal2 1021.9 1022.1 2021.9 2022.1 $IS_PATIENT
process_region parietal3 1024.9 1025.1 2024.9 2025.1 $IS_PATIENT
process_region parietal4 1028.9 1029.1 2028.9 2029.1 $IS_PATIENT
process_region parietal5 1030.9 1031.1 2030.9 2031.1 $IS_PATIENT

process_region occipital1 1004.9 1005.1 2004.9 2005.1 $IS_PATIENT
process_region occipital2 1010.9 1011.1 2010.9 2011.1 $IS_PATIENT
process_region occipital3 1012.9 1013.1 2012.9 2013.1 $IS_PATIENT
process_region occipital4 1020.9 1021.1 2020.9 2021.1 $IS_PATIENT

#TEMPORAL
#Superior, Middle, and Inferior Temporal
process_region temporal1 1008.9 1009.1 2008.9 2009.1 $IS_PATIENT
process_region temporal2 1014.9 1015.1 2014.9 2015.1 $IS_PATIENT
process_region temporal3 1029.9 1030.1 2029.9 2030.1 $IS_PATIENT
#Banks of the Superior Temporal Sulcus
process_region temporal4 1000.9 1001.1 2000.9 2001.1 $IS_PATIENT
#Fusiform
process_region temporal5 1006.9 1007.1 2006.9 2007.1 $IS_PATIENT
#Transverse Temporal 1034
process_region temporal6 1033.9 1034.1 2033.9 2034.1 $IS_PATIENT
#Entorhinal 1006
process_region temporal7 1005.9 1006.1 2005.9 2006.1 $IS_PATIENT
#Temporal Pole 1033
process_region temporal8 1032.9 1033.1 2032.9 2033.1 $IS_PATIENT
#Parahippocampal 1016
process_region temporal9 1015.9 1016.1 2015.9 2016.1 $IS_PATIENT

result=frontal1_bi.nii.gz
for region in frontal*_bi.nii.gz    
do	
	fslmaths ${region} -add ${result} ${result}
done

result2=parietal1_bi.nii.gz
for region in parietal*_bi.nii.gz    
do	
	fslmaths ${region} -add ${result2} ${result2}
done

result3=occipital1_bi.nii.gz
for region in occipital*_bi.nii.gz    
do	
	fslmaths ${region} -add ${result3} ${result3}
done

result4=temporal1_bi.nii.gz
for region in temporal*_bi.nii.gz    
do	
	fslmaths ${region} -add ${result4} ${result4}
done

# Reslice created file to match MPRAGE (001.mgz) dimensions --(nearest neighbour)
    tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz -rt nearest frontal1_bi.nii.gz frontal_resliced.nii"
    tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz -rt nearest parietal1_bi.nii.gz parietal_resliced.nii"
    tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz -rt nearest occipital1_bi.nii.gz occipital_resliced.nii"
    tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz -rt nearest temporal1_bi.nii.gz temporal_resliced.nii"
    
# Eliminate nan values from the image (otherwise the computation of mean and std doesn't work properly and the outputs are nan) and binnarize
    fslmaths frontal_resliced.nii -nan -bin frontal_mask.nii
    fslmaths parietal_resliced.nii -nan -bin parietal_mask.nii
    fslmaths occipital_resliced.nii -nan -bin occipital_mask.nii
    fslmaths temporal_resliced.nii -nan -bin temporal_mask.nii

# Reslice PET image to match MPRAGE dimensions --(trilinear)
    tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz  ${OUTPUT_DIR}/${PET_file}.nii r${PET_file}.nii"
    
# Obtain mean and std of the PET image using the mask created above, and output to a txt file
    MEAN_AND_STD=`fslstats r${PET_file}.nii -k frontal_mask.nii.gz -m -s`
    echo ${SUBJECT_ID} ${MEAN_AND_STD} ${IS_PATIENT}>> ${PET_DIR}/ROI_Results/lobe_frontal_roi_values.txt

    MEAN_AND_STD=`fslstats r${PET_file}.nii -k parietal_mask.nii.gz -m -s`
    echo ${SUBJECT_ID} ${MEAN_AND_STD} ${IS_PATIENT}>> ${PET_DIR}/ROI_Results/lobe_parietal_roi_values.txt
 
    MEAN_AND_STD=`fslstats r${PET_file}.nii -k occipital_mask.nii.gz -m -s`
    echo ${SUBJECT_ID} ${MEAN_AND_STD} ${IS_PATIENT}>> ${PET_DIR}/ROI_Results/lobe_occipital_roi_values.txt

    MEAN_AND_STD=`fslstats r${PET_file}.nii -k temporal_mask.nii.gz -m -s`
    echo ${SUBJECT_ID} ${MEAN_AND_STD} ${IS_PATIENT}>> ${PET_DIR}/ROI_Results/lobe_temporal_roi_values.txt


# Delete intermediate files
rm *_left.nii.gz *_right.nii.gz  *_bi.nii.gz
