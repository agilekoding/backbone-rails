#= require_self
#= require ./helpers
#= require_tree ./modules
#= require ./models/base_model
#= require ./models/base_collection
#= require_tree ./models
#= require ./views/base_view
#= require_tree ./views
#= require_tree ./routers

window.<%= js_app_name %> =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}

window.Modules = {}
