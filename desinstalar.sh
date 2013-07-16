#!/bin/bash

export PATH_INSTALACION_SHIELD=/etc/shilda/
if [ $USER == "root" ]
then
	echo Determinando si esta instalado...
	updatedb
	INSTALADO=$( locate /nucleo/shield.sh | head -1 | wc -l ) #determina si esta instalado o no

	USUARIO_CONFIGURADO=0
	if [ $INSTALADO -eq 1 ]
	then
		 while  read usuario
			do
				CONFIGURADO=$( locate  /home/$usuario/.shield | head -1 | wc -l )

				if [ $CONFIGURADO -eq 1 ]
				then
					echo "Aviso: $usuario tiene Shield configurado"
					let USUARIO_CONFIGURADO++
		        	fi

		        	unset CONFIGURADO	
			done < <(ls /home/)
		if [ $USUARIO_CONFIGURADO -eq 1 ]
		then
			echo "Hay $USUARIO_CONFIGURADO usuario/s con Shield configurado"m
			echo "No se puede desinstalar Shield"
		else
			rm /usr/bin/root_shield
			rm /usr/bin/shield.sh
			sed -i '/shield/d' /etc/shells
			rm -fr $PATH_INSTALACION_SHIELD
			echo "Shield se desinstalo correctamente"
		fi
	

	else
	echo "-Shield no se encuentra instalado- Ejecute \"make instalar\" para instalarlo"
	fi
else
	echo "No posee los suficientes para ejecutar la instalacion, loguese como root"
fi
