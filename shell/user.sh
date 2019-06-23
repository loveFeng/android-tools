#!/bin/bash
echo "*****************user build*************************"
option="-o=TARGET_BUILD_VARIANT=user"
part="-user"
project=p931l
cmd_line=$*
cmd_line=${cmd_line//" "/\#}
./mk-sys.sh $cmd_line $project $part $option

echo "****************user build***************************"
