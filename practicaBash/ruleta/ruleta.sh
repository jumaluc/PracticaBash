#!/bin/bash

#Ctl_c
function ctl_c(){ 
  echo -e "\n [+ Saliendo...]\n"
  exit 1
}
trap ctl_c INT
#Colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function helpPanel(){
  
  echo -e "\n${greenColour} [+]${endColour} Uso ${blueColour}$0${endColour}:\n"
  echo -e "\t${purpleColour}m)${endColour} Para ingresar el dinero a apostar"      
  echo -e "\t${purpleColour}t)${endColour} Para ingresar la tecnica (martingara/inversa)"      
}

function martingaraFunction(){
  money="$1"
  echo -ne "\n${yellowColour}[+]${endColour} Ingrese con cuanto dinero vas a apostar : " && read apuesta_inicial
  echo -ne "${yellowColour}[+]${endColour} Ingrese a que le vas a apostar (even/odd) : " && read even_odd
  echo -e "\n${yellowColour}[+]${endColour} Tienes ${yellowColour}$money$ ${endColour} y estas ingresando con ${yellowColour}$apuesta_inicial$ ${endColour}"
 
  #VARIABLES 
  declare -i contador_tiradas=0
  apuesta_actual=$apuesta_inicial
  racha_derrotas=""
  mayor_ganancia=$money

  #INICIO TIRADAS
  while true; do 
    money=$(($money-$apuesta_actual))
    contador_tiradas+=1
    tirada="$(($RANDOM % 37))"
    
    #MAYOR DINERO CONSEGUIDO
    if [ "$money" -gt "$mayor_ganancia" ];then
      mayor_ganancia=$money
    fi

#    echo -e "\n${purpleColour} La tirada es de : $tirada y tenes $money$ ${endColour} y la apuesta actual es de : ${apuesta_actual}"

    #CUANDO SE TE TERMINA LA PLATA
    if [ $money -lt $apuesta_actual ];then
      echo -e "\n${redColour}[!] TE QUEDASTE SIN PLATA PA TOMATELA! (Te quedan $money$) ${endColour}"
      echo -e "\n[+] La cantidad de tiradas fue de --> ${turquoiseColour} $contador_tiradas ${endColour}"
      echo -e "\n[ $racha_derrotas]"
      echo -e "\nLa mejor ganancia fue de : ${turquoiseColour}$mayor_ganancia${endColour}"
      break
    fi
    
    #CUANDO SALE EL 0
    if [ "$tirada" -eq 0 ];then
   #     echo -e "${redColour}[+] !Perdiste! ${endColour} Apostaste con ${yellowColour} $apuesta_actual$ ${endColour} tenes : ${yellowColour} $money$ ${endColour}"
        apuesta_actual=$(($apuesta_actual * 2))
        racha_derrotas+="$tirada "
        continue
    fi

    #EVEN
    if [ "$even_odd" == "even" ];then 
      if [ $(($tirada % 2)) -eq 0 ];then
          #GANA
          ingreso=$(($apuesta_actual * 2))
          money=$(($money+$ingreso))    
#          echo -e "${greenColour}[+] !Ganaste!${endColour} Apostaste con ${yellowColour} $apuesta_actual$ y ${endColour}tenes : ${yellowColour} $money$ ${endColour}"
          apuesta_actual=$apuesta_inicial
          racha_derrotas=""
      else  
          #PIERDE
#          echo -e "${redColour}[+] !Perdiste!${endColour} Apostaste con ${yellowColour} $apuesta_actual$ ${endColour} tenes : ${yellowColour} $money$ ${endColour}"
          apuesta_actual=$(($apuesta_actual * 2))
          racha_derrotas+="$tirada "
      fi 
    #ODD
    elif [ "$even_odd" == "odd" ];then
      if [ $(($tirada % 2 )) -eq 1 ];then
         #GANA
          ingreso=$(($apuesta_actual * 2))
          money=$(($money+$ingreso))    
 #         echo -e "${greenColour}[+] !Ganaste!${endColour} Apostaste con ${yellowColour} $apuesta_actual$ y ${endColour}tenes : ${yellowColour} $money$ ${endColour}"
          apuesta_actual=$apuesta_inicial
          racha_derrotas=""
      else 
          #PIERDE
  #        echo -e "${redColour}[+] !Perdiste!${endColour} Apostaste con ${yellowColour} $apuesta_actual$ ${endColour} tenes : ${yellowColour} $money$ ${endColour}"
          apuesta_actual=$(($apuesta_actual * 2))
          racha_derrotas+="$tirada "
      fi    
    fi 
  done
}

while getopts "m:t:h" arg; do
  case $arg in 
    m)money=$OPTARG;;
    t)tecnique=$OPTARG;;
    h)helpPanel;;
  esac
done  

if [ $money ] && [ $tecnique ]; then 
    if [ $tecnique == "martingara" ];then
        martingaraFunction $money 
    else 
      echo -e "\n${redColour}[!] Tecnica ingresada no existente${endColour}"
      helpPanel
    fi 
else
    echo -e "\n${redColour}[!] Ingreso no valido de parametros${endColour}"
    helpPanel
fi 


