require "combustion"

Combustion.path = "test/demo"
Combustion.initialize! :action_controller, :action_view, :action_mailer, :sprockets do
  config.autoload_paths << "#{root}/app/views/components"

  config.view_component.default_preview_layout = "preview"

  config.lookbook.project_name = "Lookbook test app"

  config.lookbook.preview_display_options = {
    max_width: "100%",
    color_scheme: {
      label: "Color scheme",
      choices: [
        ["Dark", "dark"],
        ["Light", "light"]
      ],
      default: "light"
    }
  }

  config.lookbook.preview_paths << "#{root}/lookbook/previews"
  config.lookbook.page_paths << "#{root}/lookbook/docs"

  config.lookbook.ui_status_bar = true
end
