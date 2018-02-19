#!/bin/bash

## Anything in /tmp can be deleted any time, as long as it is not accessed.
## This script deletes any file (no folders) that has not been accessed for over 10 days.
sudo find /tmp -type f -atime +10 -delete

