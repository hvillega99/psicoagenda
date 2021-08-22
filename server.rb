require 'sinatra'
require 'json'

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

get '/observaciones/:paciente'