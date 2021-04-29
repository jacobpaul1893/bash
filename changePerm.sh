#!/bin/bash

IFS=$'\n'

if [[ "$#" -ne 1 ]]; then
    echo "Usage: chPerm-Other.sh <dir-name>";
    exit -1
fi

# Get folder name, replace '.' with pwd
if [[ $1 == "." ]]; then
    folder_to_search=$PWD
else
    folder_to_search=$1
fi

# Generate filename to save 
filename_to_save=$(tr '/' '_' <<< "${folder_to_search}")

# Recursively get list list of all directories in a directory
all_dirs=$(find $folder_to_search -type d)

# Recursively get list list of all files in a directory
all_files=$(find $folder_to_search -type f)

# Find directories without other users having rx permission, save their details and add rx permission.
for dir in $all_dirs;
do
    dir_details=$(stat $dir --format='%a %n' | awk '{print "dir_perm="$1; print "dir_name="$2}')
    eval $dir_details
    other_user=$((dir_perm%10))
    if (( $other_user != 5 && $other_user != 7 )); then
        printf "$dir_perm $dir_name\n" >> "${filename_to_save}.txt"
        chmod o+rx $dir_name
    fi
done


# Find files without other users having read permission, save their details and add read permission.
for file in $all_files;
do
    file_details=$(stat $file --format='%a %n' | awk '{print "file_perm="$1; print "file_name="$2}')
    eval $file_details
    other_user=$((file_perm%10))
    if (( $other_user < 4 )); then
        printf "$file_perm $file_name\n" >> "${filename_to_save}.txt"
        chmod o+r ${file_name}
    fi
done
