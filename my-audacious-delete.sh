#!/bin/bash
#https://yalneb.blogspot.com
#Delete song currently playing on audacious and send it to trash

SONG="$(audtool current-song-filename)"
touch "$SONG"
trash "$SONG"
POSITION=$(audtool --playlist-position)
audtool --playlist-advance
audtool --playlist-delete $POSITION

