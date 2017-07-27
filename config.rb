###
# Own helpers
###

Dir["./lib/helpers/*.rb"].each {|file| require file }
helpers I18nHelpers
helpers MapDataHelpers
helpers BlogHelpers
helpers TagsHelpers

###
# I18n
###

langs = [:ru, :en]
root_lang = :ru
activate :i18n, :langs => langs, :mount_at_root => root_lang


###
# Blog extension
###

require 'lib/fix_blog'

langs.each do |lang|
  is_root_lang = lang == root_lang
  activate :blog do |blog|
    blog.name = lang
    blog.permalink = "#{'{locale}/' unless is_root_lang}blog/{year}/{month}/{day}/{title}"
    blog.sources = "#{'{locale}/' unless is_root_lang}blog/{year}/{month}/{day}/{title}/index.html"
    blog.layout = 'blog_article'
    blog.default_extension = '.md'

    blog.year_link = "#{"#{lang}/" unless is_root_lang}blog/{year}/index.html"
    blog.month_link = "#{"#{lang}/" unless is_root_lang}blog/{year}/{month}/index.html"
    blog.day_link = "#{"#{lang}/" unless is_root_lang}blog/{year}/{month}/{day}/index.html"
    blog.taglink = "#{"#{lang}/" unless is_root_lang}blog/tags/{tag}/index.html"

    blog.tag_template = 'blog/tag.html'
    blog.calendar_template = 'blog/calendar.html'

    blog.paginate = true
    blog.per_page = 4
    blog.page_link = 'page/{num}'
  end
end


# Pages without .html ext
activate :directory_indexes

###
# Compass & sprockets
###

# Change Compass configuration
compass_config do |config|
  config.add_import_path "bower_components/foundation-sites/scss/"
  config.output_style = :compact

  # Set this to the root of your project when deployed:
  config.http_path = "/"
  config.css_dir = "stylesheets"
  config.sass_dir = "stylesheets"
  config.images_dir = "images"
  config.javascripts_dir = "javascripts"
end

# Activate sprockets
activate :sprockets

# Add bower's directory to sprockets asset path
after_configuration do
  @bower_config = JSON.parse(IO.read("#{root}/.bowerrc"))
  sprockets.append_path File.join "#{root}", @bower_config["directory"]
end

# Use the correct vendor prefixes for foundation
activate :autoprefixer do |config|
  config.browsers = ['last 2 versions', 'ie >= 9', 'and_chr >= 2.3']
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

ignore 'bower_components/*'

# sitemap.xml
#page 'sitemap.xml', layout: false

###
# Own extensions
###
Dir["./lib/extensions/*.rb"].each {|file| require file }

activate :diszin_projects



# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end


# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster not for this website
  # activate :asset_hash
end

# helpers do
  
# end
