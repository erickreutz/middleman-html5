#-----------------------------------------------------------------------------
# Directories
#-----------------------------------------------------------------------------

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

#-----------------------------------------------------------------------------
# Plugins
#-----------------------------------------------------------------------------

activate :directory_indexes

# activate :autoprefixer do |config|
#   config.browsers = [
#     'last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6',
#     'android 4'
#   ]
# end

activate :external_pipeline,
         name: :webpack,
         command: build? ?
         './node_modules/webpack/bin/webpack.js --bail -p' :
         './node_modules/webpack/bin/webpack.js --watch -d --progress --color',
         source: '.tmp/dist',
         latency: 1

#-----------------------------------------------------------------------------
# Development
#-----------------------------------------------------------------------------

configure :development do
  activate :livereload
  # activate :dotenv
end

#-----------------------------------------------------------------------------
# Build
#-----------------------------------------------------------------------------

configure :build do
  # "Ignore" JS so webpack has full control.
  ignore { |path| path =~ /\/(.*)\.js$/ && $1 != 'site' }

  activate :gzip
  activate :asset_hash
  activate :minify_css
  activate :minify_javascript

  activate :imageoptim do |config|
    config.manifest = true
    config.image_extensions = %w(.png .jpg .gif .svg)
    config.pngout = false
    config.svgo = false
  end

  activate :s3_sync do |sync|
    sync.bucket = ENV.fetch('AWS_BUCKET_NAME')
    sync.region = ENV.fetch('AWS_REGION')
    sync.aws_access_key_id = ENV.fetch('AWS_ACCESS_KEY_ID')
    sync.aws_secret_access_key = ENV.fetch('AWS_SECRET_ACCESS_KEY')
    sync.delete = true
    sync.path_style = true
    sync.prefer_gzip = true
  end

  activate :cloudfront do |cf|
    cf.access_key_id = ENV.fetch('AWS_ACCESS_KEY_ID')
    cf.secret_access_key = ENV.fetch('AWS_SECRET_ACCESS_KEY')
    cf.distribution_id = ENV.fetch('AWS_DISTRIBUTION_ID')
  end

  after_s3_sync do |files_by_status|
    invalidate files_by_status[:updated]
  end
end
