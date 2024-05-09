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

function max {
    echo $(( $1 > $2 ? $1 : $2 ))
}

function min {
    echo $(( $1 < $2 ? $1 : $2 ))
}

function clamp {
    local value=$1
    local min_value=$2
    local max_value=$3
    echo $(min $( max $value $min_value ) $max_value)
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

function render_array {
    clear
    printf "$(echo $1 | sed -e 's/,//g' -e 's/;/\\n/g')\n"
}

function check_game {
    local array=$1
    for y in {1..3}; do
	[ $(get_array_element $array $y 1) = "⬛️" ] || \
	{ [ $(get_array_element $array $y 1) = $(get_array_element $array $y 2) ] && \
	    [ $(get_array_element $array $y 2) = $(get_array_element $array $y 3) ] && \
	    { echo $(get_array_element $array $y 1); return 0; } }
    done
    for x in {1..3}; do
	[ $(get_array_element $array 1 $x) = "⬛️" ] || \
	{ [ $(get_array_element $array 1 $x) = $(get_array_element $array 2 $x) ] && \
	    [ $(get_array_element $array 2 $x) = $(get_array_element $array 3 $x) ] && \
	    { echo $(get_array_element $array 1 $x); return 0; } }
    done
    [ $(get_array_element $array 2 2) = "⬛️" ] || \
    { { [ $(get_array_element $array 1 1) = $(get_array_element $array 2 2) ] && \
	[ $(get_array_element $array 2 2) = $(get_array_element $array 3 3) ]; } || \
	   { [ $(get_array_element $array 3 1) = $(get_array_element $array 2 2) ] && \
		[ $(get_array_element $array 2 2) = $(get_array_element $array 1 3) ]; } && \
		{ echo $(get_array_element $array 2 2); return 0; }; }
}

function make_move {
    local game=$1
    local player=$2
    local move=$3
    local y=$(echo $move | cut -d"," -f 1 -)
    y=$(clamp $y 1 3)
    local x=$(echo $move | cut -d"," -f 2 -)
    x=$(clamp $x 1 3)
    echo $(set_array_element $game $y $x $player)
}

game="⬛,⬛,⬛️;⬛️,⬛️,⬛️;⬛️,⬛️,⬛️"
no_moves=0
while true; do
    render_array $game
    result=$(check_game $game)
   [ -z $result ] || echo $result won!
    read -p "Enter move: " move
    player=$([ "$(( $no_moves % 2))" = 0 ] && echo "⭕" || echo "❌")
    game=$(make_move $game $player $move);
    no_moves=$((no_moves+1))
done
