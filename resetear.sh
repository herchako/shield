#!/bin/bash
if [ $USER == "root" ]
then

	updatedb
	INSTALADO=$( locate /nucleo/shield.sh | head -1 | wc -l) #determina si esta instalado o no
	if [ $INSTALADO -eq 1 ]
	then
	
		echo "Escriba el usuario a desconfigurar:"
		read USUARIO_A_CONFIGURAR
		EXISTE_USUARIO=$(locate /home/"$USUARIO_A_CONFIGURAR"/ | head -1 | wc -l )
		CONFIGURADO=$( locate  /home/"$USUARIO_A_CONFIGURAR"/.shield | head -1 | wc -l )
		SHELLS_PREVIO=$( cat /home/"$USUARIO_A_CONFIGURAR"/.shield/config/shells_previos | grep '/')	
		if [ $EXISTE_USUARIO -eq 1 ] && [ $CONFIGURADO -eq 1 ]
		then
			rm -fr /home/$USUARIO_A_CONFIGURAR/.shield
			rm -fr /home/$USUARIO_A_CONFIGURAR/.ssh
			chsh -s "$SHELLS_PREVIO" $USUARIO_A_CONFIGURAR
			sed -i "/$USUARIO_A_CONFIGURAR/d" /etc/sudoers
			echo "$USUARIO_A_CONFIGURAR desconfigurado correctamente"
		else
			if [ $CONFIGURADO -eq 0  ]
			then	
			echo "-Shield no encuentra configurado para $USUARIO_A_CONFIGURAR. Ejecute make configurar."
			fi

			if [ $EXISTE_USUARIO -eq 0  ]
			then	
			echo "-El usuario $USUARIO_A_CONFIGURAR no existe, creelo-"
			fi
			echo "Abortando operacion"
			sleep 3

		fi	




	else
	echo "-Shield no se encuentra instalado- Ejecute \"make instalar\" para instalarlo"
	fi
else
	echo "No posee los suficientes para ejecutar la instalacion, loguese como root"
fi
