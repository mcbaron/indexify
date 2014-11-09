#!/bin/bash

## indexify.sh: a script to create/update an index.md file of systems in the current directory.
##
##    Usage: indexify [options] <argv> ...
##
##    Options:
##      -h        show help options.
##      -c        create new index.md.
##      -i        show information about index.md.
##      -u        update existing index.md from current directory.
##      -e <file> add explaination to filename.
##

#- index.md: the constructed markdown index file from indexify.sh, which
#- 		(should) follow 'proper' markdown syntax.
#-    The name of the vehicle is kept at the top as the primary header
#-    File groups are written as secondary headers,
#-          seperating raw data from systems, prfx files, etc.
#-    Filenames are kept as list elements, with dashes, and comments are
#-          in block quotes beneath each entry, with a waka ">"

help=$(grep "^## " "${BASH_SOURCE[0]}" | cut -c 4-)
form=$(grep "^#- " "${BASH_SOURCE[0]}" | cut -c 4-)

diff(){
    a1="$1"
    a2="$2"
    awk -va1="$a1" -va2="$a2" '
     BEGIN{
       m= split(a1, A1," ")
       n= split(a2, t," ")
       for(i=1;i<=n;i++) { A2[t[i]] }
       for (i=1;i<=m;i++){
            if( ! (A1[i] in A2)  ){
                printf A1[i]" "
            }
        }
    }'
}

associate() {
# associate expects the third argument to already be declared an A-array,
# done with 'declare -A arg3'
# We also assume every file to have a single, one line comment
    a1="$1"  # keys (filename)
    a2="$2"  # values (comment)
    out="$3"

    for  i in `seq 0 ${#a1[@]}`
    do
      out["${a1[i]}"]="${a2[i]}"
    done
}


opt_h() {
   echo "$help"
}

opt_i() {
   echo "$form"
}

opt_create() {
  FILES=$(ls $PWD)
  touch index.md
  parent=$(dirname $PWD)
  grandparent=$(dirname $parent)
  echo -e "$grandparent \n ==== \n\n" > index.md
  for f in $FILES
  do
    echo -e "-- $f \n > -" >> index.md
  done
}

opt_update() {
  touch odd.mk
  touch a.mk
  FILES=$(ls $PWD)
  list=$(grep "^-- " index.md | cut -c 4-)
  comm=$(grep "^> " index.md | cut -c 2-)
  add=( $(diff "$FILES" "$list") )

  list=($list)
  comm=($comm)
  declare -A myindex
  associate "$list" "$comm" "$myindex"

  write=("${list[@]}" "${add[@]}")

  echo " --------- "
  echo ${myindex[@]}
#  echo ${write[@]} | awk 'BEGIN{RS=" ";} {print $1}' | sort
}

opt_explain() {
#  echo ${!#} > index.md
echo $#
echo $@ > index.md
}

while getopts ":cue::hi" opt; do
  case $opt in
    h)
      eval "opt_h"
      exit 0
      ;;
  	i)
      eval "opt_i"
      exit 0
      ;;
    c)
      eval "opt_create"
      exit 0
      ;;
    u)
      eval "opt_update"
      exit 0
      ;;
    e)
      shift $(($OPTIND -1))

      opt_explain $OPTARG $1
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires a filename." >&2
      exit 1
      ;;
  esac


done


