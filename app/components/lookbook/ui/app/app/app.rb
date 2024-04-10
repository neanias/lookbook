module Lookbook
  module UI
    class App < BaseComponent
      with_slot :header
      with_slot :main
      with_slot :status_bar, Lookbook::UI::StatusBar

      with_slot :previews_nav do |tree, **kwargs|
        Lookbook::UI::NavTree.new(id: "previews-nav-tree", tree: tree, filter: config.previews_nav_filter, **kwargs)
      end

      with_slot :pages_nav do |tree, **kwargs|
        Lookbook::UI::NavTree.new(id: "pages-nav-tree", tree: tree, filter: config.pages_nav_filter, **kwargs)
      end
    end
  end
end
