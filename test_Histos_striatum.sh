#!/usr/bin/env bash
##
## TO BE USED AFTER 'get_PETmean_FS_ROIs.sh' or 'test_ROIs_ivan_allRegions.sh' ONLY!!!! (needs as inputs some of the files that are created running that script)
##
## Provides MIN AND MAX intensity of pixels within the masked VOI, so that histo range is known. 
## Provides HISTOGRAM values for nbins (50) between min (0.8) and max (1.8)
##
## You NEED TO CHANGE "PET_DIR"


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


## Obtain min and max of the PET image using the mask created the script 'get_PETmean_FS_ROIs.sh', and output to a txt file
#    MIN_AND_MAX=`fslstats r${PET_file}.nii -k ${REGION}_bi_mask.nii.gz -R`
#    echo ${SUBJECT_ID} ${MIN_AND_MAX} ${IS_PATIENT}>> ${PET_DIR}/Histograms/${REGION}_min_and_max_values.txt
# }

# Obtain histogram values for pallidum, putamen, caudate and thalamus:
  
   HISTO=`fslstats r${PET_file}.nii -k pallidum_bi_mask.nii.gz -H 50 0.8 1.8`
    echo ${SUBJECT_ID} ${HISTO} ${IS_PATIENT}>> ${PET_DIR}/Histograms/pallidum_histo_values.txt

   HISTO2=`fslstats r${PET_file}.nii -k putamen_bi_mask.nii.gz -H 50 0.5 1.8`
    echo ${SUBJECT_ID} ${HISTO2} ${IS_PATIENT}>> ${PET_DIR}/Histograms/putamen_histo_values.txt
   
   HISTO3=`fslstats r${PET_file}.nii -k caudate_bi_mask.nii.gz -H 50 0.3 1.5`
    echo ${SUBJECT_ID} ${HISTO3} ${IS_PATIENT}>> ${PET_DIR}/Histograms/caudate_histo_values.txt

   HISTO4=`fslstats r${PET_file}.nii -k thalamus_bi_mask.nii.gz -H 50 0.5 1.9`
    echo ${SUBJECT_ID} ${HISTO4} ${IS_PATIENT}>> ${PET_DIR}/Histograms/thalamus_histo_values.txt




