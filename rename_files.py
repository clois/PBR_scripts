import glob
import shutil

# Substitute path/to/dir for the directory the files are in
#directory = '.'
directory = '/autofs/cluster/hookerlab/Users/Cristina/fPET/Subjects_PETMR/fPET_0901_clois/PET/MR/MPRAGE'
old_files = glob.glob(directory + '/*.dcm')

# Removes four last chars in the name and add '_cris.dcm'
new_files = [ f[:-4] + '_cl.dcm' for f in old_files ]

# Builds a list of 2-tuples, where the first (second) is the old (new) file 
zipped = zip(old_files, new_files)

# Copies the old to the new files. Use 'rename' instead of 'copyfile' to move.
for z in zipped:
    shutil.move(z[0], z[1])
