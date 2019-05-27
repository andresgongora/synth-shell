#!/bin/bash

fun2()
{
	echo "$variable"
	if [ -z $HOME ]; then
		echo ":)"
	else
		echo "$HOME"
	fi
}

fun()
{
	local variable=13
	local HOME=4




	fun2

}

fun
echo $HOME
