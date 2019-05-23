<!--------------------------------------+-------------------------------------->
#                                  Introduction
<!--------------------------------------+-------------------------------------->
My personal collection of bash scripts. Their application varies wildly from
script to script, including eyecandy for the terminal, productivity tools,
and sys-administration helpers. You can find more details and similar tools on
[Yet Another Linux'n Electronics Blog](https://yalneb.blogspot.com/).


*DISCLAIMER*
Note that some script snippets might be from third parties.
I collected them over many years from forums, wikis, and chats.
The original authors, if known, are referenced within the individual scripts.
If you recognize cone in a script (especially the older ones) as your own
or know the author, and the file has no reference, kindly let me know.




<!--------------------------------------+-------------------------------------->
#                                  Installation
<!--------------------------------------+-------------------------------------->

For now, the easiest way to install this scripts is to clone this repository
and then tell your `.bashrc` file to source those scripts you want.

```
## Clone repository to ~/.config/scripts
cd ~/.config
git clone https://github.com/andresgongora/scripts.git

## Source individual scripts. Choose the ones you want (or all).
echo 'source ~/.config/scripts/terminal/fancy-bash-prompt.sh' >> ~/.bashrc
echo 'source ~/.config/scripts/terminal/alias.sh' >> ~/.bashrc
echo 'source ~/.config/scripts/terminal/status.sh' >> ~/.bashrc
```

If you want to use `fancy-bash-promt.sh` you also need power-line fonts.
Depending on your distro you can install it as:

```
## ArchLinux
sudo pacman -S powerline-fonts

## Ubuntu
sudo apt install fonts-powerline
```

Lastly, you may configure your scripts by editing the individual `.config`
files included in this repo. For example, to configure the colors in
`fancy-bash-promt.sh` or `status.sh`, you can do as follows.

```
## Colors of fancy-bash-promt.sh
nano ~/.config/scripts/terminal/fancy-bash-prompt.config

## Colors and behaviourt of status.sh
nano ~/.config/scripts/terminal/status.config
```




### Manual instalation of individual scripts
If you want to skip the above steps, and are only intereset in a very
specific script, you can easily use it by its own.
However, some scripts might source other scripts from the `common` folder,
as they provided shared functioanlities to all scripts. If you are interested
in a single script from my collection, check whether it depends on a common
script, and copy the content of it into the script you want.
Also, some script might depend on third party packages which might require
your manual intervention. Check the content of each script for details.






<!--------------------------------------+-------------------------------------->
#                                    Overview
<!--------------------------------------+-------------------------------------->

| Folder                	| Script                         	| Description                                          	|
|-----------------------	|--------------------------------	|------------------------------------------------------	|
|                       	|                                	|                                                      	|
| common                      	| color.sh                           	| Colorize and format command line text                	|
| common                      	| load_config.sh                      	| Retrieve script configurations from a file        	|
|                       	|                                	|                                                      	|
| maintenance/archlinux 	| archlinux-update-helper.sh     	| An attempt to make ArchLinux updates more convenient 	|
| maintenance/archlinux 	| yaourt-setup.sh               	| Quick install many usefull packages                  	|
| maintenance/linux     	| clean_tmp_folder.sh            	| Remove old files from /tmp                           	|
| maintenance/network   	| iptables-fast-setup.sh         	| Useful rules for IPTABLES                            	|
| maintenance/network   	| iptables-reset.sh              	|                                                      	|
| maintenance/network   	| scp-speed-test.sh              	| Test remote copy command (SCP) speed                 	|
| maintenance/services  	| oc-perms.sh                    	| Secure file permissions for OwnCloud - After update  	|
| maintenance/services  	| sharkoon-renew-certificates.sh 	| Renew certificates for one of my servers             	|
|                       	|                                	|                                                      	|
| terminal              	| alias.sh                      	| Aliases of common commands for better productivity   	|
| terminal              	| better-history.sh                   	| Configure and wrap the `history` comand             	|
| terminal              	| better-ls.sh                   	| Wrap the `ls` comand for extra utility              	|
| terminal              	| fancy-bash-promt.sh            	| PowerLine style bash prompt                           |
| terminal              	| status.sh                      	| Bash promt greeter with status report               	|
|                       	|                                	|                                                      	|
| utils                    	| invert-colors.sh                 	| Invert X11 colors                                    	|
| utils                    	| listtty.sh                        	| Display available tty interfaces                     	|
| utils                    	| my-audacious-delete.sh            	| Delete from HDD currently playing track              	|
| utils                    	| steam.sh                          	| Helper script to fix steam of linux                  	|
|                       	|                                	|                                                      	|




<!--------------------------------------+-------------------------------------->
#                                   Contribute
<!--------------------------------------+-------------------------------------->

This project is only possible thanks to the effort of and passion of many, 
including mentors, developers, and of course, our beloved coffe vending machine.
If you like this collection of scripts and want to contribute in any way,
you are most welcome.

You can find a detailed list of everyone involved in the development of
these scripts in [AUTHORS.md](AUTHORS.md). Thanks to all of you!



### Help us improve

* Add your own scripts: do you have some cool scripts you wold like to 
  add to this collection? Don't hesitate to create a pull-request or,
  alternatively, contact the authors over email.
* [Report a bug](https://github.com/andresgongora/scripts/issues): 
  if you notice that something is not right, tell us. 
  We'll try to fix it ASAP.
* Become a developer: fork this repo and become an active developer!
* Push your one-time changes: even if its a tiny change, 
  feel free to fill in a pull-request :)



### Git branches

There are two branches in this repository:

* **master**: this is the main branch, and thus contains fully functional 
  scripts. When you want to use the scripts as a _user_, 
  this is the branch you want to clone or download.
* **develop**: this branch contains all the new features and most recent 
  contributions. It is always _stable_, in the sense that you can use it
  without major inconveniences. However, because we are still working on it,
  its very prone to undetected bugs and it might be subject to major
  unanounced changes. If you want to contribute, this is the branch 
  you should pull-request to.




<!--------------------------------------+-------------------------------------->
#                                    License
<!--------------------------------------+-------------------------------------->

Copyright (c) 2014-2019, Andres Gongora - www.andresgongora.com

* This software is released under a GPLv3 license.
  Read [license-GPLv3.txt](LICENSE),
  or if not present, <http://www.gnu.org/licenses/>.

* If you need a closed-source version of this software
  for commercial purposes, please contact the authors.

