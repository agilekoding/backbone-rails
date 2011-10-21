class <%= plural_name.camelize %>Controller < InheritedResources::Base
  include BackboneResponses

  respond_to :json
end

