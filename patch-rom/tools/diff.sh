#! /bin/sh
ROOT_PATH=`pwd`
t_path=$ROOT_PATH/t-framework-res
s_path=$ROOT_PATH/s-framework-res
df_txt=$ROOT_PATH/diff.txt
echo "start diff" > $df_txt
cd $t_path
for file in `find ./ -name "*.*"`
do
   	if [ -f $s_path/$file ]
   	then
    	diff $file $s_path/$file > /dev/null || {
				#diff -B -c $file $new_code_noline/$file > $file.diff
                echo "$file is diff"
                echo "$file is diff" >> $df_txt
		}
   	else
    	echo "$file does not exist at $s_path"
        echo "$file not exist" >> $df_txt
   	fi
done
