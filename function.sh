#!/usr/bin/env sh
set -eu

# _Backup_the_File()
# Back up working_file to backup_file
_Backup_the_File() {
    cat "$working_file" >"$backup_file"
}


# _insert_line(text, n)
# Inserts text into the line number n of backup_file and returns the result.
# For n = -1 it inserts it at the end of the file.
_insert_line() {
	_text="$1"
	_n="$2"

	case "$_n" in
	-1)
		cat "$backup_file"
		printf '%s\n' "$_text"
		;;
	0)
		printf '%s\n' "$_text"
		cat "$backup_file"
		;;
	*)
		gsed -n 1,"$_n"p "$backup_file"
		printf '%s\n' "$_text"
		gsed -n "$((_n + 1))",\$p "$backup_file"
		;;
	esac
}

# _print_file
# Prints working_file with line numbering
_print_lines() {
	i=1
    printf '>> Show %s : line | content\n' "$original_file"
	while read -r line || [ -n "$line" ]; do
    printf '# %s | %s\n' "$i" "$line"
		_i="$((i + 1))"
	done <"$working_file"
	echo 'EOF'
}

# _print_line(n)
# Prints the line number n of working_file. If n = -1 it prints the last line.
_print_line() {
	case "$1" in
	-1) tail -n 1 "$working_file" ;;
	*) gsed -n "$1p" "$working_file" ;;
	esac
}

# _replace_line(n)
# Replaces text into the line number n of working_file with n between 1 and the
# total number of lines.
_replace_line() {
	_insert_line "$@" | gsed "$1"d
}

_make_sure_to_quit(){
   printf '## myed : %s > ' "$_prompt"
   read -r input
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

# _parse_command(cmd)
# Parses user input commands
_parse_command() {
	_cmd="$1" && shift

	case "$_cmd" in
	a)
		_Backup_the_File
		_n="${1--1}"

		_print_line "$_n"
		_insert_line "$(cat)" "$_n" >"$working_file"
		;;
	c)
		_Backup_the_File
		_n="${1--1}"
		_print_line "$_n"
		_replace_line "$(cat)" "$_n" >"$working_file"
		;;
	d) gsed -i "$1d" "$working_file" ;; # Deletes a line
	*e)                                 # Edit another file
		_Backup_the_File
		exec "$0" "$@"
		;;
	*w | *wq) cat "$working_file" >"$original_file" & new_create=0;; # Saves the file
	p)
		case "$#" in
		0) _print_lines ;;
		1) _print_line "$1" ;;
		esac
		;;
	u) cat "$backup_file" >"$working_file" ;; # Undoes last change
	/) grep -n "$1" "$working_file" ;;
	*!) "$@" ;; # Shell commands
	*q) ;;
	*) printf 'myed: the "%s" command is unknown\n' "$_cmd"

       ;;
	esac

	case "$_cmd" in
    #再次确认用户是否要退出,不保存文件
	*q) _make_sure_to_quit;;
	esac
}

_main(){
while :;
do
    printf '## myed : %s > ' "$_prompt"
    read -r input

    [ -z "$input" ] && continue

    eval "_parse_command $input"
done
}
