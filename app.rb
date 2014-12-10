Bundler.require

require 'sinatra/asset_pipeline'

class App < Sinatra::Base
  set :assets_digest, false

  register Sinatra::AssetPipeline

  configure do |config|
    cache_dir = File.join(settings.root, "tmp", "cache")
    config.sprockets.cache = Sprockets::Cache::FileStore.new(cache_dir)
  end

  get '/' do
    haml :index
  end

  get '/cube' do
    haml :cube
  end
end
