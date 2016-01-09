#!/bin/bash

echo Kickoff script now removing itself from rc.local so it will not run again
sed -i '/\/home\/edison\/scripts\/kickoff.sh/c\\#\/home\/edison\/scripts\/kickoff.sh' /etc/rc.local

# echo running the kickoff script to set up the server. 
# /home/edison/scripts/setup_basic_infrastructure.sh
# /home/edison/scripts/install_ODK_Aggregate.sh
