# NiFi Python scripts

This directory holds all python scripts available in the Apache NiFi instance

#### How to create new scripts

Apache NiFi uses simple scheme for executing command line scripts/utilities:
- The script should expect selected attributes to be sent using command line arguments
- The script should expect FlowFile content to be sent usign ```stdin```
- The script should output modified content of the FlowFile to ```stdout```
- The script should return ```0``` to indicate success
- The script sgould return a non-zero value to indicate errors. It should also write any error messages to ```stderr```
