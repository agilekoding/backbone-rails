module Backbone
  module Generators
    module ResourceHelpers

      def backbone_path
        "app/assets/javascripts/backbone"
      end

      def backbone_tmpl_path
        "app/views"
      end

      def controllers_path
        "app/controllers"
      end

      def model_namespace
        [js_app_name, "Models", class_name].join(".")
      end

      def classify_model_name
        singular_name.classify
      end

      def human_attribute_translate(name)
        "#{classify_model_name}.human_attribute_name(:#{name})"
      end

      def singular_model_name
        uncapitalize singular_name.camelize
      end

      def plural_model_name
        uncapitalize(plural_name.camelize)
      end

      def collection_namespace
        [js_app_name, "Collections", plural_name.camelize].join(".")
      end

      def view_namespace
        [js_app_name, "Views", plural_name.camelize].join(".")
      end

      def router_namespace
        [js_app_name, "Routers", plural_name.camelize].join(".")
      end

      def jst(action)
        "backbone/templates/#{plural_name}/#{action}"
      end

      def tmpl(action)
        "backbone_templates_#{plural_name}_#{action}".camelize(:lower)
      end

      def js_app_name
        application_name.camelize
      end

      def application_name
        if defined?(Rails) && Rails.application
          Rails.application.class.name.split('::').first
        else
          "application"
        end
      end

      def uncapitalize(str)
          str[0, 1].downcase + str[1..-1]
      end

    end
  end
end
