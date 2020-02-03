<!--------------------------------------+-------------------------------------->
#                                     v2.3
<!--------------------------------------+-------------------------------------->

-






<!--------------------------------------+-------------------------------------->
#                                     v2.4
<!--------------------------------------+-------------------------------------->

- Better README.
- Add alias scripts.
- Add better-ls script.
- Add reminder during installation of optional packages.






<!--------------------------------------+-------------------------------------->
#                                     v2.3
<!--------------------------------------+-------------------------------------->

- Abridged installation steps.
- Quick 256-color reference in fancy-bash-prompt.config, suggested by Omega100.
- Added note to make sure UTF-8 is enabled in locale config, suggested by dzionek.
- Added symbol to indicate status of the current git branch if current workdir is inside git branch. Inspired by twolfson's sexy-bash-prompt (https://github.com/twolfson/sexy-bash-prompt).






<!--------------------------------------+-------------------------------------->
#                                     v2.2
<!--------------------------------------+-------------------------------------->

- Improvement and fixes to textfiles and code comments.
- Fixed "N/A" message printed for SWAP_MON if there is no swap (reported by jhakonen).
- Add preview of the configuation options for status.sh.
- fancy_bash_prompt: Update titlebar of terminal-window when changing folder (reported by jhakonen).






<!--------------------------------------+-------------------------------------->
#                                    v2.1.5
<!--------------------------------------+-------------------------------------->

- Fix top delay parameter to avoid conflicts depending on locale config, reported by b1oki.






<!--------------------------------------+-------------------------------------->
#                                v2.1.3 & v2.1.4
<!--------------------------------------+-------------------------------------->

- Fix long GPU name issue, reported by slink007.






<!--------------------------------------+-------------------------------------->
#                                v2.1.1 & v2.1.2
<!--------------------------------------+-------------------------------------->

- Update README.
- Fix bug that prevented correct reading of user config files.
- SUpport for multiple GPUs.






<!--------------------------------------+-------------------------------------->
#                                      v2.1
<!--------------------------------------+-------------------------------------->

- Update README
- Fix uninstaller bug (now uses quick-uninstall files left by installer, if available).
- New info elements (some are optional and not shown by default).
- Minor bug fixes.
- Improve installer.






<!--------------------------------------+-------------------------------------->
#                                      v2.0
<!--------------------------------------+-------------------------------------->

- Rename the repository from scripts to synth-shell.
- Remove all unnecessary scripts.






<!--------------------------------------+-------------------------------------->
#                                      v1.5
<!--------------------------------------+-------------------------------------->

- Include optional git info in bash prompt (idea by fikoborizqy).
- Bugfixes.
- Add script to shorten path ways without truncating folder names.
- General code cleanup.
- Faster response time (removed `load_config`).
- In `status.sh`: logo and info are separate entities than can be printed separately.
- In `status.sh`: info elements are now completely customizable (what to print, and in what order).
- New `common` script to control the terminal cursor and print text-blocks side by side.
- `status.sh` now only prints those elements that fit inside the screen, decided automatically based on character count. For example, if the terminal is too narrow, it does not print the logo, and if the terminal is extremely narrow, it does not print any information at all.
- An uninstall script is generated inside the installation folder, such that it's now easier to remove all scripts without having to download this repository again.
- More engaging example configuration files for `status.sh`.






<!--------------------------------------+-------------------------------------->
#                                      v1.4
<!--------------------------------------+-------------------------------------->

- Fix bug when some commands are not found with which.
- Date format is now configurable.
- Fix "Y" error message when using config file.
- Fix error messages on some distros when `which` command failed.
- Status.sh does no longer pollute the environment with stray functions or variables.
- Fix to load_config where the configuration might be interpreted as escape sequences.
- Smart installer lets you install for a single user or system wide.
- Other minor fixes.
- Overall code cleanup.




