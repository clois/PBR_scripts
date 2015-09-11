from subprocess import call
with open('patients.txt', 'r') as f:
    lines = f.readlines()
for line in lines:
    splitted = line.split()
    call(['./test_Histos_striatum.sh', splitted[0], splitted[1], splitted[2]])
