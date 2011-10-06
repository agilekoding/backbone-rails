#= require_self
#= require ./helpers
#= require ./models/base_model
#= require_tree ./models
#= require ./views/base_view
#= require_tree ./views
#= require_tree ./routers

window.<%= js_app_name %> =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
