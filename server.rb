require "sinatra"
require "sinatra/activerecord"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "./database.sqlite3")

# set :database, {adapter: "sqlite3", database:"./database.sqlite3"}

enable :sessions

class User < ActiveRecord::Base
end

get "/" do
  erb :home
  # puts "running"
end

get "/signup" do
  @user = User.new
  erb :'user/signup'
  if session[:user_id]
    redirect "/"
  else
    erb :'user/signup'
  end
end

post "/signup" do
@user = User.new(params)
if @user.save
  p "#{@user.first_name} was saved to the database"
  redirect "/thanks"
end
end


get "/thanks" do
  erb :'user/thanks'
end

get "/login" do
  erb :'user/login'
  if session[:user_id]
    redirect "/"
  else
    erb :'user/login'
  end
end

post "/login" do
  given_password = params['password']
  user = User.find_by(email: params['email'])
  if user
    if user.password == given_password
      p "User authenticated successfully!"
      session[:user_id] = user.id
    else
      p "Invalid email or pasword"
    end
  end
end

#Delete request
post '/logout'do
  session.clear
  p "user logged out successfully"
  redirect "/"
end
