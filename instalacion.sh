#!/bin/bash
if [ $USER == "root" ]
then
	echo Instalando...
	echo Determinando si ya se encuentra instalado...	
	updatedb
	INSTALADO=$(locate /nucleo/shield.sh | head -1 | wc -l) #determina si esta instalado o no

	export PATH_INSTALACION_SHIELD=/etc/shilda/

	if [ $INSTALADO -eq 0 ]
	then
		mkdir -p "$PATH_INSTALACION_SHIELD"modulos/comando/seguridad
		mkdir -p "$PATH_INSTALACION_SHIELD"modulos/comando/auditoria
		mkdir -p "$PATH_INSTALACION_SHIELD"modulos/comando/sesiones
		mkdir -p "$PATH_INSTALACION_SHIELD"modulos/periodicos/limitaciones
		mkdir -p "$PATH_INSTALACION_SHIELD"modulos/periodicos/carga
		mkdir -p "$PATH_INSTALACION_SHIELD"modulos/periodicos/trafico
		mkdir -p "$PATH_INSTALACION_SHIELD"nucleo/
		mkdir -p "$PATH_INSTALACION_SHIELD"utilitarios/
	
	
		ln -s "$PATH_INSTALACION_SHIELD"nucleo/shield.sh /usr/bin/
		ln -s 	"$PATH_INSTALACION_SHIELD" /usr/bin/root_shield
	

		cp shield.sh "$PATH_INSTALACION_SHIELD"nucleo/shield.sh
		cp shield.cfg "$PATH_INSTALACION_SHIELD"nucleo/shield.cfg
		chmod +x "$PATH_INSTALACION_SHIELD"nucleo/shield.sh	
	
		cp funciones_shield.cfg "$PATH_INSTALACION_SHIELD"nucleo/funciones_shield.cfg
		chmod +x "$PATH_INSTALACION_SHIELD"nucleo/funciones_shield.cfg
		cp modulo_auditoria.sh "$PATH_INSTALACION_SHIELD"modulos/comando/auditoria
		chmod +x "$PATH_INSTALACION_SHIELD"modulos/comando/auditoria/modulo_auditoria.sh
		cp modulo_seguridad.sh "$PATH_INSTALACION_SHIELD"modulos/comando/seguridad
		chmod +x "$PATH_INSTALACION_SHIELD"modulos/comando/seguridad/modulo_seguridad.sh
		cp modulo_csesiones.sh  "$PATH_INSTALACION_SHIELD"modulos/comando/sesiones
		chmod +x "$PATH_INSTALACION_SHIELD"modulos/comando/sesiones/modulo_csesiones.sh
		cp modulo_limitaciones.sh  "$PATH_INSTALACION_SHIELD"modulos/periodicos/limitaciones
		chmod +x "$PATH_INSTALACION_SHIELD"modulos/periodicos/limitaciones/modulo_limitaciones.sh
		cp modulo_carga.sh "$PATH_INSTALACION_SHIELD"modulos/periodicos/carga
		chmod +x "$PATH_INSTALACION_SHIELD"modulos/periodicos/carga/modulo_carga.sh
		cp modulo_trafico.sh "$PATH_INSTALACION_SHIELD"modulos/periodicos/trafico
		chmod +x "$PATH_INSTALACION_SHIELD"modulos/periodicos/trafico/modulo_trafico.sh
		cp comandos_builtins.sh "$PATH_INSTALACION_SHIELD"utilitarios
		chmod +x "$PATH_INSTALACION_SHIELD"utilitarios/comandos_builtins.sh
		cp listado "$PATH_INSTALACION_SHIELD"utilitarios/listado
	
		echo ""$PATH_INSTALACION_SHIELD"nucleo/shield.sh" >> /etc/shells

	
		echo "Shield se instalo correctamente."	
	else
		echo "-Shield ya se encuentra instalado-"
	fi	
else
	echo "No posee los suficientes para ejecutar la instalacion, loguese como root"
fi
