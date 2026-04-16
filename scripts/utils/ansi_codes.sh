#!/usr/bin/env bash

RED='\e[1;31m'
RED_DARK='\e[0;31m'
GREEN='\e[1;32m'
GREEN_DARK='\e[0;32m'
YELLOW='\e[1;33m'
BROWN='\e[0;33m'
BLUE='\e[1;34m'
BLUE_DARK='\e[0;34m'
PURPLE='\e[1;35m'
PINK='\e[0;35m'
CYAN='\e[1;36m'
CYAN_DARK='\e[0;36m'
WHITE='\e[1;37m'
GREY='\e[0;37m'
INVERT='\e[7m'
INVERT_BLK='\e[27m'
UNDERLINE='\e[4m'
UNDERLINE_BLK='\e[24m'
BLK='\e[0;0m'

TOPLEFT='\e[0;0H'            ## Move cursor to top left corner of window
NOCURSOR='\e[?25l'           ## Make cursor invisible
SHOWCURSOR='\e[?25h'           ## Make cursor visible
NORMAL_OP='\e[0m\e[?12l\e[?25h'   ## Resume normal operation
SAVE_CURSOR='\e7'
RESTORE_CURSOR='\e8'
CLEAR_LINE='\e[K'
CLEAR_SCREEN='\e[2J'
CLEAR_2BOTTOM_SCREEN='\e[0J'
CLEAR_2TOP_SCREEN='\e[1J'

function export_colors() {
    export RED RED_DARK GREEN GREEN_DARK YELLOW BROWN BLUE BLUE_DARK PURPLE \
           PINK CYAN CYAN_DARK WHITE GREY INVERT INVERT_BLK UNDERLINE \
           UNDERLINE_BLK BLK
}

function unset_colors() {
    unset RED RED_DARK GREEN GREEN_DARK YELLOW BROWN BLUE BLUE_DARK PURPLE \
          PINK CYAN CYAN_DARK WHITE GREY INVERT INVERT_BLK UNDERLINE \
          UNDERLINE_BLK BLK
}
