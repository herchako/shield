#!/bin/bash

source "/usr/bin/root_shield/nucleo/funciones_shield.cfg"

function ayuda() {
	
	if [ -z "$1" ]
	then
		echo Ayuda: presenta en pantalla una breve ayuda sobre el built in indicado. Si no recibe parámetro, presentará la ayuda de 			todos los builtins.
		echo Información de los Módulos: a cada módulo activo para el usuario le indica que imprima en pantalla información sobre sí 			mismo. Si al built-in se lo invoca de la forma info_modulos string, sólo imprimirá la información de los módulos cuyo nombre 			contengan al string indicado.
		echo Listar Módulos: presenta en pantalla los paths absolutos de los módulos que tiene activo el usuario.
		echo Actualizar Módulos: invoca a la función del núcleo Registrar e inicializar módulos.
		echo Mostrar variable: muestra el valor de la variable interna de shell de nombre Variable.
		echo Salir: termina la sesión actual del usuario.
		echo Apagar: apaga la PC.		
	       		
	else
		case "$1" in
			ayuda) 
				echo Ayuda: presenta en pantalla una breve ayuda sobre el built in indicado. Si no recibe parámetro, 					presentará la ayuda de todos los builtins.
			;;
			info_modulos)
				echo Información de los Módulos: a cada módulo activo para el usuario le indica que imprima en pantalla 				información sobre sí mismo. Si al built-in se lo invoca de la forma info_modulos string, sólo imprimirá la 					información de los módulos cuyo nombre contengan al string indicado.
			;;
			listar_modulos)
			        echo Listar Módulos: presenta en pantalla los paths absolutos de los módulos que tiene activo el usuario.
			;;
			actualizar_modulos)
			        echo Actualizar Módulos: invoca a la función del núcleo Registrar e inicializar módulos.
			;;
			mostrar)
			        echo Mostrar variable: muestra el valor de la variable interna de shell de nombre Variable.
			;;	
			salir)
			        echo Salir: termina la sesión actual del usuario.
			;;
			apagar)
			        echo Apagar: apaga la PC.
			;;
			*)
		       	 	echo No es un módulo válido
				sh_log -B "Información sobre los Módulos" -a "No existe el módulo solicitado"
			;;
			esac
		return 1
	
	fi
}

function info_modulos() {
	
if [ -z "$1" ]
then

	for t in "${vectorComando[@]}"                               
	do
		source $t informacion
	done

	for t in "${vectorPeriodicos[@]}"
	do
		source $t informacion
	done

else
	cantidad_periodicos=0
	for t in "${vectorPeriodicos[@]}"
	do
		nombre_modulo=$(echo $t | grep -o -E "modulo_\w*")
	  	cadena_a_buscar=$1
		coincidencia=$(echo $nombre_modulo | grep -c $cadena_a_buscar)				
		if [ $coincidencia != 0 ]
		then
			source $t informacion
			let cantidad_periodicos++
		fi 		
	done
	
	cantidad_comando=0	
	for t in "${vectorComando[@]}"                               
	do
		nombre_modulo=$(echo $t | grep -o -E "modulo_\w*")
		cadena_a_buscar=$1
		coincidencia=$(echo $nombre_modulo | grep -c $cadena_a_buscar)				
		if [ $coincidencia != 0 ]
		then
			source $t informacion
			let cantidad_comando++
		fi 		
	done
	
	if [ $cantidad_periodicos = 0 ] && [ $cantidad_comando = 0 ]
	then
		sh_log -B "Información de Módulos" -a "La palabra a buscar no coincide ni un módulo periódico ni un módulo de comando"
		echo "La palabra a buscar no coincide con un módulo períodico ni de comando existente o habilitado para el usuario"                
        	return 0
	else	
		if [ $cantidad_periodicos = 0 ]
		then
			sh_log -B "Información de Módulos" -a "La palabra a buscar no coincide con un módulo periódico o habilitado para el usuario"
			echo "La palabra a buscar no coincide con ningún módulo períodico existente o habilitado para el usuario"                
        		return 0
		fi

		if [ $cantidad_comando = 0 ]
		then
			sh_log -B "Información de Módulos" -a "La palabra a buscar no coincide con un módulo de comando o habilitado para el usuario"
			echo "La palabra a buscar no coincide con ningún módulo de comando existente o habilitado para el usuario"                
        		return 0
		fi
	fi
fi

}

function listar_modulos (){
	
	if [ -z "$1" ] 
	then
               	echo -e "\n-Paths absolutos de los módulos de comando autorizados para el usuario: -"
                for t in "${vectorComando[@]}"                                  # Imprime el array
                do
                        echo $t
                done

                echo -e "\n-Paths absolutos de los módulos periódicos autorizados para el usuario: -"
                for t in "${vectorPeriodicos[@]}"                                       # Imprime el array
                do
                        echo $t
                done
	else
		sh_log -B "Listar los Módulos" -a "Se pasó un parámetro a la función a ejecutar"
		echo Este Built-in no espera ningún parámetro                
                return 1
	fi

}


function actualizar_modulos (){

	if [ -z "$1" ] 
	then
		detenerModulos
		unset vectorComando
		unset vectorPeriodicos
		RegistrarModulos comando
		RegistrarModulos periodicos
		
		detenerModulos
		InicializarModulos comando
		InicializarModulos periodicos        
	else
		sh_log -B "Actualizar los Módulos" -a "Se pasó un parámetro a la función a ejecutar"
		echo Este Built-in no espera ningún parámetro
                return 1
	fi

}


function mostrar (){

	if [ -z "$1" ] #checkeo que llegue un parametro
	then
        	sh_log -M "Error al ejecutar comando built in Mostrar" -a "Se espera el paso de un parámetro a la función a ejecutar"
	        echo Este Built-in esperaba un parámetro                
	        return 1     
	else
        	variable=$1
	        echo ${!variable}
	fi   

}


function salir (){

	if [ -z "$1" ] 
	then
		exit
	else
		sh_log -B "Salir" -a "Se pasó un parámetro a la función a ejecutar"
		echo Este Built-in no espera ningún parámetro                
                return 1
	fi

}


function apagar () {

	if [ -z "$1" ] 
	then
                sudo shutdown now
	else
		sh_log -B "Apagar" -a "Se pasó un parámetro a la función a ejecutar"
		echo Este Built-in no espera ningún parámetro                
		return 1
        fi

}