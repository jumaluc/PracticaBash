#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctl_c(){
  
  echo -e "${redColour}\n\n [+] Saliendo...${endColour}"
  exit 1
  tput cnorm && exit 1

}

#ctl_c
trap ctl_c INT

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"


function helpPanel()
{
  echo -e "\n ${blueColour}[+] Uso : ${endColour}"
  echo -e "\t ${purpleColour}m)${endColour} Buscar por un nombre de maquina" 
  echo -e "\t ${purpleColour}h)${endColour} Mostrar este panel de ayuda"
  echo -e "\t ${purpleColour}i)${endColour} Buscar por una direccion de IP"
  echo -e "\t ${purpleColour}d)${endColour} Buscar por la dificultad de la maquina"
  echo -e "\t ${purpleColour}o)${endColour} Buscar por sistema operativo"
  echo -e "\t ${purpleColour}d)${endColour} Buscar por la dificultad de la maquina"
  echo -e "\t ${purpleColour}u)${endColour} Descargar o actualizar archivos necesarios"
}

function updateFiles(){


    if [ ! -f bundle.js ];then
      tput civis
      echo -e "\n[+] Descargando archivos necesarios..."
      curl -s $main_url > bundle.js
      js-beautify bundle.js | sponge bundle.js 
      echo -e "\n[+]Todos los archivos han sido descargados"
      tput cnorm
    else
      tput civis

      curl -s $main_url > bundle_temp.js 
      js-beautify bundle_temp.js | sponge bundle_temp.js
      md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
      md5_original_value=$(md5sum bundle.js | awk '{print $1}')
      
      if [ "$md5_temp_value" == "$md5_original_value" ];then 
        echo -e "\n[+] No hay actualizaciones"
         rm bundle_temp.js
      else
        echo -e "\n[+] Hay actualizaciones"
        rm bundle.js && mv bundle_temp.js bundle.js
      fi

      tput cnorm
    fi  
}

function searchMachine(){
  machine="$1"
  echo -e "\n [+] Listando las propiedades de la maquina \n"
  resultado="$(cat bundle.js | awk "/name: \"$machine\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
  if [ "$resultado" ];then
    echo -e "\n $resultado\n"
  else
    echo -e "\n No se encontro una maquina con ese nombre"
  fi  
  

   
}
function searchIP(){
  ipAddress="$1"
  maquina="$(cat bundle.js | grep "ip: \"$ipAddress\""  -B 3 | grep "name" | tr -d '"' | tr -d ',' | awk 'NF {print $NF}')"
  echo -e "\n [+] Buscando maquina por la ip : $ipAddress\n"
  if [ "$maquina" ];then
    echo -e "\n[+] El nombre de la maquina es : $maquina"
  else
    echo -e "\n[!] La direccion IP brindada no corresponde a ninguna maquina"
  fi
}
function searchDifficulty(){
  difficulty="$1"
  maquinas="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF {print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$maquinas" ];then
    echo -e "\n[+] Las Maquinas con dificultad $difficulty son : \n"
    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF {print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n[!] La dificultad brindada no existe"
  fi 
}
function searchOS(){
  os="$1"
  echo -e "\nBuscando maquinas con el sistema operativo : $os\n"
  osSearch="$(cat bundle.js | grep "so: \"$os\"" -B 4 | grep "name:" | tr -d '"' | tr -d ',' | awk 'NF {print $NF}')"
  if [ "$osSearch" ];then
      cat bundle.js | grep "so: \"$os\"" -B 4 | grep "name:" | tr -d '"' | tr -d ',' | awk 'NF {print $NF}' | column
  else 
      echo -e "\n[+] No se ha encontrado ninguna maquina con ese sistema operativo"
  fi 
}
function searchOsDifficultyMachine(){
      difficulty="$1"
      os="$2"
      echo -e "\n[+] Buscando una maquina con dificultad $difficulty y con el sistema operativo $os\n"
      resultado="$(cat bundle.js | grep "so: \"$os\"" -A 1 -B 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | tr -d '"' | tr -d ',' | awk 'NF {print $NF}' | column)"
      if [ "$resultado" ]; then
          cat bundle.js | grep "so: \"$os\"" -A 1 -B 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | tr -d '"' | tr -d ',' | awk 'NF {print $NF}' | column
      else
          echo -e "\n No se encontro ninguna maquina con esas caracteristicas"
      fi
}

#Ayudines
declare -i ayudin_os=0
declare -i ayudin_difficulty=0

#Indicadores
declare -i parameter_counter=0

while getopts "m:ui:hd:o:" arg; do 

  case $arg in
    m)machineName=$OPTARG; let parameter_counter+=1;;
    u)let parameter_counter+=2;;
    i)ipAddress=$OPTARG; let parameter_counter+=3;;
    h);;
    d)difficulty=$OPTARG; ayudin_difficulty+=1; let parameter_counter+=4;;
    o)os=$OPTARG; ayudin_os+=1; let parameter_counter+=5;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
      searchMachine $machineName
elif [ $parameter_counter -eq 2 ];then
      updateFiles
elif [ $parameter_counter -eq 3 ];then
      searchIP $ipAddress
elif [ $parameter_counter -eq 4 ];then
      searchDifficulty $difficulty
elif [ $parameter_counter -eq 5 ]; then
      searchOS $os
elif [ $ayudin_os -eq 1 ] && [ $ayudin_difficulty -eq 1 ]; then
      searchOsDifficultyMachine $difficulty $os
else
      helpPanel
fi
