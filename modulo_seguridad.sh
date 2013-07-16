#!/bin/bash

CODOP=$1  #Tipo de operación
typeset -a vectorProhibidos #declaro un vector para mostrar todos los comandos prohibidos ingresados
source "/usr/bin/root_shield/nucleo/funciones_shield.cfg"



shift 
until [ -z "$1" ]
do
	COMANDO="$COMANDO$1 "
	shift
done    #COMANDO tiene todo lo tipeado


if [ -n "$CODOP" ]
then
	case $CODOP in 
	iniciar) #Carga el Config en un vector. Asumo que hay un comando por linea
		while read COMANDOSCONFIG
  		do 
			vectorConfig+=("$COMANDOSCONFIG")
		done < ~/.shield/config/seguridad.cfg

		if [ "$?" -ne 0 ] #Si no encontró el config"
		then
			sh_log -M "Seguridad" -a "No se encontró el archivo de configuración"
			return 1
		fi 
	;;
	informacion) #Muestra por pantalla los comandos prohibidos
		echo "-Modulo de Seguridad-"		
		if [ ${#vectorConfig[@]} != 0 ]
		then
			echo "Usted no puede ejecutar los siguientes comandos:"
			for t in "${vectorConfig[@]}"       # Imprime el array
        		do
                		echo $t
			done
		else
			echo "No se ha inicializado el módulo"
			sh_log -M "Seguridad" -a "Se preguntó por los comandos prohibidos y el módulo no estaba inicializado"
		fi
	;;
	detener) 
		unset COMANDOSCONFIG
		unset vectorConfig 	#Borra el array.
	;;
	procesar)       #
		for i in "${vectorConfig[@]}"
		do	
			CANT_COMANDO_PROHIBIDO=0    #Inicializo como flag
			if [ ! -z "$i" ]
			then
				CANT_COMANDO_PROHIBIDO=$(echo $COMANDO | grep -wc $i) #Cuantas veces aparece cada uno de los comanodos prohibidos
											#en lo tipeado por el usuario
			fi
			if [ $CANT_COMANDO_PROHIBIDO != 0 ]   
			then
				vectorProhibidos+=("$i")
				unset CANT_COMANDO_PROHIBIDO
			fi
		done
			
		if [ ${#vectorProhibidos[@]} != 0 ] #Si quiso ejecutar un comando prohibido
		then
			for j in "${vectorProhibidos[@]}"  #listo todos los comandos prohibidos que quiso ejecutar
			do
				echo "No puede ejectuar: $j"
				sh_log -M "Seguridad" -e "Quiso ejecutar el siguiente comando prohibido: $j"
			done
			unset COMANDO
			unset vectorProhibidos
			return 1
		fi
		unset COMANDO
	;;
	*)
		echo "No es una operacion valida"  #No es necesario. 
		
	;;
	esac	
	return 0	
else
	echo "No se paso niguna operacion"  #No es necesario.
fi

