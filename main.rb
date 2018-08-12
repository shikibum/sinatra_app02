require 'sinatra'
require 'sinatra/reloader'
require 'json'

use Rack::MethodOverride

get '/' do
  @titles = Dir.glob('files/*').map do |name|
    name.sub(/files\//, '')
  end
  erb :index
end

get '/new' do
  erb :new
end

post "/new" do 
  @title = params['title']
  @body = open("files/#{params['title']}", 'w') {|f|
    a = params.slice('title', 'body').to_json
    f.write(a) 
  }
  redirect "/memos/#{params['title']}"
end

get '/memos/:id/edit' do
  contents = open("files/#{params['id']}") {|f|
    JSON.parse(f.read)
  }
  @title = contents['title']
  @body = contents['body']
  erb :edit
end

patch '/memos/:id/edit' do
  @title = params['title']
  @body = open("files/#{params['title']}", 'w') {|f|
    a = params.slice('title', 'body').to_json
    f.write(a) 
  }
  redirect "/memos/#{params['id']}"
end

get "/memos/:id" do
  contents = open("files/#{params['id']}") {|f|
    JSON.parse(f.read)
  }
  @title = contents['title'].gsub(/(\r\n|\r|\n)/, "<br>") 
  @body = contents['body'].gsub(/(\r\n|\r|\n)/, "<br>") 
  erb :show
end

delete '/memos/:id' do
  File.delete("files/#{params['id']}")
  redirect '/'
end