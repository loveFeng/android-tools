#!/bin/bash
echo "*****************eng build*************************"
option=""
part="-eng"
project=p931l
cmd_line=$*
cmd_line=${cmd_line//" "/\#}
./mk-sys.sh $cmd_line $project $part $option

echo "****************eng build***************************"
