#!/bin/bash
#configuracion shield
if [ $USER == "root" ]
then
	echo "Configurando..."
	echo "Determinando si shield se encuentra instalado"	
	updatedb
	INSTALADO=$( locate nucleo/shield.sh | head -1 | wc -l) #determina si esta instalado o no
	if [ $INSTALADO -eq 1 ]
	then
		echo "Escriba el usuario a configurar:"
		read USUARIO_A_CONFIGURAR
	
		EXISTE_USUARIO=$(locate /home/"$USUARIO_A_CONFIGURAR"/ | head -1 | wc -l )
		CONFIGURADO=$( locate  /home/$USUARIO_A_CONFIGURAR/.shield/ | head -1| wc -l )
	
		if [ $EXISTE_USUARIO -eq 1 ] && [ $CONFIGURADO -eq 0 ]
		then
			
			#CREACION DE ARCHIVOS Y DIRECTORIOS
			mkdir -p /home/$USUARIO_A_CONFIGURAR/.shield
			mkdir -p /home/$USUARIO_A_CONFIGURAR/.shield/config
			touch /home/$USUARIO_A_CONFIGURAR/.shield/comandos.log		# comandos registrados por Auditoría
			touch /home/$USUARIO_A_CONFIGURAR/.shield/shell.log		# errores
	
			#COPIANDO ARCHIVOS DE SHIELD
			cp modulos_comando /home/$USUARIO_A_CONFIGURAR/.shield/modulos_comando		# lista de paths de módulos para el usuario
			cp modulos_periodicos /home/$USUARIO_A_CONFIGURAR/.shield/modulos_periodicos  # lista de paths de módulos para el usuario
		 	cp auditoria.cfg /home/$USUARIO_A_CONFIGURAR/.shield/config/auditoria.cfg
			cp seguridad.cfg /home/$USUARIO_A_CONFIGURAR/.shield/config/seguridad.cfg
			cp sesiones.cfg /home/$USUARIO_A_CONFIGURAR/.shield/config/sesiones.cfg	
			cp limitaciones.cfg /home/$USUARIO_A_CONFIGURAR/.shield/config/limitaciones.cfg
			cp carga.cfg /home/$USUARIO_A_CONFIGURAR/.shield/config/carga.cfg
			cp trafico.cfg /home/$USUARIO_A_CONFIGURAR/.shield/config/trafico.cfg
			cp shells_previos /home/$USUARIO_A_CONFIGURAR/.shield/config/shells_previos
		
			#cp trafico.cfg /home/$USUARIO_A_CONFIGURAR/.shield/config/trafico.cfg
	
			#PERMISOS DE ARCHIVOS Y CARPETAS
			chmod 755 /home/$USUARIO_A_CONFIGURAR/.shield
			chmod 666 /home/$USUARIO_A_CONFIGURAR/.shield/shell.log
			chmod 666 /home/$USUARIO_A_CONFIGURAR/.shield/comandos.log
			chmod 644 /home/$USUARIO_A_CONFIGURAR/.shield/modulos_comando
			chmod 644 /home/$USUARIO_A_CONFIGURAR/.shield/modulos_periodicos
			#chsh -s /etc/shield/nucleo/shield.sh $USUARIO_A_CONFIGURAR
	
			#CREACION DE KEYS
			#eval $(ssh-agent)	
			#echo "el usuario es $USUARIO_A_CONFIGURAR"
			#su $USUARIO_A_CONFIGURAR -c 'ssh-keygen  -t dsa -f /home/'$USUARIO_A_CONFIGURAR'/.ssh/id_dsa -p' 
			#echo "el usuario es $USUARIO_A_CONFIGURAR"		
			#scp /home/$USUARIO_A_CONFIGURAR/.ssh/id_dsa.pub $USUARIO_A_CONFIGURAR@$dirip:.ssh/authorized_keys
		
			#eval $(ssh-agent)
			#echo TERCERO $?

			#ssh-add
			#echo TERCERO $?	
			#EDITO SUDOERS
			sudo echo "$USUARIO_A_CONFIGURAR ALL = NOPASSWD: /sbin/shutdown" >> /etc/sudoers;
			#GUARDO SHELL ACTUAL
			echo $SHELL >> /home/$USUARIO_A_CONFIGURAR/.shield/config/shells_previos
		
			#CAMBIO DE SHELL 
			elShield=$(less /etc/shells | grep 'shield.sh')
			chsh -s $elShield $USUARIO_A_CONFIGURAR
			echo "Configuracion para $USUARIO_A_CONFIGURAR finalizada correctamente"
	
		else
			if [ $CONFIGURADO -eq 1  ]
			then	
			echo "-Shield ya se encuentra configurado para $USUARIO_A_CONFIGURAR. Inicie sesion con el comando login-"
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
