#!/bin/bash
echo "********************build start*************************"
compiler=$1
project=$2
part=$3
option=$4
all_cmd="$option $project"
#将全部#替换为空格
compiler=${compiler//\#/" "}
##
change_to_normal()
{
	echo "*****mv common$part common;$project$part $project*****"
	mv out/target/common$part out/target/common
	mv out/target/product/$project$part out/target/product/$project
}

##
change_to_special()
{
	echo "*****mv common common$part;$project $project$part*****"
	mv out/target/common out/target/common$part
	mv out/target/product/$project out/target/product/$project$part
}

deal_copys()
{
	echo "*******copy app lib to out/target/product/$project/system/ *******"
	cp -r need-copy/app out/target/product/$project/system/
	cp -r need-copy/lib out/target/product/$project/system/
	echo "*******end copy *******"
}

##
deal_special_file()
{
	echo "*******start ./makeMtk $all_cmd mm prebuilt/3rd_party_apk_odex *******"
	./makeMtk $all_cmd mm prebuilt/3rd_party_apk_odex
	echo "*******end ./makeMtk $all_cmd mm prebuilt/3rd_party_apk_odex *******"
	#echo "*******start ./makeMtk $all_cmd mm prebuilt/3rd_party_jar_odex *******"
	#./makeMtk $all_cmd mm prebuilt/3rd_party_jar_odex
	#echo "*********end ./makeMtk $all_cmd mm prebuilt/3rd_party_jar_odex *******"
	##copy app lib
	deal_copys
	echo "*******start ./makeMtk $all_cmd systemimage *******"
	./makeMtk $all_cmd systemimage
	echo "*******end ./makeMtk $all_cmd systemimage *******"
}
change_to_normal

#for params in $compiler
#do
case $compiler in
    "new" | "r" | "remake")
    echo "*********start ./makeMtk $all_cmd $compiler *******"
    	./makeMtk $all_cmd $compiler
    echo "*********end ./makeMtk $all_cmd $compiler *******"
    #deal_special_file
    ;;
   "systemimage")
    echo "********later will run systemimage*******"
    deal_special_file
    ;;
   *)
    echo "*********start ./makeMtk $all_cmd $compiler *******"
	./makeMtk $all_cmd $compiler
    echo "*********end ./makeMtk $all_cmd $compiler *******"
  esac
#done
change_to_special
echo "********************build end***************************"
