#!/bin/bash
CODOP=$1
CONFIG="$HOME/.shield/config/carga.cfg"
if [ -n "$CODOP" ]
then
	case $CODOP in 
	iniciar)
		CPU_MAX=( $( /bin/cat $CONFIG ) ) #Toma el valor de cpu maximo del archivo de configuracion
		if [ "$?" -ne 0 ] #Si no se encontro el config
		then
			sh_log -M "Control de carga" -a "No se encontró el archivo de configuración"
			return 1
		fi
		PID_ANTERIOR=-1 #Es el pid del proceso que se está incrementando en el momento.
		INCREMENTOS=0	
		PID_SHIELD=$$
	;;
	informacion)
		echo "-Modulo de Control de Carga-"		
		echo "Máximo consumo de CPU por proceso: $CPU_MAX"
		if [ "$PID_ANTERIOR" -eq -1 ]
		then
			echo "Aún no se ha procesado el máximo consumo de CPU de los procesos"
		else
			echo "Proceso: $PID_ANTERIOR"
			NI=`ps -o ni,pid | grep $PID_ANTERIOR | awk '{print $1}'`
			if [ -z "$NI" ]
			then
				echo "El proceso ya ha sido eliminado."
			else
				echo "Cantidad de incrementos de nice: $INCREMENTOS"
				echo "Valor actual de nice: $NI"
				
			fi
			unset NI #Imprime el valor de CPU_MAX, el proceso con mayor consumo de cpu, su valor de nice y la cantidad de incrementos que se le hicieron
		fi
	;;
	detener)
		unset CPU_MAX 
		unset PID_ANTERIOR
		unset INCREMENTOS
		unset PID_SHIELD
	;;
	procesar)
		mostrar=1
		PID=`ps -o pid,pcpu,ni,comm --sort pcpu|grep -v -w $PID_SHIELD|tail -n 1|awk -v awkmax="$CPU_MAX" '{ if( $2 > awkmax) {print $1}}'` #Guardo el PID del proceso con mayor porcentaje de CPU que supere al CPU_MAX y no sea shield.sh
		if [ -z $PID ] #Si ningun proceso supera el CPU_MAX retorna 0
		then
			unset PID
			return 0
		fi
		NI=`ps -o ni,pid | grep $PID | awk '{print $1}'` #Obtengo valor de nice actual
		renice `expr $NI + 5` -p $PID 2>/dev/null
		if [ "$?" -ne 0 ] #Si fallo la ejecución del renice
		then
			unset PID
			unset NI
			return 0
		fi
		mostrar=0
		sh_log -M "Control de carga" -a "Se bajó la prioridad del proceso $PID."
		if [ "$PID_ANTERIOR" -eq "$PID" ]
		then
			INCREMENTOS=`expr $INCREMENTOS + 1`
		else
			INCREMENTOS=1
			PID_ANTERIOR=$PID	
		fi
		if [ "$INCREMENTOS" -eq 4 ]
		then
			disown $PID
			kill -9 $PID
			INCREMENTOS=0
			echo "El proceso $PID ha sido eliminado por su consumo de CPU."
			echo
			sh_log -M "Control de carga" -a "El proceso $PID ha sido eliminado por su consumo de CPU."
			unset PID
			unset NI
		fi
		unset NI
		unset PI
		if [ "$mostrar" -eq 0 ]
		then
			return 2		# avisa al núcleo que debe mostrar el prompt
		fi
	;;

esac

fi

return 0



