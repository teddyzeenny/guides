require 'redcarpet'
require 'active_support'
require 'active_support/core_ext'

Dir['./lib/*'].each { |f| require f }

# Debugging
set(:logging, ENV['RACK_ENV'] != 'production')

activate :relative_assets
set :relative_links, true

set :markdown_engine, :redcarpet
set :markdown, :layout_engine => :erb,
         :fenced_code_blocks => true,
         :lax_html_blocks => true,
         :renderer => Highlighter::HighlightedHTML.new

activate :directory_indexes
activate :toc
activate :highlighter
activate :alias

###
# Swiftype
###
activate :swiftype do |swift|
  swift.api_key = ""
  swift.engine_slug = ""
  swift.pages_selector = lambda { |p| p.path.match(/\.html/) && p.metadata[:options][:layout] == nil }
end

###
# Build
###
configure :build do
  activate :minify_css
  activate :minify_javascript, ignore: /.*examples.*js/
end

###
# Pages
###
page '404.html', directory_index: false

# Don't build layouts standalone
ignore '*_layout.erb'

###
# Helpers
###
helpers do
  # Workaround for content_for not working in nested layouts
  def partial_for(key, partial_name=nil)
    @partial_names ||= {}
    if partial_name
      @partial_names[key] = partial_name
    else
      @partial_names[key]
    end
  end

  def rendered_partial_for(key)
    partial_name = partial_for(key)
    partial(partial_name) if partial_name
  end

  def page_classes
    classes = super
    return 'not-found' if classes == '404'
    classes
  end
end
