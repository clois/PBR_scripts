from subprocess import call
with open('patients.txt', 'r') as f:
    lines = f.readlines()
for line in lines:
    splitted = line.split()
    call(['./test_ROIs_ivan_allRegions.sh', splitted[0], splitted[1], splitted[2]])
