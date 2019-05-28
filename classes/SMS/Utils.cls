Class SMS.Utils Extends %Library.SerialObject [ ProcedureBlock ]
{

ClassMethod sendSMS(tel, mensaje, tipoMensaje) As %Status
{
	// d ##class(SMS.Utils).sendSMS("+34669093991","hola desde MSC","SMS")

	s pathOBJ=##class(CARPINTERIA.Parametros).%OpenId("SMSScript")
	s path=pathOBJ.Valor
	//s tipoServicio=pathOBJ.Extra  // Si es SMS entonces envio SMS si es otra cosa envio iMessage. Lo uso para pruebas
	s tipoServicio=tipoMensaje
	// osascript sendMessage.applescript "+34669093991" "Hola esto es otra prueba" "SMS"	
	
	//OJO
	// He tenido que añadir el NOPASSWD para %admin y para cacheusr para tener que evitar tener que pasar la password al sudo que era un coñazo y siempre fallaba
	// sudo visudo
	// # User privilege specification
	// root    ALL=(ALL) ALL
	// %admin  ALL=(ALL) NOPASSWD: ALL
	// cacheusr ALL=(ALL) NOPASSWD: ALL
	s comando="sudo -S -u MSCAdministrador osascript "_path_" """_tel_""" """_mensaje_""" """_tipoServicio_""""
	s errorzf="null"
	s errorzf=$ZF(-1,$ZCONVERT(comando,"O","UTF8")) // error is 1 if the command fails and 0 if works
	//S ^MARIO("SMS",errorzf,$J)=comando
	If (errorzf){
		quit '$$$OK
	}Else{
		quit $$$OK
	}
}

ClassMethod encolaSMS(trabajoId, tel, mensaje, tipoMensaje = "SMS")
{
	set ^MSC("SMS",$I(^MSC("SMS"))) = trabajoId_"#"_tel_"#"_mensaje_"#"_tipoMensaje
	job ..procesaColaSMS() 
	quit
}

ClassMethod procesaColaSMS()
{
	 // Si no hay ningún proceso procesando la cola me la quedo
	lock +^MSC("SMS","jobProcesandoCola"):0
	quit:'$TEST  // Me salgo si no consigo el lock
	
	set key=$ORDER(^MSC("SMS",""))
	while (key'="") {
	     //set ^procesado($I(^procesado),$J) = key_" - "_^MSC("SMS",key)
	     do ..mandaSMSyReporta(^MSC("SMS",key))
	     set currentKey=key
	     k ^MSC("SMS",key)
	     set key = $ORDER(^MSC("SMS",currentKey))
	}
   
   lock -^MSC("SMS","jobProcesandoCola")
}

ClassMethod mandaSMSyReporta(trabajoTelMensajeTipo)
{
	set trabajoId=$P(trabajoTelMensajeTipo,"#",1)
	set telefono=$P(trabajoTelMensajeTipo,"#",2)
	set textoSMS=$P(trabajoTelMensajeTipo,"#",3)
	set sms=$P(trabajoTelMensajeTipo,"#",4)
	
	set st=..sendSMS(telefono,textoSMS,sms)
	if $$$ISOK(st){
		set resultado="Mensaje "_sms_" enviado correctamente"
		set color="#006400;"		
	}else{
		set resultado="Error en el envio del mensaje "_sms
		set color="#ff0000;"
	}
	
	do ##class(SMS.RegistroEnvio).AddRegistroEnvio(trabajoId,telefono,textoSMS,$$$ISOK(st))
	
	// envio incidencia si hay trabajo
	set trabajo=##class(CARPINTERIA.Trabajo).%OpenId(trabajoId)
	if $IsObject(trabajo){
		set descripcion="<b><span style='color:"_color_"'><b>"_resultado_":</b></span><br/>Telefono:"_telefono_"<br/>Mensaje:"_textoSMS
		do ##class(CARPINTERIA.Utils).AddIncidencia(trabajoId,descripcion)
	}
	
	quit
}

// Obtiene un número valido de movil a partir de un telefono con texto

ClassMethod getMovil(tel) As %String
{
	set movil=""
	set telSinEspacios=$ZSTRIP(tel,"*W") 
	set sc=$LOCATE(telSinEspacios,"[6]\d{8}",,,movil) //formato 611111111
	
	quit movil
}

Storage Default
{
<StreamLocation>^SMS.UtilsS</StreamLocation>
<Type>%Library.CacheSerialState</Type>
}

}
