# Patch for middleman-blog

module BlogPaginatorMatchBlogLocale

  # Compare resource & blog locales
  def match_blog(res, md)
    super(res, md) && (@blog_controller.name.to_s == (res.path[/^\/?([a-z]{2})\//,1]  ||  I18n.default_locale).to_s)
  end

end

class Middleman::Blog::Paginator

  prepend BlogPaginatorMatchBlogLocale

end