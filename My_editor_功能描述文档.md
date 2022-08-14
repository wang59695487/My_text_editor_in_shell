## My_editor_功能描述文档

#### 1. File Structure:

**如果使用 `macos` 要注意，先下载 `gnu-sed` ，把代码里的 `sed` 换成 `gsed` **

下载文件，文件夹里有：

-function.sh

-myed.sh

-Makefile

#### 2. Setting & Start:

- 进入命令行：

```shell
make
make install
#将下面这一行添加到你的～/.bashrc或者~/.vimrc中：
export PATH=$HOME/bin:$PATH
```

- 此时我们就可以直接输入`myed`命令来运行我们的文件编辑器了：

```shell
#example
myed 1.txt
#若1.txt文件存在则会自动打开1.txt并输出文件内容，若不存在则新建一个名为1.txt的文件
#文件的格式：
#行数 | 内容
#EOF
```

例子：

![image-20220814183410189](/Users/gakiara/Library/Application Support/typora-user-images/image-20220814183410189.png)

可以输入`Ctrl+c`强制结束：

#### 3. Usage:

进入了myed的界面后：

- **打印选项：**

  `p [#line number]`  -》打印某一行

  `p`  -》打印整个文件

- **行操作：**

  `a [#LINE]`: insert line(s) after #LINE

选项：

- `! [COMMAND]`: run shell COMMAND in the myed

- `/ [PATTERN]`: search for PATTERN in the file
- 
- `a`: appends to the end of the file
- `c [#LINE]`: change #LINE
- `d [#LINE]`: delete #LINE
- `e [FILE]`: close the current file (without saving) and opens FILE
- `q`: quits
- `u`: undo last change
- `w`: save
- `wq`: save and quit

### Editing

For the commands that require text input:

1. Write as you would normally do, presing enter for a new line.
2. After the last line is written, press enter again.
3. Press `Ctrl+D` to finish the text input.