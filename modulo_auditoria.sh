#!/bin/bash


COMANDOS_AUDITADOS=~/.shield/comandos.log
FILE_SIZE_CA=$(stat -c %s "$COMANDOS_AUDITADOS")
codOp=$1
comando=
CONFIG="/$HOME/.shield/config/auditoria.cfg"

shift #el primero no me sirve, empiezo a leer los parametros que son comandos 
until [ -z "$1" ]  
do
  comando="$comando$1 "
  shift
done

if [ -n "$codOp" ]
then

	case $codOp in

	informacion )
		echo -Modulo Auditoria-		
		echo Tamaño maximo permitodo del achivo de log $TAM_MAX_LOG_FILE
		echo Tamaño actual del archivo de log $FILE_SIZE_CA		
		echo Direccion ip para loggear remotamente $IP_TO_LOG
		;;
		
	procesar )
	
		if [ $[$FILE_SIZE_CA + ${#comando}] -le $TAM_MAX_LOG_FILE ]
 		then
						
			echo "$comando" >> $COMANDOS_AUDITADOS
						
		else
			#echo "El archivo de auditoria supero su maximo> se enviara a servidor"
			
			(echo "$comando" | ssh $USER@$IP_TO_LOG "cat >> /home/$USER/log.txt")&
			#ssh test@$192.168.1.35 "echo $comando >> /home/test/log.txt"
		fi
		;;
	
	iniciar )
		TAM_MAX_LOG_FILE=$(awk 'NR==2{print $0}' $CONFIG) 	 	
		if [ "$?" -ne 0 ] #Si no encontró el config"
		then
			sh_log -M "Auditoria" -a "Error al cargar del archivo de configuracion"
			return 1
		fi 
		IP_TO_LOG=$(awk 'NR==4{print $0}' $CONFIG)
		if [ "$?" -ne 0 ] #Si no encontró el config"
		then
			sh_log -M "Auditoria" -a "Error al cargar del archivo de configuracion"
			return 1
		fi 
		
	#	eval $(ssh-agent) 
		
	#	ssh-add 
		
		
		;;
	
	detener)
		unset TAM_MAX_LOG_FILE
		unset IP_TO_LOG
		unset FILE_SIZE_CA
		unset codOp
		unset COMANDOS_AUDITADOS
		unset CONFIG
		;;	
	*)
		echo "ERROR OPERACION MODULO"
		;;
	esac
else
	echo "no se paso ningun comando"
fi


return 0 

