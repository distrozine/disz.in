class ProjectsExtension < ::Middleman::Extension

  define_setting :projects_dir, ENV['DZ_PROJECTS_DIR'] || 'projects', 'The directory projects are stored in'

  option :layout, 'project', 'Project-specific layout'

  def initialize(app, options_hash={}, &block)
    super

    app.data.store :projects, load_projects_data

    # link to projects from cities
    # app.data.cities.each {|city_name,_| app.data.cities[city_name].projects = []} 
    # app.data.projects.each do |project_name, project|
    #   project.cities.each do |city_name|
    #     app.data.cities[city_name.to_sym].projects.push project_name
    #   end
    # end

    # Require libraries only when activated
    # require 'necessary/library'

    # set up your extension
    # puts options.my_option

  end

  def after_configuration
  end

  # A Sitemap Manipulator
  def manipulate_resource_list(resources)
    # ignore project template
    app.sitemap.find_resource_by_path(options.layout).ignore!

    resources + app.data.projects.map do |name, project|
      project_resources(project)
    end.flatten
  end

  # helpers do
  #   def a_helper
  #   end
  # end

  private

  def load_projects_data
    projects = {}
    Dir.glob("#{app.config[:projects_dir]}/*/data.yml").each do |f|
      data_pathname = Pathname.new(f)
      project = OpenStruct.new(YAML.load_file(f).with_indifferent_access)
      project.name = data_pathname.dirname.basename.to_s
      project.photos = []
      Dir.glob((data_pathname.dirname + "photo*.jpg").to_s).each do |pf|
        project.photos << "/" + Pathname.new(pf).relative_path_from(Pathname.new("#{app.config[:projects_dir]}")).to_s
      end
      project[:cities].uniq!
      projects[project.name] = project
    end
    projects
  end

  def project_resources(project)
    [
      project_logo_resources(project),
      project_page_resources(project),
      project_photos_resources(project)
    ]
  end

  # localized project pages resources
  def project_page_resources(project)
    app.extensions[:i18n].langs.map do |locale|
      locale_path = "#{locale}/" if (locale != ::I18n.default_locale)
      ::Middleman::Sitemap::ProxyResource.new( app.sitemap, "#{locale_path}#{project.name}/index.html", options.layout).tap do | p |
        p.add_metadata options: {lang: locale}
        p.add_metadata locals: {
          'project' => project
        }
      end
    end
  end

  # logo images resources
  def project_logo_resources(project)
    source_file = File.join(app.root, app.config[:projects_dir], project.name, "logo.png")
    return [] unless File.exists?(source_file)
    [
      #image_resource(project, "logo_tiny.png", source_file, "48x48"),
      image_resource(project, "logo_small.png", source_file, "120x120"),
      image_resource(project, "logo.png", source_file, "240x240"), # is medium
      #image_resource(project, "logo_large.png", source_file, "480x480")
    ]
  end

  # logo images resources
  def project_photos_resources(project)
    photo_index = 0
    project.photos.map do |photo|
      source_file = File.join(app.root, app.config[:projects_dir], photo)
      photo_name = File.basename(photo, File.extname(photo))
      [
        image_resource(project, File.basename(photo), source_file, "320x320"), # is medium
        image_resource(project, "#{photo_name}_large.jpg", source_file, "640x640")
      ]
    end    
  end

  def image_resource(project, name, source, size)
    ImageResource.new(
      app.sitemap,
      "#{project.name}/#{name}",
      source,
      {resize: size}
    )
  end

  # Manipulated image
  class ImageResource < ::Middleman::Sitemap::Resource
    def initialize(store, path, source, options)
      
      @request_path = path
      @source = source
      @options = options
      read_image

      super(store, path)
    end

    # Pretend to be a template, so render gets called.
    #def template?
    #  true
    #end

    def binary?
      false
    end

    def read_image
      @_img = ::MiniMagick::Image.open(@source)
    end

    def render(*)
      if @options[:resize_to_fit]
        @_img.resize_to_fit(@options[:resize_to_fit])
      end

      if @options[:resize]
        @_img.resize(@options[:resize])
      end
      return @_img.to_blob
    end
  end

end

Middleman::Extensions.register :'diszin_projects' do
  ProjectsExtension
end
