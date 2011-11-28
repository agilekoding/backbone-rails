#= require_self
#= require_tree ./config
#= require_tree ./modules
#= require ./helpers
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
  Locales: {}
  Config:
    default_locale:"es-MX"
    flashes: ["warning", "error", "success", "info"]

window.Modules = {}
