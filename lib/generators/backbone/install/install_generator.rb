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
            "",
            "// The necessary libraries are loaded",
            "//= require jquery.tmpl",
            "//= require jquery.iframe-transport",
            "//= require lib/jquery.ak.tools",
            "//= require lib/jquery.livequery",
            "//= require lib/jquery.maskedinput-1.3",
            "//= require lib/jshashtable-2.1",
            "//= require lib/jquery.numberformatter-1.2",
            "//= require lib/jquery.formatting.tmpl",
            "",
            "// Loads backbone files",
            "//= require underscore",
            "//= require backbone",
            "//= require backbone_rails_sync",
            "//= require backbone_datalink",
            "//= require backbone/#{application_name.underscore}",
            "",
            "// Loads all Bootstrap javascripts",
            "//= require bootstrap",
            "\n"
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
            "end\n",
            "",
            "def title_page",
            "  '#{application_name}'",
            "end"
          ].join("\n  ")
        end
      end

      def inject_in_gemfile
        append_file "Gemfile" do
          [
            "",
            "# Gems used for rails-backbone",
            "gem 'inherited_resources'",
            "gem 'will_paginate', '~> 3.0'",
            "gem 'acts_as_api'",
            "gem 'haml-rails'",
            "gem 'bootstrap-sass', '~> 2.0.1', :group => :assets"
          ].join("\n")
        end
      end

      def create_dir_layout
        %W{routers models views modules config}.each do |dir|
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
        empty_directory "app/views/backbone_templates"
        %w{error_alert info_alert success_alert warning_alert modal_form pagination}.each do |template_name|
          template "backbone_templates/_#{template_name}.haml", "app/views/backbone_templates/_#{template_name}.html.haml"
        end
      end

      def create_backbone_responses
        template "backbone_responses.rb", "lib/backbone_responses.rb"
      end

      def create_module_files
        %W{inheritance eip i18n ajax_requests number_helper pagination validations fill_dropbox modal_form}.each do |module_name|
          template "modules/#{module_name}.coffee", "app/assets/javascripts/backbone/modules/#{module_name}.js.coffee"
        end
      end

      def create_locale_files
        empty_directory "app/assets/javascripts/backbone/config/locales"
        template "config/locales/es-MX.coffee", "app/assets/javascripts/backbone/config/locales/es-MX.js.coffee"
      end

      def create_config_files
        template "config/string.coffee", "app/assets/javascripts/backbone/config/string.js.coffee"
      end

      def create_base_router
        template "base_router.coffee", "app/assets/javascripts/backbone/routers/base_router.js.coffee"
      end

      def create_representation_dir
        empty_directory "app/representations/"
        empty_directory "app/representations/api_v1"
      end

      def create_layout_stylesheet
        template "layout.css", "app/assets/stylesheets/layout.css.scss"
      end

      def inject_in_application_css
        inject_into_file "app/assets/stylesheets/application.css", :before => "*= require_self" do
          [
            "*= require layout",
            " "
          ].join("\n")
        end
      end

      def create_backbone_locales
        template "config/locales/backbone-MX.yml", "config/locales/backbone-MX.yml"
      end

    end
  end
end
