module Lookbook
  class PageRenderer < ActionController::Base
    helper PageHelper

    layout false

    def render_page(page, locals = {}, template = nil)
      locals = {
        config: Lookbook.config,
        previews: Previews,
        pages: Pages,
        page: page,
        previous_page: page.previous,
        next_page: page.next,
        **locals
      }

      if template
        render template, locals: locals
      else
        render inline: page.content, locals: locals
      end
    end
  end
end