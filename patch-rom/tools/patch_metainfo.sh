#! /bin/sh

diff $file $new_code_noline/$file > /dev/null || {
					diff -B -c $file $new_code_noline/$file > $file.diff
			}



