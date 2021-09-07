require 'sinatra'
require 'json'
require 'mysql2'

client = Mysql2::Client.new(
    :host => "b6joa72sftrldpb59ymx-mysql.services.clever-cloud.com", 
    :username => "utx94vo4wamo01ew", 
    :password => "eZf9Ncc4YyeQ9uWBRgAq", 
    :database => "b6joa72sftrldpb59ymx"
)

before do
    content_type :json
end

#Pacientes-------------------------------
#Obtener todos los pacientes
get '/pacientes' do
    @pacientesOrCitas = client.query("SELECT * FROM pacientes").each
    erb :pacienteORCita
end

#Obtener paciente por id
get '/pacientes/:id' do
    @pacientesOrCitas = client.query("SELECT * FROM pacientes WHERE id = #{params[:id].to_i}").each
    erb :pacienteORCita
end


#Crear paciente
post '/pacientes' do
    data = JSON.parse request.body.read
    client.query("INSERT INTO pacientes (cedula,nombreCompleto,email,clave) VALUES ('#{data['cedula']}','#{data['nombreCompleto']}','#{data['email']}','#{data['clave']}')")
    @message = "Paciente creado"
    erb :result
end

#Psicólogos-------------------------------
#Obtener todos los psicólogos
get '/psicologos' do
    @psicologos = client.query("SELECT * from psicologos", :symbolize_keys => true).each
    erb :resultpsico
end

#Obtener psicólogo por id
get '/psicologos/:id' do
    @psicologos = client.query("SELECT * from psicologos WHERE id = #{params[:id].to_i}", :symbolize_keys => true).each
    erb :resultpsico
end

#Crear psicólogo
post '/psicologos' do
    data = JSON.parse request.body.read
    client.query("INSERT INTO psicologos(cedula, nombreCompleto, email, clave) VALUES ('#{data['cedula']}', '#{data['nombreCompleto']}', '#{data['email']}', '#{data['clave']}')", :symbolize_keys => true)
    @psicologos = client.query("SELECT * FROM  psicologos ORDER BY id DESC LIMIT 1", :symbolize_keys => true).each
    erb :resultpsico
end

#Atenciones-------------------------------
#Obtener todas las atenciones
get '/atenciones' do
    @atenciones = client.query("SELECT * FROM atenciones", :symbolize_keys => true)
    erb :resultatenciones
end

#Obtener atención por id de paciente. Muestra nombres de los psicólogos, observaciones y fechas.
get '/atenciones/:id' do
    @patenciones = client.query("SELECT atenciones.idPaciente, psicologos.nombreCompleto, atenciones.observaciones, atenciones.fecha
                                FROM atenciones
                                INNER join psicologos on atenciones.idPsicologo = psicologos.id
                                WHERE idPaciente = #{params[:id].to_i}", :symbolize_keys => true).each
    erb :resultpatenciones
end

#Crear atención.
post '/atenciones' do
    data = JSON.parse request.body.read
    client.query("INSERT INTO atenciones VALUES ('#{data['idPaciente']}', '#{data['idPsicologo']}', '#{data['observaciones']}', '#{data['fecha']}')", :symbolize_keys => true)
    @atenciones = client.query("SELECT * FROM atenciones ORDER BY fecha LIMIT 1", :symbolize_keys => true)
    erb :resultatenciones
end

#Turnos-------------------------------
#Obtener todos los turnos
get '/turnos' do
    @result = client.query("SELECT * FROM turnos", :symbolize_keys => true).each
    erb :turnos
end

#Obtener turno por id
get '/turnos/:id' do
    @result = client.query("SELECT * FROM turnos WHERE id='#{params[:id]}'", :symbolize_keys => true).each
    erb :turnos
end

#Obtener turnos disponibles por id de psicólogo
get '/turnosDisponibles/:idPsicologo' do
    @result = client.query("SELECT * FROM turnos where estado='disponible' and idPsicologo='#{params[:idPsicologo]}'", :symbolize_keys => true).each
    erb :turnos
end

#Crear turno
post '/turnos' do
    data = JSON.parse request.body.read
    client.query("INSERT INTO turnos (fecha,hora,estado,idPsicologo) VALUES ('#{data['fecha']}','#{data['hora']}','#{data['estado']}','#{data['idPsicologo']}')")
    @result = client.query("SELECT * FROM turnos ORDER BY id DESC LIMIT 1", :symbolize_keys => true).each
    erb :turnos
end

#Actualizar estado del turno
put '/turnos/:id' do
    data = JSON.parse request.body.read
    client.query("UPDATE turnos SET estado = '#{data['estado']}' WHERE id='#{params[:id]}'")
    @result = client.query("SELECT * FROM turnos WHERE id='#{params[:id]}'", :symbolize_keys => true).each
    erb :turnos
end

#Citas-------------------------------
#Obtener todas las citas
get '/citas' do
    @pacientesOrCitas = client.query("SELECT citas.idPaciente, 
                                    turnos.idPsicologo, 
                                    citas.estado, 
                                    turnos.fecha, 
                                    turnos.hora
                                    FROM citas
                                    INNER join pacientes on citas.idPaciente = pacientes.id
                                    INNER join turnos on citas.idTurno = turnos.id
                                    INNER join psicologos on turnos.idPsicologo = psicologos.id").each    
    erb :pacienteORCita
end

#Obtener citas por id de paciente
get '/citasPorPaciente/:idPaciente' do
    @pacientesOrCitas = client.query("SELECT citas.id, 
                                    turnos.idPsicologo, 
                                    psicologos.nombreCompleto,
                                    citas.estado, 
                                    turnos.fecha, 
                                    turnos.hora
                                    FROM citas
                                    INNER join pacientes on citas.idPaciente = pacientes.id
                                    INNER join turnos on citas.idTurno = turnos.id
                                    INNER join psicologos on turnos.idPsicologo = psicologos.id
                                    WHERE pacientes.id=#{params[:idPaciente]}").each    
    erb :pacienteORCita
end

#Obtener citas por id de psicólogo
get '/citasPorPsicologo/:idPsicologo' do
    @pacientesOrCitas = client.query("SELECT citas.id,
                                    citas.idPaciente, 
                                    pacientes.nombreCompleto, 
                                    citas.estado,
                                    turnos.fecha, 
                                    turnos.hora
                                    FROM citas
                                    INNER join turnos on citas.idTurno = turnos.id
                                    INNER join psicologos on turnos.idPsicologo = psicologos.id
                                    INNER join pacientes on citas.idPaciente = pacientes.id
                                    WHERE psicologos.id=#{params[:idPsicologo]}").each    
    erb :pacienteORCita
end

#Crear una cita
post '/citas' do
    data = JSON.parse request.body.read
    
    client.query("UPDATE turnos SET estado = 'ocupado' WHERE id=#{data['idTurno']}")
    client.query("INSERT INTO citas (estado,idPaciente,idTurno) VALUES ('#{data['estado']}','#{data['idPaciente']}','#{data['idTurno']}')")
    @message = "Cita creada"
    erb :result

end

#Actualizar estado de la cita
put '/citas/:idCita' do
    data = JSON.parse request.body.read
    client.query("UPDATE citas SET estado = '#{data['estado']}' WHERE id=#{params[:idCita]}")
    @message = "Cita actualizada"
    erb :result
end

#Eliminar cita
delete '/citas/:idCita' do

    turno=client.query("SELECT idTurno FROM citas WHERE id=#{params[:idCita]}").each

    turnoID = turno[0]["idTurno"]
    client.query("UPDATE turnos SET estado = 'disponible' WHERE id=#{turnoID}")

    client.query("DELETE FROM citas WHERE id=#{params[:idCita]}")
    @message = "Cita eliminada"
    erb :result
end