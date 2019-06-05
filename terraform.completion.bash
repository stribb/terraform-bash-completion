#!/usr/bin/env bash
#
# Bash completion for the terraform command v0.11.7
#
# Copyright (C) 2018 Vangelis Tasoulas
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# This is not yet complete, but it can autocomplete most of the stuff.
# TODO: Implement autocompletion for the import/output/taint/untaint commands
#       as well as the subcommands for workspace/env/debug/state.

_terraform()
{
	local cur prev words cword opts terrabin
	_get_comp_words_by_ref -n : cur prev words cword
	COMPREPLY=()
	opts=""
	terrabin="${1}"

	# If the user has typed a hyphen, then show all the available parameters that
	# start with a hyphen.
	if [[ ${cword} -eq 1 && ${cur} == -* ]] ; then
		opts="--help --version"
	elif [[ ${cword} -ge 2 && ${cur} == -* ]] ; then
		args="${words[@]:1:${#words[@]}-2}"
		# Extract the hyphened parameters if any.
		opts="$(${terrabin} --help ${args[@]} | grep -E '^\s+-' | awk '{print $1}' | awk -F '=' '{ if ($0 ~ /=/) {print $1"="} else {print $1} }')"
		# And always append --help. Help is something that we can always use.
		opts="${opts} --help"
	else
		if [[ ${cword} -eq 1 ]] ; then
			# If no parameter has been typed in yet, show all the non-hyphened commands available.
			# These are always starting with four spaces as of the current latest terraform version (v0.11.7).
			opts="$(${terrabin} --help | grep -E '^\s\s\s\s\S' | awk '{print $1}')"
		else
			case ${words[1]} in
				apply|console|destroy|fmt|graph|init|plan|providers|push|refresh|validate|force-unlock)
					# Dir autocompletion
						_filedir -d
					;;
				get|show)
					# Path autocompletion
						_filedir
					;;
				import)
					# Addr ID autocompletion
					# ---- not yet implemented ----
					;;
				output|taint|untaint)
					# NAME autocompletion
					# ---- not yet implemented ----
					;;
				workspace|env|debug|state)
					# These commands have different subcommands that each one of them may be accepting further agrguments and provide additional --help
					if [[ ${words[1]} && ${cword} -eq 2 ]]; then
						opts="${opts} $(${terrabin} --help "${words[1]}" | grep -E '^\s\s\s\s\S' | awk '{print $1}')"
					else
						if [[ ${words[1]} == 'state' ]] ; then
							case ${words[2]} in
								show)
									# Auto completion for the "terraform state show" command
									${terrabin} state list > /dev/null 2>&1
									if [[ $? -eq 0 ]]; then
										opts="$(${terrabin} state list)"
									fi
									;;
							esac
						fi
					fi
					;;
				*)
					;;
			esac
		fi
	fi

	if [[ ${#COMPREPLY[*]} -eq 0 ]] ; then
		# If no COMPREPLY, try to generate it from opts. If COMPREPLY exists
		# the _filedir function has been called that already generates it.
		COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
	fi

	if [[ ${#COMPREPLY[*]} -eq 1 ]] ; then
		if [[ ${COMPREPLY[0]} == *= ]] ; then
			# When only one completion is left, check if there is an equal sign.
			# If an equal sign, then add no space after the autocompleted word.
			compopt -o nospace
		fi
	fi
	return 0
}

complete -F _terraform terraform
