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

# Mostrar psicologos
get '/psicologos' do
    @psicologos = client.query("SELECT * from psicologos", :symbolize_keys => true)
    erb :resultpsico
end

#Mostrar un psicologo
get '/psicologos/:id' do
    @psicologos = client.query("SELECT * from psicologos WHERE id = #{params[:id].to_i}", :symbolize_keys => true)
    erb :resultpsico
end

#Crear un psicologo
post '/psicologos' do
    data = JSON.parse request.body.read
    client.query("INSERT INTO psicologos(cedula, nombreCompleto, email, clave) VALUES ('#{data['cedula']}', '#{data['nombreCompleto']}', '#{data['email']}', '#{data['clave']}')", :symbolize_keys => true)
    @psicologos = client.query("SELECT * FROM  psicologos ORDER BY id DESC LIMIT 1", :symbolize_keys => true)
    erb :resultpsico
end

#Mostrar atenciones
get '/atenciones' do
    @atenciones = client.query("SELECT * FROM atenciones", :symbolize_keys => true)
    erb :resultatenciones
end

#Mostrar atenciones por id de Cliente
get '/atenciones/:id' do
    @patenciones = client.query("SELECT atenciones.idPaciente, psicologos.nombreCompleto, atenciones.observaciones, atenciones.fecha
                                FROM atenciones
                                INNER join psicologos on atenciones.idPsicologo = psicologos.id
                                WHERE idPaciente = #{params[:id].to_i}", :symbolize_keys => true)
    erb :resultpatenciones
end

#Creat atenciones
post '/atenciones' do
    data = JSON.parse request.body.read
    client.query("INSERT INTO atenciones VALUES ('#{data['idPaciente']}', '#{data['idPsicologo']}', '#{data['observaciones']}', '#{data['fecha']}')", :symbolize_keys => true)
    @atenciones = client.query("SELECT * FROM atenciones ORDER BY fecha LIMIT 1", :symbolize_keys => true)
    erb :resultatenciones
end

