class <%= model_namespace %> extends <%= js_app_name %>.Models.BaseModel
  paramRoot: '<%= singular_name %>'
  collectionRoute: '<%= plural_name %>'

  defaults:
<% attributes.each do |attribute| -%>
    <%= attribute.name %>: null
<% end -%>

  validate: (attrs) ->
    return @validates(attrs, {
      # example: <field_name>: "presence"
    })

<%= model_namespace %>.paramRoot = '<%= singular_name %>'
<%= model_namespace %>.collectionRoute = '<%= plural_name %>'

class <%= collection_namespace %>Collection extends <%= js_app_name %>.Collections.BaseCollection
  model: <%= model_namespace %>
  url: '<%= route_url %>'

