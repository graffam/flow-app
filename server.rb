require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'omniauth-github'
require 'dotenv'

Dotenv.load

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']

  use OmniAuth::Builder do
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
  end
end


def user_from_omniauth(auth)
  binding.pry
  {
    uid:auth.uid,
    provider: auth.provider,
    username:auth.info.nickname,
    avatar_url: auth.info.image
  }
end

def create_user(user_info)

get '/' do
  erb :index
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']
  user_info = user_from_omniauth(auth)

end
