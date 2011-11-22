require 'generators/backbone/resource_helpers'

module Backbone
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Backbone::Generators::ResourceHelpers

      source_root File.expand_path("../templates", __FILE__)

      desc "This generator installs backbone.js with a default folder layout in app/assets/javascripts/backbone"

      class_option :skip_git, :type => :boolean, :aliases => "-G", :default => false,
                              :desc => "Skip Git ignores and keeps"

      def inject_backbone
        inject_into_file "app/assets/javascripts/application.js", :before => "//= require_tree" do
          [
            "//= require jquery.tmpl",
            "//= require underscore",
            "//= require backbone",
            "//= require backbone_rails_sync",
            "//= require backbone_datalink",
            "//= require backbone/#{application_name.underscore}\n"
          ].join("\n")
        end
      end

      def inject_in_application_helper
        inject_into_file "app/helpers/application_helper.rb", :after => "module ApplicationHelper" do
          [
            "\n",
            "def script_template(*args)",
            "  name    = args.first",
            "  options = args.second || {}",
            "  id      = options[:id] || \"backbone_templates_\#{controller_name}_\#{name}\"",
            "  locals  = options[:locals] || {}",
            "  partial = options[:partial] || \"\#{controller_name}/\#{name}\"",
            "  id = id.camelize(:lower)",
            "  content_tag(:script, :type => \"text/template\", :id => id) do",
            "    render :partial => partial, :locals => locals",
            "  end",
            "end\n"
          ].join("\n  ")
        end
      end

      def create_dir_layout
        %W{routers models views modules}.each do |dir|
          empty_directory "app/assets/javascripts/backbone/#{dir}"
          create_file "app/assets/javascripts/backbone/#{dir}/.gitkeep" unless options[:skip_git]
        end
      end

      def create_app_file
        template "app.coffee", "app/assets/javascripts/backbone/#{application_name.underscore}.js.coffee"
      end

      def create_helpers_file
        template "helpers.coffee", "app/assets/javascripts/backbone/helpers.js.coffee"
      end

      def create_base_model_file
        template "base_model.coffee", "app/assets/javascripts/backbone/models/base_model.js.coffee"
      end

      def create_base_view_file
        template "base_view.coffee", "app/assets/javascripts/backbone/views/base_view.js.coffee"
      end

      def create_base_collection_file
        template "base_collection.coffee", "app/assets/javascripts/backbone/models/base_collection.js.coffee"
      end

      def create_dir_backbone_alerts
        empty_directory "app/views/backbone_alerts"
        template "alerts/_error_alert.haml", "app/views/backbone_alerts/_error_alert.html.haml"
        template "alerts/_info_alert.haml", "app/views/backbone_alerts/_info_alert.html.haml"
        template "alerts/_success_alert.haml", "app/views/backbone_alerts/_success_alert.html.haml"
        template "alerts/_warning_alert.haml", "app/views/backbone_alerts/_warning_alert.html.haml"
      end

      def create_pagination_template
        template "alerts/_pagination.haml", "app/views/backbone_alerts/_pagination.html.haml"
      end

      def create_backbone_responses
        template "backbone_responses.rb", "lib/backbone_responses.rb"
      end

      def create_inheritance_module_file
        template "modules/inheritance.rb", "app/assets/javascripts/backbone/modules/inheritance.js.coffee"
      end

    end
  end
end
