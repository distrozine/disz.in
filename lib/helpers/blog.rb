module BlogHelpers

  # return blog for current locale
  # def current_blog
  #   blog I18n.locale
  # end

  def blog_article_date(article)
    I18n.l article.date.to_date, format: :long
  end


  # def blog_article_short_date(article)
  #   l article.date, format: :short
  # end


  def blog_article_dir(article)
    unlocalize_path article.url
  end

  def blog_article_asset_path(article, path)
    File.join(blog_article_dir(article), path)
  end

  def blog_article_image_tag(article, path, *args)
    args.unshift blog_article_asset_path(article, path)
    image_tag(*args)
  end

  def blog_articles(blog_name=nil)
    limit = current_resource.data[:per_page]
    articles = blog(blog_name).articles
    limit ? articles.first(limit) : articles
  end

  def blog_calendar_item_date(page_type, year, month, day)
    case page_type
      when 'day'; I18n.l Date.new(year, month, day), format: '%e %b %Y';
      when 'month'; I18n.l Date.new(year, month, 1), format: '%b %Y' ;
      when 'year'; year;
    end
  end

  def partial_blog_pagination(paginate, prev_page, next_page, num_pages, page_number)
    partial 'partials/blog/pagination', locals: {
          paginate: paginate,
          prev_page: prev_page, next_page: next_page,
          num_pages: num_pages, page_number: page_number
      }
  end

  def blog_article_with_cover?(article)
    File.exist?(File.join('source', blog_article_asset_path(article, 'cover.jpg')))
  end
end

module I18nBlogController

  def blog_controller(blog_name=nil)
    super blog_name || I18n.locale
  end

end

module Middleman::Blog::Helpers

  prepend I18nBlogController

end