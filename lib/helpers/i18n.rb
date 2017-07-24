module I18nHelpers

	def tr(value)
	  return nil unless value
	  return value if value.is_a? String
	  value[::I18n.locale] || value[::I18n.default_locale] || value.first
  end

  # remove locale prefix from path
  def unlocalize_path(path = current_page.path)
    exists_locale = path[/^\/?([a-z]{2})\//,1]
    exists_locale = nil unless langs.include? exists_locale&.to_sym
    exists_locale ? path[3..-1] : path
  end

	# add or change locale prefix if need
	def localize_path(locale, path = current_page.path)
    unlocale_path = unlocalize_path(path)
	  ::I18n.default_locale == locale ? unlocale_path : "/#{locale}#{unlocale_path}"
	end

	# get locale from path
	def locale_from_path(path = current_page.path)
		exists_locale = path[/^\/?([a-z]{2})\//,1]
		exists_locale = nil unless langs.include? exists_locale&.to_sym
		(exists_locale  ||  ::I18n.default_locale).to_sym
	end

  # cet current locale from path
	def locale_from_path!(path = current_page.path)
		::I18n.locale = locale_from_path(path)
	end

	# localize_path with current locale
	def lp(path)
	  localize_path ::I18n.locale, path
	end

	# set meta data from current locale
	def localize_page(scope)
	  title = t(:'title', scope: scope)
	  current_page.data.title = title if title
	end

end