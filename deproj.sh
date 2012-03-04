#!/bin/bash

deproj_help() {
  echo "RUN deproj.sh op"
  echo "op  - Operations"
  echo "       create-update-script [alias cup] - Create update script."
  echo "         attributes: project_name, [path_on_server]"
  echo "       create-pack [alias cp] - Create pack for feature server."
  echo "         attributes: project_name"
  echo "       prepare-version [alias pv] - Prepare new version."
  echo "         attributes: project_name, version, [git branches]"
}

if [ $# -lt 1 ]
then
  deproj_help
  exit
fi

# UPDATED in devel branch
# UPDATED in slave branch
#OPERATION create-update-script
#
if [ $1 == 'create-update-script' ] || [ $1 == 'cup' ]
then
  if [ $# -lt 2 ]
  then
    deproj_help
    exit
  fi
  
  #Project name
  proj=$2
  
  if [ $# -eq 3 ]
  then
    path_on_server=$3
  else
    path_on_server="sites/all/modules/custom"  
  fi

  #Obtain current version
  obtain_version="php info_get_version.php $proj/$proj.info"
  ver=`eval $obtain_version`
  
  #Create directory if not exists
  if [ ! -d "$proj/updates" ] 
  then
    mkdir "$proj/updates"
  fi 
  
  #Unlink existing script
  file_name="$proj/updates/update-$ver.sh"
  if [ -r $file_name ]
  then
    unlink_script="unlink $file_name"
    eval $unlink_script
  fi
  
  line1="\#!/bin/bash"
  line2="rm -r $path_on_server/$proj"
  line3="drush dl $proj-$ver --destination=$path_on_server --source=http://fserver.rwcms.cz/fserver"
  line4="\# -- Provedeno na platformach"

  upd_scr1="echo $line1 >> $proj/updates/update-$ver.sh"
  upd_scr2="echo $line2 >> $proj/updates/update-$ver.sh"
  upd_scr3="echo $line3 >> $proj/updates/update-$ver.sh"
  upd_scr4="echo $line4 >> $proj/updates/update-$ver.sh"
  eval $upd_scr1
  eval $upd_scr2
  eval $upd_scr3
  eval $upd_scr4
fi

#
#OPERATION create-pack
#
if [ $1 == 'create-pack' ] || [ $1 == 'cp' ]
then
  if [ $# -lt 2 ]
  then
    deproj_help
    exit
  fi
  
  #Project name
  proj=$2

  #Obtain current version
  obtain_version="php info_get_version.php $proj/$proj.info"
  ver=`eval $obtain_version`
  
  #Compress project
  compress="tar czpfv $2-$ver.tgz --exclude \"$proj/.*\" $proj "
  eval $compress
fi
 
#
#OPERATION prepare-version
#
if [ $1 == 'prepare-version' ] || [ $1 == 'pv' ]
then
  if [ $# -lt 3 ]
  then
    deproj_help
    exit
  fi
  
  if [ $# -eq 4 ]
  then
    branches=$4
  else
    branches="origin master"  
  fi

  #New version
  ver=$3
  #Project name
  proj=$2

  #Set new version into .info
  set_version="php info_set_version.php $proj/$proj.info $ver"
  echo $set_version
  eval $set_version
  
  cd ./$proj
  
  #Add changes
  add_changes="git add $proj.info"
  echo $add_changes
  eval $add_changes
  
  #Create git tag
  create_tag="git tag -a $ver -m \"Starting new version $ver.\""
  echo $create_tag
  eval $create_tag
  
  #Git push
  #git_push="git push $branches --tags"
  #echo $git_push
  #eval $git_push
  
  cd ..
fi
