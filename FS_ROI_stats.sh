#!/usr/bin/env bash
##
## USE FS LABELS to OBTAIN ROI PET VALUES
## Generate FS segmented labels with FS recon -all
## This generates in the ...\FS\subjects\SubjectID\mri directory several files, including aparc+aseg.mgz

# Needs two arguments: 
#     SUBJECT ID (ej.: BATM46T_FDG)
#     PET file (with no extension!) where stats will be computed (ej.: rBAT_FDG_SUV_40-65.lin_T1_orientOK_skullstripped_norm_sm6mm)

 
## FS subjects dir and subject:
SUBJECT_ID=$1 
echo $SUBJECT_ID
SUBJECTS_DIR='/autofs/cluster/hookerlab/collaborators/PBR/Rosas/FDG/FS/subjects'

## PET data dir and file: 
PET_DIR='/autofs/cluster/hookerlab/Users/Cristina/Huntington_Corrected/FDG/PET_onto_standard'
PET_file=$2


OUTPUT_DIR=${PET_DIR}/${SUBJECT_ID}/ROIs/stats

# Make dir for this subject, copy the labels, MPRAGE and PET niftis file there, and move to that directory
mkdir -p ${OUTPUT_DIR}
mkdir -p ${PET_DIR}/ROI_Results/FS_stats
cp ${SUBJECTS_DIR}/${SUBJECT_ID}/mri/orig/001.mgz ${OUTPUT_DIR}

# Load_the Freesurfer env
FREESURFER="/usr/local/freesurfer/nmr-stable53-env"
if !([ -e $FREESURFER ]); then
     echo "Freesurfer not found at $FREESURFER."
     exit 1
fi

tcsh -c "source $FREESURFER; mri_convert ${PET_DIR}/${SUBJECT_ID}/PET-2-standard/${PET_file}.nii.gz ${OUTPUT_DIR}/${PET_file}.nii; 
mri_convert ${SUBJECTS_DIR}/${SUBJECT_ID}/mri/aparc+aseg.mgz ${OUTPUT_DIR}/aparc+aseg.nii"

cd ${OUTPUT_DIR}



## Resclice aparc+aseg.mgz to match  T1 resolution
tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz -rt nearest aparc+aseg.nii raparc+aseg.nii"

## Reslice PET image to match MPRAGE dimensions --(trilinear)

tcsh -c "source $FREESURFER; mri_convert -rl 001.mgz  ${OUTPUT_DIR}/${PET_file}.nii r${PET_file}.nii"


## Compute stats:

mri_segstats --seg raparc+aseg.nii --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --i r${PET_file}.nii --sum r${PET_file}.nii.aparc+aseg.stats

# --seg is the file with the segmentation volumes, the labels
# --ctab is the matching color lookup table
# --i invol: Input volume from which to compute more statistics, including min, max, range, average, and standard deviation as measured #            spatially across each segmentation. The input volume must be the same size and dimension as the segmentation volume.
# --sum output file where the stats will be stored. 
# Optional
# --id label1 --id label2 : if we only want statistics in specif regions (and not in all)




