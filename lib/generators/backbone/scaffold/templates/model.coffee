class <%= model_namespace %> extends <%= js_app_name %>.Models.BaseModel
  paramRoot: '<%= singular_name %>'

  defaults:
<% attributes.each do |attribute| -%>
    <%= attribute.name %>: null
<% end -%>

  validate: (attrs) ->
    return @validates(attrs, {
      # example: <field_name>: "presence"
    })


class <%= collection_namespace %>Collection extends Backbone.Collection
  model: <%= model_namespace %>
  url: '<%= route_url %>'
