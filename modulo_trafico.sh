#!/bin/bash

source "/usr/bin/root_shield/nucleo/funciones_shield.cfg"	#HARDCODEADO; modificar

codOp=$1  #Tipo de operación
config="$HOME/.shield/config/trafico.cfg"

if [ -n "$codOp" ]
then
	case $codOp in 
	iniciar)
		# Del archivo de configuración toma el máximo de paquetes y la 
		# interfaz a analizar
		while IFS== read parametro valor # Separo la línea por el carácter "=", de acuerdo al formato del config.
		do
		case $parametro in
		maximo_paquetes)
			maximo_paquetes=$valor
		;;
		interfaz)
			interfaz=$valor
		;;
		esac
		done < $config
		
		paquetes_inicial=$(cat /proc/net/dev | grep $interfaz | awk '{printf $11}')
		#echo "Módulo de red: paquetes_inicial: $paquetes_inicial"

		if [ "$?" -ne 0 ] #Si no se encontro el config
		then
			sh_log -M "Limitación de tráfico de red" -e "No se encontró el archivo de configuración"
			return 1
		fi
	;;
	informacion)
		echo "-Modulo de Trafico de Red-"		
		echo "Cantidad de paquetes IP máxima: $maximo_paquetes"
		paquetes_enviados=$(cat /proc/net/dev | grep $interfaz | awk '{print $11}')
		let paquetes_enviados=paquetes_enviados-paquetes_inicial #cantidad de paquetes
		echo "Cantidad de paquetes enviados: $paquetes_enviados"
		#echo "Cantidad de paquetes inicial: $paquetes_inicial"
	;;
	detener)
		unset maximo_paquetes
		unset paquetes_enviados
		unset cantSockets
		unset pid
	;;
	procesar)       #
		mostrar=1		# "parche" para que no muestre el prompt
		mato=1			# flag para indicar si mató o no procesos
		interfaz=$(ifconfig | awk 'NR == 1 {print $1}')		# primera interfaz activa
		paquetes_enviados=$(cat /proc/net/dev | grep $interfaz | awk '{print $11}')
		let paquetes_enviados=paquetes_enviados-paquetes_inicial  #cantidad de paquetes actual
		terminal=$(tty | cut -c 6-)
		# terminal=$(who am i | awk '{print $2}')
		if [ "$paquetes_enviados" -gt "$maximo_paquetes" ]
		then
			while read pid
			do 
				# cantidad de sockets abiertos por el proceso pid
				cantSockets=$(lsof -i | awk -v procID=$pid '$2 == procID {print $0}' | wc -l)
				if [ "$cantSockets" -gt 0 ]
				then
					echo "Proceso: $pid"
					echo -e "Sockets abiertos:"
					lsof -i | awk -v procID=$pid '$2 == procID {print $0}' # muestra los sockets
					kill $pid
					echo "El proceso $pid fue eliminado del sistema"
					sh_log -M "Limitación de tráfico de red" -a "El proceso $pid fue eliminado del sistema"
					mato=0
					mostrar=0		# tiene que mostrar el prompt
				fi
			done < <(ps -ef | awk -v usuario=$USER -v tty=$terminal '$1 == usuario && $6 == tty {print $2}')
			
			if [ "$mato" -eq 0 ]
			then
				paquetes_inicial=0
				paquetes_enviados=0
			fi

			if [ "$mostrar" -eq 0 ]
			then
				return 2		# avisa al núcleo que debe mostrar el prompt
			fi
		fi
	;;
	*)
		echo "No es una operacion valida"  #No es necesario. 
	;;
	esac
else
	echo "Debe ingresar un código de operación"  #No es necesario.
fi
return 0
