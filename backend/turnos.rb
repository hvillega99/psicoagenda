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

#obtener todos los turnos
get '/turnos' do
    @result = client.query("SELECT * FROM turnos", :symbolize_keys => true).each
    erb :turnos
end

#obtener turno por id
get '/turnos/:id' do
    @result = client.query("SELECT * FROM turnos WHERE id='#{params[:id]}'", :symbolize_keys => true).each
    erb :turnos
end

#obtener turnos disponibles por id de psicólogo
get '/turnos/disponibles/:idPsicologo' do
    @result = client.query("SELECT * FROM turnos where estado='disponible' and idPsicologo='#{params[:idPsicologo]}'", :symbolize_keys => true).each
    erb :turnos
end

#crear un turno
post '/turnos' do
    data = JSON.parse request.body.read
    client.query("INSERT INTO turnos (fecha,hora,estado,idPsicologo) VALUES ('#{data['fecha']}','#{data['hora']}','#{data['estado']}','#{data['idPsicologo']}')")
    @result = client.query("SELECT * FROM turnos ORDER BY id DESC LIMIT 1", :symbolize_keys => true).each
    erb :turnos
end

#actualizar un turno
put '/turnos/:id' do
    data = JSON.parse request.body.read
    client.query("UPDATE turnos SET fecha = '#{data['fecha']}', hora = '#{data['hora']}', estado = '#{data['estado']}', idPsicologo = '#{data['idPsicologo']}' WHERE id='#{params[:id]}'")
    @result = client.query("SELECT * FROM turnos WHERE id='#{params[:id]}'", :symbolize_keys => true).each
    erb :turnos
end