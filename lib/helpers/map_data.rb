module MapDataHelpers
	def map_data
    cities = {}
    data.cities.each do |name, city|
      cities[name] = {name:name}
      cities[name][:latlng] = city.latlng
      cities[name][:title] = tr city.title
      cities[name][:location] = tr city.location
      cities[name][:projects] = []
    end
    projects = {}
    data.projects.each do |name, project|
      prj = {
        name: name,
        title: tr(project.title),
        summary: tr(project.summary),
        about: tr(project.about),
        logo: "/#{project.name}/logo_small.png",
        url: lp("/#{project.name}")
      }
      project.cities.each {|city_name| cities[city_name][:projects] << name }
      projects[name] = prj
    end
    cities.select!{|_, city| city[:projects].any?}
    {
      cities: cities,
      projects: projects
    }
  end
end