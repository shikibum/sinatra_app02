require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'sinatra/cookies'

use Rack::MethodOverride
set :cookie_options, { domain: 'localhost', path: '/' }

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

post "/memos" do
  id = SecureRandom.hex(16)
  while File.exist?("files/#{id}") do
    id = SecureRandom.hex(16)
  end 

  open("files/#{id}", 'w') {|f|
    a = params.slice('title', 'body')
    a['id'] = id
    f.write(a.to_json)
  }
  redirect "/memos/#{id}"
end

get '/memos/:id/edit' do
  if cookies[:user_id] == nil
    cookies[:user_id] = SecureRandom.hex(16)
  end
  if File.exist?("locks/#{params['id']}")
    redirect "/error"
  else
    open("locks/#{params['id']}", 'w'){|f|}
    @content = open("files/#{params['id']}") {|f|
      JSON.parse(f.read)
    }
  end
  erb :edit
end

patch '/memos/:id' do
  open("files/#{params['id']}", 'w') {|f|
    a = params.slice('title', 'body', 'id')
    f.write(a.to_json)
  }
  redirect "/memos/#{params['id']}"
end

patch '/memos/:id/cancel' do
  File.delete("locks/#{params['id']}")
  redirect "/memos/#{params['id']}"
end

get "/memos/:id" do
  @content = open("files/#{params['id']}") {|f|
    JSON.parse(f.read)
  }

  erb :show
end

delete '/memos/:id' do
  File.delete("files/#{params['id']}")
  redirect '/'
end

get '/error' do
  erb :error
end 