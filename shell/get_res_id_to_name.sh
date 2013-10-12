#!/bin/bash

if [ $# -lt 2 ]
then
    echo "请输入需要查询名字的文件夹, 查询id的文件"
    exit
fi
c_framework=$1
c_path=$2

#标准id列表
our_file=our.txt
#处理后的资源id
our_deal_file=our_deal.txt
#查找标准id资源文件夹
our_framework=framework
#标准文件夹
our_path=android.policy

#生成需要更换id列表文件
c_file=c-policy.txt
#处理后的资源id
c_deal_file=c.txt
#查找id的文件夹
#c_framework=framework_miui
#需要更换id的文件夹
#c_path=android.policy_miui 
c_id_list=c_id_list.txt

error_file=error.txt 

tmp_file=tmp.txt
cmd_line=cmd_line.txt
check_file=check.txt
find_res_name=""
find_res_id=""
find_res_id_file=""

## 读取我们文件中资源id
function read_our(){
    #查找0x1123456 0x2123456类似资源id,导出到文件中 将字符串前后添加@
    grep "0x[12][a-z0-9]\{6\}" $our_path -rn | sort | sed 's/\(0x[12][a-z0-9]\{6\}\)/@&@/' > $our_file
    rm $our_deal_file
    
    while read line
    do
        #从变量$line的结尾, 删除最短匹配 @* 的子串
        line=${line%@*}
        #从变量$line的开头, 删除最长匹配 *@ 的子串
        line=${line##*@}
        echo $line >> $our_deal_file
    done < $our_file
}

function read_c(){

    grep "0x[12][a-z0-9]\{6\}" $c_path -rn | sort | sed 's/\(0x[12][a-z0-9]\{6\}\)/@&@/' > $c_file
    rm $c_deal_file
    
    while read line
    do
        line=${line%@*}
        line=${line##*@}
        echo $line >> $c_deal_file
    done < $c_file
}

function get_res_name(){
    fload=$1
    res_id=$2
    echo "get_res_name $fload $res_id" >>$check_file 
    line=`find $fload -name "R*.smali" | xargs grep "$res_id" -rn`
    #line 得到字符串 "framework/smali/com/android/internal/R$string.smali:842:.field public static final lockscreen_glogin_invalid_input:I = 0x1040314"
    line=${line%:*}
    #处理后结果 "framework/smali/com/android/internal/R$string.smali:842:.field public static final lockscreen_glogin_invalid_input"
    find_res_name=${line##*' '}
    #处理后结果 "lockscreen_glogin_invalid_input"
    find_res_id_file=${line##*$}
    find_res_id_file=${find_res_id_file%%.*}
    echo "get_res_name find_res_name=$find_res_name find_res_id_file=$find_res_id_file" >>$check_file 
}

function get_res_id(){
    fload=$1
    res_name=$2
    res_source_id=$3
    res_name_file=$4
    
    echo "get_res_id fload=$fload res_name=$res_name res_source_id=$res_source_id res_name_file=$res_name_file" >>$check_file
    res_source_id=${res_source_id:0:3}
    #echo "test res_source_id =$res_source_id"
    #line=`find $fload -name "R*$res_name_file.smali" | xargs grep " $res_name\:I = $res_source_id" -rn`
    line=`find $fload -name "R*$res_name_file.smali" | xargs grep " $res_name\:I = $res_source_id" -rn`
    #得到字符串 "framework_miui/smali/com/android/internal/R$string.smali:.field public static final lockscreen_glogin_invalid_input:I = 0x1040318"
    echo "get_res_id $line" >>$check_file
	
    find_res_id=${line##*' '}
    #处理结果 "0x1040318"
    echo "get_res_id find_res_id= $find_res_id" >>$check_file 
}

#将文件中的$c_res_id 更改为 $our_res_id
function file_replace_id_our(){
    c_id=$1
    our_id=$2
    file_path=$3
    echo "file_replace_id_our $c_id,$our_id $file_path" >> $check_file
    rm -f $file_path.tmp

    echo "s/$c_id/$our_id/" >> $check_file
    #echo "s/$c_id/$our_id/" > $cmd_line
    #sed -f $cmd_line $file_path > $file_path.tmp
    sed -e "s/$c_id/$our_id/" $file_path > $file_path.tmp
    rm -rf $file_path
    mv $file_path.tmp $file_path
}

#查找需要更改的文件中存在 $c_res_id 的文件存储到tmp.txt
function replace_id_our(){
    c_id=$1
    our_id=$2
    #echo "replace_id_our c_id=$c_id,our_id=$our_id"
    grep "$1" $c_path.tmp -r | sort > $tmp_file
    
    while read line
    do
        #从变量$line的结尾, 删除最长匹配 :* 的子串
        file_path=${line%%:*}
        file_path=${file_path/$c_path.tmp/$c_path}
        file_replace_id_our $c_id $our_id $file_path
    done < $tmp_file
}

#获取替换文件夹中所有资源id的列表
function get_id_from_c(){
    c_id=$1
    #echo "replace_id_our c_id=$c_id,our_id=$our_id"
    grep "$1" $c_path -r | sort >> $c_id_list
}

function start_replace() {

    rm -f $error_file
    rm -f $c_id_list

    rm -rf $c_path.tmp
    cp $c_path $c_path.tmp -r
    
    while read line
    do
        tmp_res_id=$line
        get_res_name $c_framework $tmp_res_id
		if [ "$find_res_name" != "" ]
		then
		    get_res_id $our_framework $find_res_name $tmp_res_id $find_res_id_file
		    if [ "$find_res_id" != "$tmp_res_id"  -a  "$find_res_id" != "" ]
		    then
		        echo "start replace_id_our c:$tmp_res_id,our:$find_res_id"
		        replace_id_our $tmp_res_id $find_res_id
            else
                echo "get_res_id $our_framework $find_res_name $tmp_res_id" >> $error_file 
		    fi
        else
           echo "get_res_name $c_framework $tmp_res_id" >> $error_file 
		fi
    done < $c_deal_file
    
    rm -rf $c_path.tmp
}

#test_line
rm -f $check_file
read_c
start_replace
#read_c end.txt



function test_line() {
    line="android.policy/smali/com/android/internal/policy/impl/Account@UnlockScreen.smali:195:    const v0, @0x104030e@ fsadf"
    #echo $line
    line=${line%@*}
    line=${line##*@}
    #echo $line
    tmp_res_id=0x1040314
    get_res_name $c_framework $tmp_res_id
    get_res_id $our_framework $find_res_name
    #replace_id_our $c_res_id $our_res_id
    
    our_id_list=""
    c_id_list=""
    
    while read line
    do
        tmp_res_id=$line
        get_res_name $c_framework $tmp_res_id
		if [ "$find_res_name" != "" ]
		then
		    get_res_id $our_framework $find_res_name $tmp_res_id 
            
		    if [ "$find_res_id" != "$tmp_res_id"  -a  "$find_res_id" != "" ]
		    then
		        echo "get_id_from_c c:$tmp_res_id "
		        get_id_from_c $tmp_res_id 
                our_id_list=$our_id_list" "$find_res_id
                c_id_list=$c_id_list" "$tmp_res_id
                echo "$our_id_list $c_id_lis"
            else
                echo "get_res_id $our_framework $find_res_name $tmp_res_id" >> $error_file 
		    fi
        else
           echo "get_res_name $c_framework $tmp_res_id" >> $error_file 
		fi
    done < $c_deal_file
}



