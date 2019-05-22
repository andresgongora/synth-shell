<!--------------------------------------+-------------------------------------->
#                                  Introduction
<!--------------------------------------+-------------------------------------->
My personal collection of bash scripts. Some are actually useful ;)


*DISCLAIMER*
Note that some script snippets might be from third parties.
I collected them over many years from forums, wikis, and chats.
The original authors, if known, are referenced within the individual scripts.
If you recognize cone in a script (especially the older ones) as your own
or know the author, and the file has no reference, kindly let me know.




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
#                                  Installation
<!--------------------------------------+-------------------------------------->

These are simple scripts which do not require an installation as such.
However, some script might depend on third party packages which might require
your manual intervention. CHeck the content of each script for details.

Some general remarks:

* Remember to allow the scripts to execute (i.e. chmod +x script_name).
* The usefulness of the scripts lays, exclusively, in the way you use them.
  There are really no rules, but consider the following:
	* Some scripts are most useful when called with a keyboard shortcut 
	  rather than from the terminal. 
	* Others are meant to work with cron to do periodical work.
	* Usually, the scripts inside "terminal" are meant to be copied into 
	  your ~/.bashrc file, or alternatively, sourced from within.




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

