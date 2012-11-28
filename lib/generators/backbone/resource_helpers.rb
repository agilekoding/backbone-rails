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

      def controller_class_path
        class_path
      end

      def controller_file_name
        @controller_file_name ||= file_name.pluralize
      end

      def controller_class_name
        (controller_class_path + [controller_file_name]).map!{ |m| m.camelize }.join('::')
      end

      def controller_path
        (controller_class_path + [controller_file_name]).map!{ |m| m.camelize }.join('/')
      end

      def model_namespace
        [js_app_name, "Models", backbone_class_name].join(".")
      end

      def backbone_class_name
        #singular_model_name.camelize
        class_name.gsub("::", ".")
      end

      def classify_model_name
        #singular_model_name.camelize
        class_name
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
        [js_app_name, "Collections", (class_path + [plural_name]).map!{ |m| m.camelize}.join(".")].join(".")
      end

      def view_namespace
        [js_app_name, "Views", (class_path + [plural_name]).collect(&:camelize)].join(".")
      end

      def router_namespace
        [js_app_name, "Routers", (class_path + [plural_name]).collect(&:camelize)].join(".")
      end

      def jst(action)
        "backbone/templates/#{plural_name}/#{action}"
      end

      def tmpl(action)
        "backbone_templates_#{controller_path.tr('/', '_')}_#{action}".camelize(:lower)
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
