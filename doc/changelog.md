<!--------------------------------------+-------------------------------------->
#                                      v2.1
<!--------------------------------------+-------------------------------------->

- Update README
- Fix bug that prevented correct reading of user config files






<!--------------------------------------+-------------------------------------->
#                                      v2.1
<!--------------------------------------+-------------------------------------->

- Update README
- Fix uninstaller bug (now uses quick-uninstall files left by installer, if available)
- New info elements (some are optional and not shown by default)
- Minor bug fixes
- Improve installer






<!--------------------------------------+-------------------------------------->
#                                      v2.0
<!--------------------------------------+-------------------------------------->

- Rename the repository from scripts to synth-shell
- Remove all unnecessary scripts






<!--------------------------------------+-------------------------------------->
#                                      v1.5
<!--------------------------------------+-------------------------------------->

- Include optional git info in bash prompt (idea by fikoborizqy)
- Bugfixes
- Add script to shorten path ways without truncating folder names
- General code cleanup
- Faster response time (removed `load_config`)
- In `status.sh`: logo and info are separate entities than can be printed separately
- In `status.sh`: info elements are now completely customizable (what to print, and in what order)
- New `common` script to control the terminal cursor and print text-blocks side by side
- `status.sh` now only prints those elements that fit inside the screen, decided automatically based on character count. For example, if the terminal is too narrow, it does not print the logo, and if the terminal is extremely narrow, it does not print any information at all.
- An uninstall script is generated inside the installation folder, such that it's now easier to remove all scripts without having to download this repository again.
- More engaging example configuration files for `status.sh`






<!--------------------------------------+-------------------------------------->
#                                      v1.4
<!--------------------------------------+-------------------------------------->

- Fix bug when some commands are not found with which
- Date format is now configurable
- Fix "Y" error message when using config file
- Fix error messages on some distros when `which` command failed
- Status.sh does no longer pollute the environment with stray functions or variables
- Fix to load_config where the configuration might be interpreted as escape sequences
- Smart installer lets you install for a single user or system wide
- Other minor fixes
- Overall code cleanup




