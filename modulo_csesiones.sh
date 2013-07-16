#!/bin/bash

config="$HOME/.shield/config/sesiones.cfg"
source "/usr/bin/root_shield/nucleo/funciones_shield.cfg"

case $1 in
informacion)
	echo "-Modulo Control de Sesiones-"
	echo "Cantidad máxima de sesiones permitida: $maximo_sesiones"
	echo "Cantidad actual de sesiones iniciadas por $USER: $sesiones_actuales"
;;
iniciar)
	maximo_sesiones=( $( /bin/cat $config ) ) # lee archivo de configuración
	sesiones_actuales=$(who | awk -v val=$USER '$1 == val {print $0}' | wc -l)
	
	if [ "$?" -ne 0 ] #Si no se encontro el config
	then
		sh_log -M "Control de sesiones" -e "No se encontró el archivo de configuración"
		exit 1
	fi
	
	if [ "$sesiones_actuales" -gt "$maximo_sesiones" ]
	then
		echo -e "CONTROL DE SESIONES. Más sesiones que las permitidas"
		sh_log -M "Control de sesiones" -w "Se cerrará la sesión por exceder el máximo de sesiones permitido."
		return 1
	fi
;;
detener)
	unset config
	unset maximo_sesiones
	unset sesiones_actuales
;;
procesar)
	# no hacer nada
;;
esac

return 0
