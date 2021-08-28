require 'sinatra'
require 'json'
require 'mysql2'

client = Mysql2::Client.new(:host => "b6joa72sftrldpb59ymx-mysql.services.clever-cloud.com", :username => "utx94vo4wamo01ew", :password => "eZf9Ncc4YyeQ9uWBRgAq", :database => "b6joa72sftrldpb59ymx")

client.query("SELECT * FROM pacientes", :symbolize_keys => true).each do |row|

    puts "row: #{row}"
    
end

before do
    content_type :json
end

get '/' do
    @message = 'Put this in your pipe & smoke it!'
    erb :result
end

get '/saludo/:nombre' do
    @message = "Hola #{params[:nombre]}"
    erb :result
end

#Aqui empieza mi trabajo

#Pacientes
get '/pacientes' do
    @pacientesOrCitas = client.query("SELECT * FROM pacientes").each
    erb :pacienteORCita
end

post '/pacientes' do
    data = JSON.parse request.body.read
    #client.query("INSERT INTO pacientes (cedula,nombreCompleto,email,clave) VALUES ('0931451561','Daniel Viscarra','danielviscarra@gmail.com','123456drvz')")
    client.query("INSERT INTO pacientes (cedula,nombreCompleto,email,clave) VALUES ('#{data['cedula']}','#{data['nombreCompleto']}','#{data['email']}','#{data['clave']}')")
    @message = "Paciente creado"
    erb :result
end

#Citas
get '/citas' do
    @pacientesOrCitas = client.query("SELECT pacientes.nombreCompleto, psicologos.id, turnos.fecha, turnos.hora
                            FROM citas
                            INNER join pacientes on citas.idPaciente = pacientes.id
                            INNER join turnos on citas.idTurno = turnos.id
                             INNER join psicologos on turnos.idPsicologo = psicologos.id"
                ).each    
    erb :pacienteORCita
end

get '/citas/:idPsicologo' do
    @pacientesOrCitas = client.query("SELECT psicologos.id, turnos.fecha, turnos.hora
                FROM citas
                INNER join turnos on citas.idTurno = turnos.id
                INNER join psicologos on turnos.idPsicologo = psicologos.id
                WHERE psicologos.id=#{params[:idPsicologo]}"
                ).each    
    erb :pacienteORCita
end

post '/citas' do
    data = JSON.parse request.body.read
    
    client.query("UPDATE turnos SET estado = 'ocupado' WHERE id=#{data['idTurno']}")
    client.query("INSERT INTO citas (estado,idPaciente,idTurno) VALUES ('#{data['estado']}','#{data['idPaciente']}','#{data['idTurno']}')")
    @message = "Cita creada"
    erb :result

end

put '/citas/:idCita' do
    data = JSON.parse request.body.read
    client.query("UPDATE citas SET estado = '#{data['estado']}', idPaciente = '#{data['idPaciente']}', idTurno = '#{data['idTurno']}' WHERE id=#{params[:idCita]}")
    @message = "Cita actualizada"
    erb :result
end

delete '/citas/:idCita' do

    #client.query("UPDATE turnos SET estado = 'disponible' WHERE id=#{data['idTurno']}")
    turno=client.query("SELECT idTurno FROM citas WHERE id=#{params[:idCita]}").each

    turnoID = turno[0]["idTurno"]
    client.query("UPDATE turnos SET estado = 'disponible' WHERE id=#{turnoID}")
    #puts turnoID

    client.query("DELETE FROM citas WHERE id=#{params[:idCita]}")
    @message = "Cita eliminada"
    erb :result
end

