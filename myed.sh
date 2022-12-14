#!/usr/bin/env sh
#my text editor in shell

set -eu

#引入所需函数
source ./function.sh

# 检查输入的参数数量
if [ "$#" -ne 1 ]; then
    printf '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Wrong Input!<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< \n'
    printf "myed [filename] : Create or Open an exist file to edit.\n"
    printf "myed [filename] : Expected one file name input to edit.\n"
    exit 1
fi

# disable ctrl + c
# trap '' 2

# 初始化变量
original_file="$1"
working_file=."$1".myeqwf
backup_file=."$1".myeqbf

_prompt="$(basename "$original_file")"

#判断是否为新建的文件，默认为0，若为新建的
new_create=0

#如果文件不存在，创建文件
[ ! -f "$original_file" ] && touch "$original_file" && new_create=1

cat "$original_file" > "$working_file"

#检测退出指令，删除working——file
trap 'rm -f "$working_file"' EXIT

printf '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Welcome to my text editor<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< \n'
printf '>> enter h for usage <<\n'

#调用显示文件函数
_print_lines

#调用主函数
_main
