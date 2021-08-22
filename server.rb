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