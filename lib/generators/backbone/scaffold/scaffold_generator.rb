require 'generators/backbone/model/model_generator'

module Backbone
  module Generators
    class ScaffoldGenerator < ModelGenerator

      source_root File.expand_path("../templates", __FILE__)
      desc "This generator creates the client side crud scaffolding"

      def inject_into_routes
        inject_into_file "config/routes.rb", :after => "Application.routes.draw do\n" do
          "\n  resources :#{plural_name}\n"
        end
      end

      def create_router_files
        template 'router.coffee', File.join(backbone_path, "routers", class_path, "#{plural_name}_router.js.coffee")
      end

      def create_view_files
        available_views.each do |view|
          template "views/#{view}_view.coffee", File.join(backbone_path, "views", plural_name, "#{view}_view.js.coffee")
          template "templates/#{view}.haml", File.join(backbone_tmpl_path, plural_name, "_#{view}.html.haml")
        end

        template "views/model_view.coffee", File.join(backbone_path, "views", plural_name, "#{singular_name}_view.js.coffee")
        template "templates/model.haml", File.join(backbone_tmpl_path, plural_name, "_#{singular_name}.html.haml")
        template "templates/form.haml", File.join(backbone_tmpl_path, plural_name, "_form.html.haml")
        template "index.haml", File.join(backbone_tmpl_path, plural_name, "index.html.haml")
      end

      def create_rails_controller
        template "controller.rb", File.join(controllers_path, "#{plural_name}_controller.rb")
      end

      protected

        def available_views
          %w(index show new edit)
        end

    end
  end
end
