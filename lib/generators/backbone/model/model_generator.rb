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

    end
  end
end
