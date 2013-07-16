#!/bin/bash

source "/usr/bin/root_shield/nucleo/funciones_shield.cfg"

case $1 in
iniciar) #iniciar agarra las variables de ~/.shield/config/limitaciones.cfg
	while IFS== read parametro valor    # Separo la línea por el carácter "=", de acuerdo al formato del config.
        do
		if [ $parametro = "CPU" ]   
           	then
			MAX_CPU=$valor
		fi
	
		if [ $parametro = "MEMORIA" ]
		then	
			MAX_MEM=$valor
		fi

		if [ $parametro = "PROCESOS" ]
                then
                        MAX_PROCESOS=$valor
                fi

		if [ $parametro = "SOCKETS" ]
                then
                        MAX_SOCKETS=$valor
                fi

		if [ $parametro = "ARCHIVOS" ]
                then
                        MAX_FILES=$valor
                fi

	done < ~/.shield/config/limitaciones.cfg  #Config
		
	if [ "$?" -ne 0 ] #Si no encontró el config"
	then
		sh_log -M "Limitaciones" -a "No se encontró el archivo de configuración"
                return 1
	fi

;;
detener)
        unset MAX_CPU
        unset MAX_MEM
        unset MAX_PROCESOS
        unset MAX_SOCKETS
        unset MAX_FILES
;;
informacion) 
	echo "-Modulo de Limitaciones-"
	if [ ${#MAX_MEM} != 0 ]  #MAX_MEM por preguntar por alguno. Puede ser cualquiera
        then

		TERMINAL=$(tty)   
		TERMINAL_ACTUAL=$(echo ${TERMINAL:5:10})  #obtengo tty de la sesión actual
        

		CPU_ACTUAL=$(ps -o pcpu,tt -u $USER | grep $TERMINAL_ACTUAL | awk '{total=total+$1}END{print total}') 
	
		MEM_ACTUAL=$(ps -o %mem,tt -u $USER | grep $TERMINAL_ACTUAL | awk '{total=total+$1}END{print total}')

		CANT_PROCESOS=$(ps -o tt -u $USER | grep -c $TERMINAL_ACTUAL )
   
		FILES_ACTUAL=0

        	while read pid
        	do

                	NEW_FILES=$(lsof -p $pid 2>/dev/null  | grep -c REG)
	                FILES_ACTUAL=$(( $NEW_FILES + FILES_ACTUAL ))

	        done < <(ps -o pid,tt -u $USER | grep $TERMINAL_ACTUAL | awk '{print $1}')

		SOCKETS_ACTUAL=0
	        while read pid
        	do
                        NEW_SOCKETS=$(ls -l /proc/$pid/fd 2>/dev/null | grep -c socket)
                        SOCKETS_ACTUAL=$(( $NEW_SOCKETS + SOCKETS_ACTUAL))

        	done < <(ps -o pid,tt -u $USER | grep $TERMINAL_ACTUAL | awk '{print $1}')

		echo "Máximo uso de CPU de sesión:$MAX_CPU" 
		echo -e "El uso de CPU de la sesión actual es de:$CPU_ACTUAL \n" 
	
		echo "Máximo uso de Memoria por sesión:$MAX_MEM" 
		echo -e "El uso de Memoria de la sesión actual es de:$MEM_ACTUAL \n" 

		echo "Máximo de procesos de sesión:$MAX_PROCESOS" 
		echo -e "Cantidad de procesos de la sesión actual:$CANT_PROCESOS \n" 

		echo "Máxima cantidad de archivos abiertos por proceso:" $MAX_FILES
		echo -e "Archivos abiertos por los procesos de la sesión actual:$FILES_ACTUAL \n"

                echo "Máxima cantidad de sockets abiertos por proceso:" $MAX_SOCKETS
                echo -e "Sockets abiertos por los procesos de la sesión actual:$SOCKETS_ACTUAL \n"

	else
                echo "No se inicializó el módulo"
		sh_log -M "Limitaciones" -a "Se preguntó por las limitaciones y el módulo no estaba inicializado"

        fi
;;
procesar)
	
	TERMINAL=$(tty)   
        TERMINAL_ACTUAL=$(echo ${TERMINAL:5:10})  #obtengo tty de la sesión actual

	if [ ${#MAX_MEM} != 0 ]  #MAX_MEM por preguntar por alguno. Puede ser cualquiera. Si no inicializo tira error al comparar
	then

		MEM_ACTUAL=$(ps -o %mem,tt -u $USER | grep $TERMINAL_ACTUAL | awk '{total=total+$1}END{print total}')
	
		if [ $(echo "$MEM_ACTUAL <= $MAX_MEM" | bc) = 0 ]
		then
        		echo "La memoria usada por los procesos de la sesión actual superó el máximo permitido"
			echo "Se cerrará la sesión."
			sh_log -M "Limitaciones" -e "Se superó el máximo pertimido de memoria por sesión"
			return 1
		fi
	
		CANT_PROCESOS=$(ps -o tt -u $USER | grep -c $TERMINAL_ACTUAL)

       		 if [ $(echo "$CANT_PROCESOS <= $MAX_PROCESOS" | bc) = 0 ]
        	then
                	echo "Se superó la máxima cantidad de procesos abiertos permitidos"
        		echo "Se cerrará la sesión."
			sh_log -M "Limitaciones" -e "Se superó la máxima cantidad de procesos abiertos permitidos por sesión"
			return 1
		fi

        	CPU_ACTUAL=$(ps -o pcpu,tt -u $USER | grep $TERMINAL_ACTUAL | awk '{total=total+$1}END{print total}')

        	if [ $(echo "$CPU_ACTUAL <= $MAX_CPU" | bc) = 0 ]
        	then
                	echo "Los procesos de la sesión actual superaron el uso de CPU permitido"
			echo "Se cerrará la sesión."
			sh_log -M "Limitaciones" -e "Se superó el máximo de CPU permitido por sesión"
			return 1
		fi

        	FILES_ACTUAL=0

	        while read pid
        	do

                	NEW_FILES=$(lsof -p $pid 2>/dev/null | grep -c REG )
                	FILES_ACTUAL=$(( $NEW_FILES + FILES_ACTUAL ))

        	done < <(ps -o pid,tt -u $USER | grep $TERMINAL_ACTUAL | awk '{print $1}')


        	if [ $(echo "$FILES_ACTUAL <= $MAX_FILES" | bc) = 0 ]
        	then
                	echo "Se superó la máxima cantidad de archivo abiertos permitidos"
			echo "Se cerrará la sesión."
			sh_log -M "Limitaciones" -e "Se superó la máxima cantidad de archivos abiertos permitidos por sesión"
			return 1	
		fi
		
		SOCKETS_ACTUAL=0
                while read pid
                do
                        NEW_SOCKETS=$(ls -l /proc/$pid/fd 2>/dev/null | grep -c socket)
                        SOCKETS_ACTUAL=$(( $NEW_SOCKETS + SOCKETS_ACTUAL))

                done < <(ps -o pid,tt -u $USER | grep $TERMINAL_ACTUAL | awk '{print $1}')

		if [ $(echo "$SOCKETS_ACTUAL <= $MAX_SOCKETS" | bc) = 0 ]
                then
                        echo "Se superó la máxima cantidad de sockets  abiertos permitidos"
			echo "Se cerrará la sesión."
                        sh_log -M "Limitaciones" -e "Se superó la máxima cantidad de sockets abiertos permitidos por sesión"
                        return 1
                fi 

	else
		echo "No se inicializó el módulo"
	fi
;;
esac
