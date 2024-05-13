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
  [ $1 -gt $2 ] && echo $1 || echo $2
}

function min {
  [ $1 -lt $2 ] && echo $1 || echo $2
}

function clamp {
    local value=$1
    local min_value=$2
    local max_value=$3
    local firstValue=$(max $value $min_value)
    local returnValue=$(min $firstValue $max_value)

    echo "$returnValue"
}

function get_row {
  echo $1 | cut -d";" -f $2 -
}

function get_cell {
  echo $1 | cut -d"," -f $2 -
}

function get_array_element {
    local array=$1
    local y=$2
    local x=$3
    local row=$(get_row "$array" "$y")
    local element=$(get_cell "$row" "$x")
    echo "$element"
}

function set_array_element {
    local array=$1
    local y=$2
    local x=$3
    local newvalue=$4
    local row=$(get_row "$array" "$y")
    row=$(printf "$row" | awk -F "," -v newvalue="$newvalue" -v x="$x" 'BEGIN{FS=OFS=","} {$x=newvalue; print}' )
    array=$(printf "$array" | awk -F ";" -v newvalue="$row" -v y="$y" 'BEGIN{FS=OFS=";"} {$y=newvalue; print}')
    echo $array
}

function render_array {
    printf "$(echo $1 | sed -e 's/,//g' -e 's/;/\\n/g')\n"
}

function check_game {
    local array=$1
    for y in {1..3}; do
	[ "$(get_array_element $array $y 1)" == "⬛️" ] || \
	{ [ "$(get_array_element $array $y 1)" == "$(get_array_element $array $y 2)" ] && \
	    [ "$(get_array_element $array $y 2)" == "$(get_array_element $array $y 3)" ] && \
	    { printf "$(get_array_element $array $y 1)"; return 0; } }
    done
    for x in {1..3}; do
	[ "$(get_array_element $array 1 $x)" == "⬛️" ] || \
	{ [ "$(get_array_element $array 1 $x)" == "$(get_array_element $array 2 $x)" ] && \
	    [ "$(get_array_element $array 2 $x)" == "$(get_array_element $array 3 $x)" ] && \
	    { printf "$(get_array_element $array 1 $x)"; return 0; } }
    done
    [ "$(get_array_element $array 2 2)" == "⬛️" ] || \
    { { [ "$(get_array_element $array 1 1)" == "$(get_array_element $array 2 2)" ] && \
	[ "$(get_array_element $array 2 2)" == "$(get_array_element $array 3 3)" ]; } || \
	   { [ "$(get_array_element $array 3 1)" == "$(get_array_element $array 2 2)" ] && \
		[ "$(get_array_element $array 2 2)" == "$(get_array_element $array 1 3)" ]; } && \
		{ printf "$(get_array_element $array 2 2)"; return 0; }; }

    [ $(printf $array | sed 's/[^⬛]//g' | wc --chars) == 0 ] && { printf 'no one'; return 0;}
}

function make_move {
    local game=$1
    local player=$2
    local move=$3
    local y=$(printf $move | cut -d"," -f 1 -)
    y=$(clamp $y 1 3)
    local x=$(printf $move | cut -d"," -f 2 -)
    x=$(clamp $x 1 3)
    block="$(get_array_element $game $y $x)"
    if [ "$block" == "⭕" ] || [ "$block" == "❌" ]; then
      read -p "That block is preoccupied, please enter new move: " move
      make_move $game $player $move
    else
      echo $(set_array_element $game $y $x $player);
    fi
}

function restart_game {
    if ! [ -z $result ]; then
	clear
	render_array $game
	echo $result won!
	read -p "do you want to play again?[Y/N]" restart
	if [ "$restart" == 'Y' ]; then
	    echo restarting game!
	    game=$new_game
	    no_moves=0
	else
	    exit
	fi
    fi
}

function server {
    coproc SERVER { nc -l -p 4444; }
    echo "Waiting for a client to join.."
    read <&"${SERVER[0]}"
    echo "client has joined!"
    new_game="⬛,⬛,⬛️;⬛️,⬛️,⬛️;⬛️,⬛️,⬛️"
    game=$new_game
    no_moves=0
    while true; do
	render_array $game
	echo "$game" >&"${SERVER[1]}"
	result=$(check_game $game)
	restart_game
	player=$([ "$(( $no_moves % 2))" == 0 ] && echo "⭕" || echo "❌")
	if [ "$player" = "⭕" ]; then
	    read -p "$player Enter move: " move
	    game=$(make_move $game $player $move);
	else
	    echo "Waiting for ❌ to make a move"
	    read -r game <&"${SERVER[0]}"
	fi
	no_moves=$((no_moves+1))
    done
}

function client {
    read -p "Enter the IP address of the server: " -i "localhost" -e server_ip
    read -p "Enter the port of nettactoe server: " -i "4444" -e server_port
    coproc CLIENT { nc $server_ip $server_port; }
    echo "Connected" >&"${CLIENT[1]}"
    no_moves=0
    while true; do
	read -r game <&"${CLIENT[0]}"
	render_array $game
	result=$(check_game $game)
	restart_game
	player=$([ "$(( $no_moves % 2))" == 0 ] && echo "⭕" || echo "❌")
	if [ "$player" = "❌" ]; then
	    read -p "$player Enter move: " move
	    game=$(make_move $game $player $move);
	    echo $game >&"${CLIENT[1]}"
	else
	    echo "Waiting for ⭕ to make a move"
	fi
	no_moves=$((no_moves+1))
    done
}

printf "
███    ██ ███████ ████████ ████████  █████   ██████ ████████  ██████  ███████ 
████   ██ ██         ██       ██    ██   ██ ██         ██    ██    ██ ██      
██ ██  ██ █████      ██       ██    ███████ ██         ██    ██    ██ █████   
██  ██ ██ ██         ██       ██    ██   ██ ██         ██    ██    ██ ██      
██   ████ ███████    ██       ██    ██   ██  ██████    ██     ██████  ███████ 
"                                                                              
printf "Copyright (C) 2024 tusharhero\n\n"
printf "Hit return to start\n"
read
clear
printf "Start a server (client can connect to it): server\nConnect to a server: client\n"
read -p ": " mode

case "$mode" in
    [C,c]* ) client ;;
    [S,s]* ) server ;;
    * ) echo "I don't know what mode you are talking about." ;;
esac
