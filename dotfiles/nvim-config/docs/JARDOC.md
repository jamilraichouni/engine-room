# JAR Documentation

## Fonts

see: <https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts>

## Recipes

### Recipe(shellscript): for loop over list

```bash
export ids="2a33e2754605
b019c63dcd1c
92110f0b5a58"
for id in $ids;
  do echo $id;
done
```

Alternative:

```bash
export ids=("2a33e2754605" "b019c63dcd1c" "92110f0b5a58")
for id in "${ids[@]}";
  do echo $id;
done
```

### Recipe(shellscript): List used ports

```bash
# install pkg `net-tools`
netstat -tulpn
```

### Recipe(shellscript): Process files found by `find` command:

```bash
find . -type f -name "*.txt" -exec cat {} \;
```

### Recipe(shellscript): Exclude a dir/ folder/ path in find command

```bash
# The asterisk is important
find . ! -path './3rdparty/*' -type f -name ".project"
```

### Recipe(shellscript): Translate, squeeze, and/or delete chars in strings

Translate, squeeze, and/or delete characters from standard input, writing to
standard output. STRING1 and STRING2 specify arrays of characters ARRAY1 and
ARRAY2 that control the action.

```bash
echo "Hello World" | tr '[:lower:]' '[:upper:]'  # HELLO WORLD
echo "Hello World" | tr -d '[:space:]'  # HelloWorld
```

### Recipe(capella): List installed software

```bash
capella -consoleLog -noSplash \
    -application org.eclipse.equinox.p2.director \
    -data ~/workspaces/capella_6.0.0 \
    -repository file:///opt/capella_6.0.0/p2/org.eclipse.equinox.p2.engine/profileRegistry/DefaultProfile.profile \
    -list
```

### Recipe(docker,artifactory): Login to Artifactory registry

- Login at https://bahnhub.tech.rz.db.de/ui/user_profile

- Click on `Edit profile` below your name

- Generate an Identity Token or find one in password manager (look for entry
  named `SET Docker images (Artifactory)`)

- Add description (e.g. `ato-c-docker-stage-local`)

- Edit appropriate cfg files (e.g. `~/.config/pip/pip.conf`)

- Store token in password manager

To be able to pull images from anywhere, we need to be logged into the VPN and
four different registries:

```bash
docker login dbb-set-docker-prod-local.bahnhub.tech.rz.db.de  # user: BKU user, password: BKU password
docker login ato-c-docker-stage-local.bahnhub.tech.rz.db.de  # user: BKU user, password: BKU password
docker login dbb-set-docker-stage-dev-local.bahnhub.tech.rz.db.de  # user: BKU user, password: BKU password
docker login -u jamilraichouni  # login at docker.io (DB)
docker login -u raichouni  # login at docker.io (private)
```

### Recipe(git): Undo last local (unpushed) commit

```bash
git reset HEAD~
```

### Recipe(git): Drop last commits after HASH

```bash
git reset HASH
git push -f
```

### Recipe(git): Commit empty dirs/ folders

**Use case 1:**

Commit empty dir where no additional content is expected:

```bash
mkdir /path/to/dir
touch /path/to/dir/.gitkeep
git add /path/to/dir/
```

**Use case 2:**

Commit empty dir where additional content is expected:

```bash
mkdir /path/to/dir
echo -e "*\n!.gitignore" > /path/to/dir/.gitignore
git add /path/to/dir/
```

### Recipe(git): Rename current local branch

```bash
git branch -m NEW_NAME
```

### Recipe(git): Checkout commit and back to HEAD

```bash
git checkout --detach HASH
```

```bash
git switch BRANCH
```

### Recipe(git): Complete local reset

```bash
git restore .
git clean -fd
```

### Recipe(git-lfs): Large files with Git LFS

Recipe works to solve GitHub error:

```text
remote: error: GH001: Large files detected.
You may want to try Git Large File Storage - https://git-lfs.github.com.
```

```bash
git lfs install
git lfs migrate import --include="<files to be tracked>"
```

### Recipe(java): List installable units (IUs) in a p2 repository

```bash
java -jar \
  /opt/capella_6.0.0/plugins/org.eclipse.equinox.launcher_1.6.200.v20210416-2027.jar \
  -consolelog -application org.eclipse.equinox.p2.director -repository
```

### Recipe(pre-commit): Solve RuntimeError: The Poetry configuration is invalid

Run `pre-commit autoupdate`, commit potentially modified
`.pre-commit-config.yaml` and re-run pre-commit via `pre-commit run -a` or push
changes for CI pre-commit job.

### Recipe(python): Install Python development environment on macOS

#### Remove macos Python from python.org

1. `rm -rf /Library/Frameworks/Python.framework`
1. Remove all symlinks in `/usr/local/bin` that point to sth. containing
   `Python.framework`
1. Remove ~/Library/Python/
1. Optionally remove everything in
   `python -c "import site; print(site.USER_SITE)"`

#### Manage Python versions using pyenv

1. Install pyenv (https://github.com/pyenv/pyenv-installer)
1. Install pyenv-virtualenv (https://github.com/pyenv/pyenv-virtualenv)
1. Install Python version from python.org via `pyenv install x.y.z`

#### Download and install Python from python.org on macOS

1. Download Python from <http://www.python.org/downloads>
1. Run the installer
1. Run the file `/Applications/Python 3.10/Install Certificates.command`
1. `ln -s /Library/Frameworks/Python.framework/Versions/3.10/bin/pip3 /usr/local/bin/pip`
1. `pip install -U pip`
1. `pip install --user -r ~/dev/github/.env/requirements.txt`

This installs packages into `python -c "import site; print(site.USER_SITE)"`

`pip list` should just list sth. similar to:

```text
Package    Version
---------- ---------
certifi    2022.9.14
pip        22.2.2
setuptools 63.2.0
```

### Recipe(pip): Install a package from a git repository

```bash
pip install git+ssh://path/to/repo.git
pip install git+https://path/to/repo.git
```

### Recipe(pip): Install a package from a git repository selecting a branch

```bash
pip install git+ssh://path/to/repo.git@branch
pip install git+https://path/to/repo.git@branch
```

### Recipe(python): Debug code with `pdb` or `pdbpp`/ `pdb++`

Install via

```bash
pip install git+https://github.com/pdbpp/pdbpp.git
```

To debug common code:

```bash
python -mpdb [-c] [-m] /path/to/module
```

To debug pytest tests:

```bash
python -mpdb [-c] -m pytest --trace \
    --pdbcls=IPython.terminal.debugger:TerminalPdb /path/to/test(module)
```

To debug a statement in an IPython cell:

**Cell 1:**

```python
from capellambse import MelodyModel
model = MelodyModel("/path/to/model.aird")
```

**Cell 2:**

```python
def debug():
    ipdb.set_trace()
    model.search("LAB")


debug()
```

**Variant 1:**

Manually put a `breakpoint()` statement in the code and run

```python
%run [-m] statement  # e. g.: %run -m mddocgen.jobgen builddesc.yml .
```

**Variant 2:**

```python
# e. g.: %run -d -m mddocgen.jobgen.__main__ builddesc.yml .
%run -d [-m] statement
```

This will stop on entry in line 1 of the module `__main__`.

### Recipe(python): Debug Jinja template in FastAPI

```python
import pdbp as pdb
app = fastapi.FastAPI()
app.state.pdb = pdb
```

```jinjia2
{% set _ = request.app.state.pdb.set_trace() %}
```

### Recipe(python): Analyse shell command outputs with IPython

**Example: List symbolic links:**

```ipython
In [14]: items = !ls -la

In [15]: [i for i in items if i[0].startswith("l")]
Out[15]:
['lrwxr-xr-x     1 jamilraichouni  staff      38 May  6 07:49 .config -> /Users/jamilraichouni/My Drive/.config',
 'lrwxr-xr-x     1 jamilraichouni  staff      39 May 16 21:46 .gdbinit -> /Users/jamilraichouni/My Drive/.gdbinit',
 'lrwxr-xr-x     1 jamilraichouni  staff      41 May  6 13:59 .gitconfig -> /Users/jamilraichouni/My Drive/.gitconfig',
 'lrwxr-xr-x     1 jamilraichouni  staff      41 May  6 14:00 .gitignore -> /Users/jamilraichouni/My Drive/.gitignore',
 'lrwxr-xr-x     1 jamilraichouni  staff      37 May  7 10:12 .icons -> /Users/jamilraichouni/My Drive/.icons',
 'lrwxr-xr-x     1 jamilraichouni  staff      41 May 19 14:06 .ipython -> /Users/jamilraichouni/repos/.dev/.ipython',
 'lrwxr-xr-x     1 jamilraichouni  staff      41 May  6 13:58 .oh-my-zsh -> /Users/jamilraichouni/My Drive/.oh-my-zsh',
 'lrwxr-xr-x     1 jamilraichouni  staff      40 May  6 13:58 .p10k.zsh -> /Users/jamilraichouni/My Drive/.p10k.zsh',
 'lrwxr-xr-x     1 jamilraichouni  staff      39 May 19 22:09 .pdbrc -> /Users/jamilraichouni/repos/.dev/.pdbrc',
 'lrwxr-xr-x     1 jamilraichouni  staff      35 May  6 07:54 .ssh -> /Users/jamilraichouni/My Drive/.ssh',
 'lrwxr-xr-x     1 jamilraichouni  staff      39 May 18 15:38 .vimrc -> /Users/jamilraichouni/repos/.dev/.vimrc',
 'lrwxr-xr-x     1 jamilraichouni  staff      37 May  7 10:19 .zshrc -> /Users/jamilraichouni/My Drive/.zshrc',
 'lrwxr-xr-x     1 jamilraichouni  staff      11 May 12 12:22 DB -> My Drive/DB',
 'lrwxr-xr-x     1 jamilraichouni  staff      38 May  6 08:07 Desktop -> /Users/jamilraichouni/My Drive/Desktop',
 'lrwxr-xr-x     1 jamilraichouni  staff      40 May  8 12:24 Downloads -> /Users/jamilraichouni/My Drive/Downloads',
 'lrwx------     1 jamilraichouni  staff      20 May 20 20:19 Google Drive -> /Volumes/GoogleDrive',
 'lrwxr-xr-x     1 jamilraichouni  staff      12 May 12 12:22 JAR -> My Drive/JAR',
 'lrwxr-xr-x     1 jamilraichouni  staff      12 May 11 07:05 bak -> My Drive/bak',
 'lrwxr-xr-x     1 jamilraichouni  staff      30 May 16 22:01 mydrive -> /Users/jamilraichouni/My Drive',
 'lrwxr-xr-x     1 jamilraichouni  staff      34 May  6 08:12 tmp -> /Users/jamilraichouni/My Drive/tmp']
```

### Recipe(python): Inject IPython kernel with GDB

Developing EASE scripts with Python can be tedious. It is of great help to be
able to run an EASE script and be able to halt and get an IPython command line
with the scope at a specified location.

#### Preconditions

1. Install the GNU Project Debugger (GDB), e. g. `apt-get install gdb`
1. Install Python debug symbols, e. g. `apt-get install python3-dbg`

   (provides at least `/usr/share/gdb/auto-load/usr/bin/pythonx.ym-gdb.py`)

1. Install Python packages `ipykernel` and `jupyter`, e. g.
   `pip install ipykernel jupyter`
1. Create a custom gdb Python extension for easy injection of Python code into
   a halted (breakpoint) Python process:

   - Create a file `~/.gdbextension.py` with the following content:

     ```python
     import gdb

     def lock_GIL(func):
         def wrapper(*args):
             state = gdb.parse_and_eval("PyGILState_Ensure()")
             result = func(*args)
             gdb.parse_and_eval(f"PyGILState_Release({state})")
             return result

         return wrapper


     class Py(gdb.Command):
         def __init__(self):
             super(Py, self).__init__ (
                 "py",
                 gdb.COMMAND_NONE
             )

         @lock_GIL
         def invoke(self, command, from_tty):
             if command[0] in ('"', "'",):
                 command = command[1:]
             if command[-1:] in ('"', "'",):
                 command = command[:-1]
             cmd_string = f"exec('{command}')"
             gdb.execute(f'call PyRun_SimpleString("{cmd_string}")')


     class PyFile(gdb.Command):
         def __init__(self):
             super(PyFile, self).__init__ (
                 "pyfile",
                 gdb.COMMAND_NONE
             )

         @lock_GIL
         def invoke(self, filename, from_tty):
             cmd_string = f"with open('{filename}') as f: exec(f.read())"
             gdb.execute(f'call PyRun_SimpleString("{cmd_string}")')

     Py()
     PyFile()
     ```

   - Paste the next code snippet into a file `~/.gdbinit`.

     You may need to adapt the file path in the first line of the code snippet.

     ```bash
     source /usr/share/gdb/auto-load/usr/bin/python3.9-gdb.py
     source ~/gdbextension.py
     set history save on
     set history filename ~/.gdb_history
     ```

#### Steps

Note: when you want to do the next in a Docker container you must set the
following flags of the `docker run` command:
`--cap-add=SYS_PTRACE --security-opt seccomp=unconfined`

One can also specify these special run flags in a `docker-compose.yaml`:

```yaml
version: "3"

services:
  common:
    cap_add:
      # enable debugging with GDB:
      - SYS_PTRACE
    security_opt:
      # Run without the default seccomp profile to enable debugging with GDB:
      # https://docs.docker.com/engine/security/seccomp/
      - "seccomp=unconfined"
```

1. Prepare the script of interest you want to debug in an IPython command line
   shell by placing the following line at the location of interest:
   `import os; print(os.getpid()); breakpoint()`
1. Execute the script and note the PID that will be printed onto the console
1. Start GDB: `$ gdb`
1. In GDB

   ```text
   (gdb) attach <PID>
   (gdb) py "import IPython; IPython.embed_kernel()"
   ```

   This injects an IPython kernel at the line where you placed above Python
   code snippet that ends with a `breakpoint()` statement.

1. In a separate shell run `$jupyter console --existing kernel-<PID>.json`

### Recipe(vim): Change case in vim

see
<https://stackoverflow.com/questions/2946051/changing-case-in-vim/2966034#2966034>

`gu<motion>` to change to lowercase `gU<motion>` to change to uppercase

**Examples:**

`guaw` to lowercase for a word `guap` to lowercase for a paragraph

### Recipe(vim): LSP

#### Increase LSP log level

```
:lua vim.lsp.set_log_level("debug")
```

### Recipe(vim): Recent files

```vim
:browse oldfiles
```

```vim
:browse filter /pattern/ oldfiles
```

### Recipe(vim): Search and replace

#### Replace null bytes with blanks

```vim
:%s/\%x00/ /g
```

### Recipe(vim): Show who last set a key mapping in vim

`:verbose imap <tab>` for instance

### Recipe(vim): Sort lines and make them unique

`:sort u`

### Recipe(vim): Tags

1. Install `ctags`
1. Create a tags file: `:!ctags -R .` or `:!ctags -R <PY_PKG_NAME>`
1. Add the `tags` to the `.gitignore`
1. Jump to a function, module etc. name by `:tag <PATTERN>`

### Recipe(vim): Highlight under cursor

Command `:Inspect`

### Recipe(vim): Folds

Create a manual fold:

`zf{motion}` (e. g. `zf3j`) `:<range>zf`

Open, close, delete a fold under cursor:

- `zo`
- `zc` when foldmethod=manual or marker
- `zd` when foldmethod=manual or marker

Eliminate all folds in window:

- `zD` when foldmethod=manual or marker

Open, close all folds globally and recursively:

- `zR`
- `zM`

Open, close all folds in block under cursor and recursively:

- `zr`
- `zm`

### Recipe(vim): Filter lines into # buffer

```vim
:vimgrep PATTERN %
:cwindow
```

### Recipe(vim): Edit in multiple lines

`:[range]norm <commands>`

Examples:

1. Append a semicolon in the current and the next four lines:

`:.,+4norm A;`

### Recipe(vim): Wrap text by line length limit (textwidth)

1. Set the text width via

   - `:setl[ocal] tw=72` for docstrings or
   - `:setl[ocal] tw=79` for Python code

1. Format a paragraph via the keymap `gwap` or a line via `Shift+V` visual mode
   line selection and the keymap `gw`.

### Recipe(vim): Plugin management with `packer`

```bash
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

### Recipe(vim): Stage hunks or copy between diff files

- Install the plugin [vim-fugitve](https://github.com/tpope/vim-fugitive)
- Open the file where you want to stage hunks in a buffer
- Run the vim command `:Gvdiffsplit` (left is indexc, right is working file)
- On the right to stage hunks:
  - visually select lines with shift+v and optional movements with j etc.
  - Run the vim commands
    - `:diffput` / map: dp - like diff put - (right to left: working copy to
      index) to stage or
    - `:diffget` / map: do - like diff obtain - (left to right: index to
      working copy) to undo change

### Recipe(vim): Get diff for a specific commit in history of a given file

1. Load file of interest into a buffer
1. Command `:Gllog`
1. Select commit of interest in location list (navigate in list with `:lnext`
   and `:lprevious`)
1. Press Enter to see changes of commit
1. In new window select any line starting with `diff -- (...)`
1. Press `o` for diff in horizontal split or `O` for diff in a new tab page

### Recipe(vifm): Navigation

Go one level up: `gh`, `:cd ..`

### Recipe(vifm): Toggle views

#### Tree view

Enter `:tree`, leave: `gh`

Toggle: `:tree!`

Depth control: `:tree depth=2` or `:tree depth=3`

Toggle directory fold: `zx`

#### Panes

Dual panes: `:split` or `:vsplit`, single pane: `:only`

### Recipe(vifm): Compare dirs

Set paths in both panes and command `:compare`. Press `h` to leave the compare
view.

### Recipe(vifm): Compare files

Select the files in the panes using `t` and command `:diff`

### Recipe(macos): Brightness of displays

https://github.com/MonitorControl/MonitorControl/releases

### Recipe(macos): Change hostname and computer name on MacOS

```bash
NAME=...;
sudo scutil --set HostName $NAME && \
scutil --set LocalHostName $NAME && \
scutil --set ComputerName $NAME;
```

### Recipe(macos): Disable annoying lock screen key

defaults write com.apple.loginwindow DisableScreenLockImmediate -bool yes

### Recipe(devcontainer): Run GUI applications in Docker container

- Download and install XQuartz from https://www.xquartz.org/
- Register `XQuartz` as login item (macOS' autostart)
- Reboot
- Open the `XQuartz.app`, go to the settings tab "Security" and tick the
  checkbox "Allow connections from network clients"
- Restart `XQuartz`
- On the host put the following into your shell profile (e.g. `~/.zshrc`)

  ```bash
  if [ -z "$DOCKER_XHOST_SET" ]; then
    xhost +local:docker > /dev/null 2>&1
    export DOCKER_XHOST_SET=1
  fi
  ```

- Run a container via

  ```bash
  docker run (...) -e DISPLAY="host.docker.internal:0.0" \
      -v /tmp/.X11-unix:/tmp/.X11-unix -it (...)
  ```

## Raspberry PI

### Format SD card

https://www.sdcard.org/downloads/formatter/sd-memory-card-formatter-for-mac-download/

### Download and install Ubuntu Server

Download https://downloads.raspberrypi.org/imager/ for your operating system on
which you want to prepare the SD card.

Once this is done, start the Imager and open the `CHOOSE OS` menu. Scroll down
the menu click `Other general-purpose OS`.

Customize the OS and edit settings for user authentication, ssh etc..

How to install Ubuntu Server on your Raspberry Pi:

https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi

### First start

- Insert the SD card
- Connect the power supply

On the client that wants to connect to the `raspberrypi` it can be needed to
remove a line from `~/.ssh/known_hosts` that starts with the IP address of the
Raspberry PI

We can login to the CLI with the user data we customized before. It may be
defined in `~/.ssh/config` as

```sshconfig
Host raspberrypi
    HostName raspberrypi
    Port 22
    User jamil
    IdentityFile ~/.ssh/id_rsa
```

Run `sudo apt-get install -y kitty-terminfo`

### Ensure packages are updated to the latest version

```bash
sudo apt update    # re-read package lists
sudo apt upgrade   # update installed packages if possible
```

### Install Docker

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
# logout and login
```

```bash
sudo chown root:docker /var/run/docker.sock
```

### Setup engine-room

```bash
sudo apt-get install -y \
  git \
  net-tools \  # to check open ports with netstat
  unzip \  # needed by vim
  zsh
sudo usermod --shell /bin/zsh jamil
```

Put the following into the file `/home/jamil/.zshrc`:

```shell
PROMPT="%F{magenta}%n%f"  # Magenta user name
PROMPT+="@"
PROMPT+="%F{blue}${${(%):-%m}#zoltan-}%f" # Blue host name, minus zoltan
PROMPT+=" "
PROMPT+="%F{yellow}%1~ %f" # Yellow working directory
PROMPT+=$'\n'
PROMPT+=$" "
```

Create a file `sudo vim /etc/systemd/system/engine-room.service`:

```systemd
[Unit]
Description=Engine Room Service
After=network.target

[Service]
Type=simple
User=jamil
Environment=PYTHONPATH=/home/jamil
ExecStart=/usr/bin/python3 -m engine-room run ja
Restart=on-failure

[Install]
WantedBy=default.target
```

Reload systemd to recognize the new service:

```bash
sudo systemctl daemon-reload
```

Enable the service to start on boot:

```bash
sudo systemctl enable engine-room.service
```

Start the service:

```bash
sudo systemctl start engine-room.service
```

## Neovim help files

- api.txt
- arabic.txt
- autocmd.txt
- change.txt
- channel.txt
- cmdline.txt
- credits.txt
- debug.txt
- deprecated.txt
- dev_arch.txt
- develop.txt
- dev_style.txt
- dev_theme.txt
- dev_tools.txt
- dev_vimpatch.txt
- diagnostic.txt
- diff.txt
- digraph.txt
- editing.txt
- editorconfig.txt
- faq.txt
- filetype.txt
- fold.txt
- ft_ada.txt
- ft_hare.txt
- ft_ps1.txt
- ft_raku.txt
- ft_rust.txt
- ft_sql.txt
- gui.txt
- health.txt
- hebrew.txt
- helphelp.txt
- help.txt
- if_perl.txt
- if_pyth.txt
- if_ruby.txt
- indent.txt
- index.txt
- insert.txt
- intro.txt
- job_control.txt
- lsp.txt
- lua-bit.txt
- lua-guide.txt
- luaref.txt
- lua.txt
- luvref.txt
- map.txt
- mbyte.txt
- message.txt
- mlang.txt
- motion.txt
- news-0.10.txt
- news-0.9.txt
- news.txt
- nvim.txt
- options.txt
- pattern.txt
- pi_gzip.txt
- pi_msgpack.txt
- pi_paren.txt
- pi_spec.txt
- pi_tar.txt
- pi_tutor.txt
- pi_zip.txt
- provider.txt
- quickfix.txt
- quickref.txt
- recover.txt
- remote_plugin.txt
- remote.txt
- repeat.txt
- rileft.txt
- russian.txt
- scroll.txt
- sign.txt
- spell.txt
- starting.txt
- support.txt
- syntax.txt
- tabpage.txt
- tags
- tagsrch.txt
- terminal.txt
- testing.txt
- tips.txt
- treesitter.txt
- tui.txt
- uganda.txt
- ui.txt
- undo.txt
- userfunc.txt
- usr_01.txt
- usr_02.txt
- usr_03.txt
- usr_04.txt
- usr_05.txt
- usr_06.txt
- usr_07.txt
- usr_08.txt
- usr_09.txt
- usr_10.txt
- usr_11.txt
- usr_12.txt
- usr_20.txt
- usr_21.txt
- usr_22.txt
- usr_23.txt
- usr_24.txt
- usr_25.txt
- usr_26.txt
- usr_27.txt
- usr_28.txt
- usr_29.txt
- usr_30.txt
- usr_31.txt
- usr_32.txt
- usr_40.txt
- usr_41.txt
- usr_42.txt
- usr_43.txt
- usr_44.txt
- usr_45.txt
- usr_toc.txt
- various.txt
- vi_diff.txt
- vietnamese.txt
- vim_diff.txt
- vimeval.txt
- vimfn.txt
- visual.txt
- vvars.txt
- windows.txt
