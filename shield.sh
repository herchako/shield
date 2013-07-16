#!/bin/bash

config="/usr/bin/root_shield/nucleo/shield.cfg"
source "/usr/bin/root_shield/nucleo/funciones_shield.cfg" 
source "/usr/bin/root_shield/utilitarios/comandos_builtins.sh"	
sh_log -N -a "Inicialización de SHIELD."

typeset -a vectorComando		# declara el array
typeset -a vectorPeriodicos		# declara el array
typeset -a vectorBuiltins		# comandos builtin
typeset -a vectorConfig

while IFS== read parametro valor # Separo la línea por el carácter "=", de acuerdo al formato del config.
do
	case $parametro in
	tiempoVerificacion)
		tiempoVerificacion=$valor
	;;
	tiempoPeriodicos)
		tiempoPeriodicos=$valor
	;;
	esac
done < $config

input=$1

mostrarPrompt=0	# evita que se repita el prompt (con línea vacía)
				# si la salida fue por timeout y los scripts
				# periódicos no imprimieron nada

clear		# borra la pantalla

RegistrarBuiltins	# registra en un vector los comandos builtin

echo -e "---- Bienvenido a SHIELD, $USER. ----\n"
echo -e "Registrando módulos...\n"

RegistrarModulos comando

RegistrarModulos periodicos

listar_modulos

echo -e "\nInicializando módulos..."

InicializarModulos comando

if [ $? != 0 ]
then
	sh_log -N -e "Falló la inicialización de módulos de comando."
	exit 1
fi

InicializarModulos periodicos

if [ $? != 0 ]
then
	sh_log -N -e "Falló la inicialización de módulos periódicos."
	exit 1
fi

ultima_verificacion=$(date +%s)
ultima_ejecucion_periodicos=$(date +%s)

if [ $tiempoVerificacion -gt $tiempoPeriodicos ]
then
	tiempo=$tiempoPeriodicos
else
	tiempo=$tiempoVerificacion
fi


while true		# La única forma de salir es con el comando salir o
				# ingresando Ctrl+C
do	
	trap finalizar SIGINT
	if [ "$mostrarPrompt" == 0 ]		
	then
		mostrarPrompt=1
		read -p "[$USER@SHIELD]:~$PWD\$ " -t $tiempo input;		# muestra el prompt
	else
		read -t $tiempo input;		# no muestra el prompt
	fi
	
	if [ $? = 0 ]
	then
		if [ "${#vectorComando[@]}" -gt 0 ]
		then
			for j in "${vectorComando[@]}":
			do
				ultimoCaracter=${j#${j%?}}
			
				if [ $ultimoCaracter = ":" ]
				then
					path=${j%?}	# le quita el delimitador : del final
				else
					path=$j
				fi
				
				source $path procesar $input	# ejecuta el módulo
			
				if [ $? != 0 ]
				then
					echo "$path: ejecución con problemas."
					mostrarPrompt=0
					continue 2
				fi
			done
		fi
		mostrarPrompt=0
	fi

	if [ $? = 0 ]
	then
		for b in "${vectorBuiltins[@]}":
		do	
			if [[ "$input" == *"$b"* ]]; then	# si lo ingresado es un comando builtin...
				$input
				continue 2
			fi
		done
		eval "$input"	#le pide a Bash que ejecute el comando
	fi

  	tActual=$(date +%s)
        if [ $(( $tActual - $ultima_verificacion )) -ge $tiempoVerificacion ]
        then
                VerificarCambioArchivos
                if [ $? != 0 ] #Si hubo cambios en los config se inicializa todo otra vez
                then
			sh_log -N -a "Hubo una modificacion en el archivo de configuracion. Se reiniciará Shield."
                        actualizar_modulos              #comando builtin
                        mostrarPrompt=0
                fi
	let "ultima_verificacion = $tActual"
        fi

	let "tiempoDesdeUltimaEjecucion = $(( $tActual - $ultima_ejecucion_periodicos ))"
	if (( $tiempoDesdeUltimaEjecucion >= $tiempoPeriodicos ))
	then
		let "ultima_ejecucion_periodicos = $tActual"
		if [ "${#vectorPeriodicos[@]}" -gt 0 ]
		then
			for k in "${vectorPeriodicos[@]}":
			do
				ultimoCaracter=${k#${k%?}}
			
				if [ $ultimoCaracter = ":" ]
				then
					path=${k%?}	# le quita el delimitador : del final
				else
					path=$k
				fi
				source $path procesar	# ejecuta el módulo
			
				case $? in
				1)
					mostrarPrompt=0
					ps -o pid|grep -v -w $$|awk '{ system("kill -9 " $1) }'
					clear
					echo "$path: ejecución con problemas. Se cerrará la sesión"
					salir
					;;
				2)		# Sólo para el módulo de tráfico de red
					mostrarPrompt=0
					continue 2
					;;
				esac
			done
		fi
		mostrarPrompt=1		# ningún periódico devolvió error: no mostraron nada en pantalla
	fi 						

	if [ $(( $tiempoPeriodicos - $(( $tActual - $ultima_ejecucion_periodicos )) )) -gt $(( $tiempoVerificacion - $(( $tActual - $ultima_verificacion )) )) ]
	then
		let "tiempo = $tiempoVerificacion - $(( $tActual - $ultima_verificacion ))"
	else
		let "tiempo = $tiempoPeriodicos - $(( $tActual - $ultima_ejecucion_periodicos ))"
	fi

done

clear					# borra la pantalla
