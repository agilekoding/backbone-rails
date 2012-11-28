class <%= controller_class_name %>Controller < InheritedResources::Base
  include BackboneResponses

  respond_to :json
end

