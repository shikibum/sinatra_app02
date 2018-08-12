require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

use Rack::MethodOverride

get '/' do
  @contents = Dir.glob('files/*').map do |name|
    open(name) {|f|
      JSON.parse(f.read)
    } 
  end
  erb :index
end

get '/new' do
  erb :new
end

post "/new" do
  id = SecureRandom.hex(16)
  open("files/#{id}", 'w') {|f|
    a = params.slice('title', 'body')
    a['id'] = id
    f.write(a.to_json)
  }
  redirect "/memos/#{id}"
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
  open("files/#{params['id']}", 'w') {|f|
    a = params.slice('title', 'body', 'id')
    f.write(a.to_json)
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