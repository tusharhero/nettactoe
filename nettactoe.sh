#!/bin/bash
# nettactoe.sh - Netcat Tic Tac Toe
# Copyright (C) 2024 tusharhero

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

function clear {
    printf '\033c'
}

function get_array_element {
    local array=$1
    local y=$2
    local x=$3
    local row=$(echo $array | cut -d";" -f $y -)
    local element=$(echo $row | cut -d"," -f $x -)
    echo $element
}

function set_array_element {
    local array=$1
    local y=$2
    local x=$3
    local newvalue=$4
    local row=$(echo $array | cut -d";" -f $y -)
    row=$(echo "$row" | awk -F "," -v newvalue="$newvalue" -v x="$x" 'BEGIN{FS=OFS=","} {$x=newvalue; print}' )
    array=$(echo "$array" | awk -F ";" -v newvalue="$row" -v y="$y" 'BEGIN{FS=OFS=";"} {$y=newvalue; print}')
    echo $array
}
