module Lookbook
  module UI
    class Pane < BaseComponent
      with_slot :title do |&block|
        @toolbar_title = block.call
      end

      with_slot :tab_panel do |name, label: nil, **kwargs|
        name = name.to_s.parameterize
        @toolbar_tabs << {name: name, label: label}

        Lookbook::UI::TabPanel.new(name: name, **kwargs)
      end

      attr_reader :id, :toolbar_title, :toolbar_tabs, :toolbar_actions

      def initialize(id:, **kwargs)
        @id = id
        @toolbar_title = nil
        @toolbar_actions = []
        @toolbar_tabs = []
      end

      def with_action(**kwargs)
        @toolbar_actions << kwargs
      end
    end
  end
end