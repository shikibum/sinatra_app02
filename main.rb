require 'sinatra'
require 'sinatra/reloader'

use Rack::MethodOverride

class Memo
end


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
  str = STDIN.gets
  File.open("/files/#{$stdin}.txt", 'w'){|f|
     f.puts str
   }
  redirect '/'
  erb :new
end

get '/memos/:id/edit' do
  @title = params['id']
  @body = open("files/#{params['id']}") {|f|
    f.readlines
  }
  erb :edit
end

patch '/memos/:id/edit' do
  @title = params['id']
  @body = open("files/#{params['id']}", 'w') {|f|
    f.write(params['body']) 
  }
  redirect "/memos/#{params['id']}"
end

get "/memos/:id" do
  @title = params['id']
  @body = open("files/#{params['id']}") {|f|
    f.readlines
  }
  erb :show
end

delete '/memos/:id' do
  File.delete("files/#{params['id']}")
  redirect '/'
end