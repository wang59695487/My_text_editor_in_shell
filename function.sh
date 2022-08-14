#!/usr/bin/env sh
set -eu

#打印帮助手册
_help(){

  printf '>> h : Myed usage << \n'
  printf '>> p ：printf the whole flie << \n'
  printf '>> p [#line number]：printf your choosing line << \n'
  printf '>> a ：insert at the end of the file << \n'
  printf '>> a [#line number]：insert after the your choosing line << \n'
  printf '>> r [#line number]：replace your choosing line with your insert << \n'
  printf '>> d [#line number]：delete your choosing line << \n'
  printf '>> u ：undo last change << \n'
  printf '>> q ：quit without save << \n'
  printf '>> w ：save << \n'
  printf '>> wq ：quit and save << \n'
  printf '>> e [#new file name] ：quit current file and open a new file << \n'
  printf '>> ! [COMMAND] ：run the shell command in the editor << \n'

}

# 备份函数
# 将 working_file 存储到 backup_file
# 这一步主要是为了保存上一步未修改前的脚本
_Backup_the_File() {
    cat "$working_file" >"$backup_file"
}


# 输入函数
# _insert_line(text, n)
# 函数的第一个参数为文本内容
# 第二个参数为行数，
# 行数为-1时默认在最后一行输入
_insert_line() {
	_text="$1"
	_n="$2"

    #判断行数
	case "$_n" in
    #当输入最后一行时
	-1)
        #将备份文件和输入输出到working file中，等价于在最后输入一行
		cat "$backup_file"
		printf '%s\n' "$_text"
		;;
     0)
        #将输入和备份文件的输出到working file中，等价于在最后第一行
        printf '%s\n' "$_text"
        cat "$backup_file"
        ;;
	 *)
        #显示备份文件第1到_n行的内容；
        gsed -n 1,"$_n"p "$backup_file"
        #显示输入的内容
		printf '%s\n' "$_text"
        #显示_n+1到结束的内容
		gsed -n "$((_n + 1))",\$p "$backup_file"
        #h将其输出到working file中，等价于在_n行后输入一行
		;;
	esac
}


# 输出文件全部内容函数
_print_lines() {
	i=1
    # 展示文件输出的格式：行 | 内容
    printf '>> Show %s : line | content\n' "$original_file"
    # 一行行地读取并显示文件的内容
	while read -r line || [ -n "$line" ]; do
    printf '# %s | %s\n' "$i" "$line"
		i="$((i + 1))"
	done <"$working_file"
	echo 'EOF'
}

# 输出文件某一行函数(n)
_print_line() {
	case "$1" in
	-1) tail -n 1 "$working_file" ;;
    0) ;;
	*) gsed -n "$1p" "$working_file" ;;
	esac
}


# 替代文件某一行函数(n) 相当于插入并删除某行
_replace_line() {
      _text="$1"
      _n="$2"

      #判断行数
      case "$_n" in
      #当输入最后一行时
      -1)#将备份文件1到n-1行和输入输出到working file中，等价于替换最后一行
      gsed -n 1,\$p | gsed '$d' "$backup_file"
      printf '%s\n' "$_text"
      ;;
      1)#将备份文件输入和2到最后一行输出到working file中，等价于替换最后一行
      printf '%s\n' "$_text"
      gsed -n 2,\$p "$backup_file"
      ;;
      *)
      #显示备份文件第1到_n-1行的内容；
      gsed -n 1,"$((_n-1))"p "$backup_file"
      #显示输入的内容
      printf '%s\n' "$_text"
      #显示_n+1到结束的内容
      gsed -n "$((_n + 1))",\$p "$backup_file"
      #h将其输出到working file中，等价于替换了第_n行
      ;;
     esac
}

#确认是否退出
_make_sure_to_quit(){
   printf 'File %s unsave, are you sure to quit [y/n]\n' "$original_file"
   printf '## myed : %s > ' "$_prompt"
   read -r input
   case "$input" in
   #若要退出，输入为y or yes
   y | yes)
      #判断是否是新建的文件，若为新建的文件且没有保存则删除掉
      case "$new_create" in
      0) exit 0 ;;
      1) rm -f "$original_file" & exit 0 ;;
      esac
      ;;
   #若不退出，回到主程序
   n | no)  _main;;
   #无效输入重新调用本函数
   *)
      printf '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Wrong Input!<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< \n'
      printf '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>myed: please input y or n to confirm <<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n' & _make_sure_to_quit
      ;;
   esac
}

# 等待命令输入
# 用户输入指令
_parse_command() {
	_cmd="$1" && shift
    # 根据输入执行相应指令
	case "$_cmd" in
	a)
        #先备份文件，根据输入的行数调用print和insert函数
		_Backup_the_File
		_n="${1--1}"
		_print_line "$_n"
		_insert_line "$(cat)" "$_n" >"$working_file"
		;;
    r)
        #先备份文件，根据输入的行数调用print和replace函数
		_Backup_the_File
		_n="${1--1}"
		_print_line "$_n"
		_replace_line "$(cat)" "$_n" >"$working_file"
		;;
    d)
        #先备份文件
        _Backup_the_File
        #检测输入参数数量，如果不符合回到主函数
        if [ "$#" -ne 1 ]; then
           printf '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Wrong Input!<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< \n'
           printf "d [# line number] :  Expected one line number input to edit.\n"
           _main
        #得到输入的函数，删除该行
        else
           gsed -i "$1d" "$working_file" # Deletes a line
        fi
        ;;
	e)
        #先备份文件
		_Backup_the_File
        #编辑打开另一个文件
		exec "$0" "$@"
		;;
    *w | *wq)
        #保存文件
        cat "$working_file" >"$original_file" & new_create=0 ;;# Saves the file
	p)
        #没有输入参数时调用
        #检测输入参数数量，如果不符合回到主函数
        if [ "$#" -gt 1 ]; then
              printf '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Wrong Input!<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< \n'
              printf "p:  Expected 0 or 1 input to print.\n"
              _main
        else
        #根据参数调用print函数
           case "$#" in
		   0) _print_lines ;;
		   1) _print_line "$1" ;;
		   esac
        fi
		;;

	u)
       #撤回到上一步操作，复制backup
       cat "$backup_file" >"$working_file" ;;
    h)
       #打开帮助文档
       _help ;;
	*!)
       #输入shell命令
        "$@" ;;
	*q);;

    *) #其他指令报错
       printf 'myed: the "%s" command is unknown\n' "$_cmd"
       printf '>> h : Myed usage << \n'
       ;;
	esac

    case "$_cmd" in
    #再次确认用户是否要退出,不保存文件
    q) _make_sure_to_quit ;;
    wq) exit 0 ;;
    esac

}

#主函数
_main(){
while :;
do
    #输出界面
    printf '## myed : %s > ' "$_prompt"
    #用户input
    read -r input
    [ -z "$input" ] && continue
    #根据input执行函数
    eval "_parse_command $input"
done
}
