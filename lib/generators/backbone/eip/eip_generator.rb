require 'generators/backbone/resource_helpers'

module Backbone
  module Generators
    class EipGenerator < Rails::Generators::NamedBase
      include Backbone::Generators::ResourceHelpers

      source_root File.expand_path("../templates", __FILE__)
      desc "This generator creates haml eip views and eip module is included in backbone form view"

      argument :attributes, :type => :array, :default => [], :banner => "eip_node field:type"

      def initialize(args=[], options={}, config={})
        super
        find_eip_node
      end

      def inject_eip_module
        inject_into_file @form_view_path, :after => "#{js_app_name}.Views.BaseView" do
          [
            "\n",
            "@include Modules.EIP"
          ].join("\n  ")
        end if @eip_node
      end

      def inject_eip_root_node
        inject_into_file @form_view_path, :after => "@include Modules.EIP" do
          [
            "",
            "eipNodes:"
          ].join("\n    ")
        end if @eip_node
      end

      def inject_node
        inject_into_file @form_view_path, :after => "eipNodes:" do
          [
            "",
            "#{@eip_plural_name}: true"
          ].join("\n      ")
        end if @eip_node
      end

      def inject_eip_button
        inject_into_file @form_template_path, :after => "#eip-buttons.span12.well" do
          [
            "\n",
            "= link_to t(\".#{@eip_plural_name}\"), \"#\", :class => \"btn eip_#{@eip_plural_name} eip-btn\""
          ].join("          ")
        end if @eip_node
      end

      def inject_content_for_templates
        inject_into_file @form_template_path, :after => "do |f|" do
          [
            "",
            "- if form_type.eql?(\"new\")",
            "  = content_for :templates do"
          ].join("\n      ")
        end if @eip_node
      end

      def inject_script_templates
        inject_into_file @form_template_path, :after => "content_for :templates do" do
          [
            "",
            "= script_template(\"\", :id => \"eipForm#{@eip_plural_name.camelize}Template\", :partial => \"#{plural_name}/nesteds/#{@eip_plural_name}/eip_form\", :locals => {:form => f})",
            "= script_template(\"\", :id => \"eipNode#{@eip_plural_name.camelize}Template\", :partial => \"#{plural_name}/nesteds/#{@eip_plural_name}/eip_node\")",
            "= script_template(\"\", :id => \"eipList#{@eip_plural_name.camelize}Template\", :partial => \"#{plural_name}/nesteds/#{@eip_plural_name}/eip_list\")",
            ""
          ].join("\n          ")
        end if @eip_node
      end

      def create_eip_template_dir
        empty_directory File.join(backbone_tmpl_path, plural_name, "nesteds", @eip_plural_name) if @eip_node
      end

      def create_templates
        available_eip_templates.each do |view|
          template "#{view}.haml", File.join(backbone_tmpl_path, plural_name, "nesteds", @eip_plural_name, "_#{view}.html.haml")
        end if @eip_node
      end

      protected

        def available_eip_templates
          %w{eip_node eip_form eip_list}
        end

        def find_eip_node
          @eip_node = attributes.slice!(0)

          if @eip_node
            @eip_singular_name  = @eip_node.name.singularize
            @eip_plural_name    = @eip_node.name.pluralize
            @form_template_path = File.join(backbone_tmpl_path, plural_name, "_form.html.haml")

            %w{_form 00_form}.each do |form_name|
              break if @form_view_path
              form_path = File.join(backbone_path, "views", plural_name, "#{form_name}_view.js.coffee")
              @form_view_path = form_path if File.exist?(form_path)
            end
          end
        end

    end
  end
end
