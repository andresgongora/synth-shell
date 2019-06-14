<!--------------------------------------+-------------------------------------->
#                               Bash coding style
<!--------------------------------------+-------------------------------------->

This document is intended as a primer and reference to ensure a consistent style
between all scripts and auxiliary files (e.g. config files). This file will
slowly grow as needed.






<!--------------------------------------+-------------------------------------->
#                                    Variables
<!--------------------------------------+-------------------------------------->

### Global variables

Avoid global variables unless strictly needed. Even if they are meant to be
unset at the end of the script, it is always possible that the script stops
prematurely or that the developer forgets about it. Global variables can
_contamiante_ the user's run space and lead to unexpected behaviour.

Global variables are named in uppercase and using underscores.

```
MY_VAR=2
MY_SUPER_STRING="Hello world!"
```



## Local variables

Declare _local_ variables using `local` rather than `declare` or other options.
Because local variables can not be declared in the main body of the script,
this will enforce wrapping everithing into functions, which is not a bad thing. 

Local variables are named all in lower case and using underscores.

```
local my_var=2
local my_super_string="Hello world!"
```






<!--------------------------------------+-------------------------------------->
#                                    Functions
<!--------------------------------------+-------------------------------------->

Each function shall do only one thing, otherwise, the function shall be
divided into two separate functions. Following this rule is not always easy,
but it ensures that the code is easy to read, modular and reusable.

Functions are named using camel case, with the first letter in lower case. Also,
all names must be or contain a verb that describes the action that will
performed by the function. An exception to this rule is when the function
returns (prints) a boolean. In this case, the function starts with `is` or
`has` to make it easier to read.

```
getNewValue()
printTemperature()
lockSystem()
getGPSCoordinates()
reload()
isSystemOverloaded()
hasEnoughMemory()
```






<!--------------------------------------+-------------------------------------->
#                                  Tabs vs spaces
<!--------------------------------------+-------------------------------------->

* **Tabs** for indenting
* **Spaces** for alignment (its rarely needed)

```
getData()
{
<tab> if [ $VAR -gt 2 ]; then
<tab> <tab> aux_var=$(pollSystem "/home/user/made/up/path" |\
<tab> <tab> <spaces............> head -n 1" |\
<tab> <tab> <spaces............> sed '/somereggexblackmagic' |
<tab> <tab> <spaces............> tr -d " ")
<tab> <tab> echo "$aux_var"
<tab> fi
}
```

**Why??** - Because some of us just want to see the world burn.






<!--------------------------------------+-------------------------------------->
#                     	           Code structure
<!--------------------------------------+-------------------------------------->

### Line length
Limit lines to 80 characters whenever possible (code + characters). 
Use backslash '\' to continue code on a second line.
This is because of the following reasons:
* Traditionally, temrinals were 80 chars wide. This no longer holds true, but  
  is as good as any other line-length limit in a similar range.
* When working on a single monitor, its useful to visualize two files side  
  by side. With more than 80 characres per line, it becomes difficul unless  
  the scriin is very wide
* When solving conflicts when mergin two files, the same applies; only that  
  this time its useful to visualize 3 files side by side.



### New lines to separate code
If adding new lines to separate chunks of code, use either 1, 2, 3 or 6 lines.

* 1 line if the code is very related
* 2 lines if the code in inside the same function, and the function is short
* 3 lines if the code in inside the same function, and the function is  
    complex. In this case, a "header-comment" must be placed above each chunk  
    explaining what it does.
* 6 lines To separate bigger code sections, like to separate the sections that  
    contain functions with similar functionality or intention.






<!--------------------------------------+-------------------------------------->
#                         Built-in and system functions
<!--------------------------------------+-------------------------------------->


### Use printf (instead echo, etc)
Printf is more versatile to use especially with more complex output lines, so
do use only printf when needing to say something into terminal or variables.
This ensures consistent code, consistent behaviour of text output, so therefore
easier to debug if need ever arises to.


### System binary calls
Please do not call any system binary using only it's name, wrap it in `'`, 
or use `which`. 

For example, do not do call `ls` or `/usr/bin/ls`, as the
former is susceptible to be aliased by the user to a different command, and the
latter might have a different path for a different distro. Instead `'ls'` or
(if need be) `$(which ls)` provide more consistent behaviour.






