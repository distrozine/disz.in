module TagsHelpers

  def tagvalue(tagname, scope, value)
    t("#{tagname}.#{value}", scope: "tags.#{scope}", :default => tagname)
  end

  def tagtitle(tagname, scope)
    tagvalue tagname, scope, 'title'
  end

  def taginfo(tagname, scope)
    tagvalue tagname, scope, 'info'
  end

  def blog_tagtitle(tagname)
    tagtitle tagname, 'blog_articles'
  end

  def blog_taginfo(tagname)
    taginfo tagname, 'blog_articles'
  end

end