#!/bin/bash
#configuracion shield
echo "Ingrese nombre de usuario en el servidor"
read USUARIO_A_CONFIGURAR
echo "Ingrese IP del servidor"
read dirip
	
		#CREACION DE KEYS
			
		echo "el usuario es $USUARIO_A_CONFIGURAR"
		ssh-keygen  -t dsa #-f /home/$USUARIO_A_CONFIGURAR/.ssh/id_dsa -p 
		echo "el usuario es $USUARIO_A_CONFIGURAR"		
		ssh $USUARIO_A_CONFIGURAR@$dirip "mkdir .ssh; "
		scp /home/$USUARIO_A_CONFIGURAR/.ssh/id_dsa.pub $USUARIO_A_CONFIGURAR@$dirip:.ssh/authorized_keys


