import requests
import sys, getopt



payload = {'machineId': sys.argv[2]}
r = requests.post('http://ec2-52-203-182-95.compute-1.amazonaws.com/endSession', data = payload)
print(r.text)

