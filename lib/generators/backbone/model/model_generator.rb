require 'generators/backbone/resource_helpers'

module Backbone
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      include Backbone::Generators::ResourceHelpers

      source_root File.expand_path("../templates", __FILE__)
      desc "This generator creates a backbone model and rails model with migration"

      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      def create_backbone_model
        template "model.coffee", "#{backbone_path}/models/#{file_name}.js.coffee"
      end

      def create_rails_model
        attrs = attributes.collect{|a| "#{a.name}:#{a.type}" }.join(" ")
        generate "model #{name} #{attrs}"
      end

      def create_api_model
        template "api_model.rb", "app/representations/api_v1/#{file_name}.rb"
      end

      def inject_in_rails_model
        inject_into_file "app/models/#{file_name}.rb", :before => "end" do
          [
            "",
            "  acts_as_api",
            "  include ApiV1::#{class_name}",
            "\n"
          ].join("\n")
        end
      end

    end
  end
end
