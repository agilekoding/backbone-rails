<%= js_app_name %>.Helpers =

  jsonData: (url, params = {}) ->
    return if !url
    responseDate = null
    $.ajax(
      url: url
      async: false
      dataType: "json"
      data: params
      success: (data, textStatus, jqXHR) -> responseDate = data
    )
    responseDate

  jsonCallback: (url, callback, params = {}) ->
    $.getJSON(url, params, (data) -> callback?(data) )

  ajax: (options = {}) ->
    return if !options.url

    settings =
      type: "GET"
      data: {}
      dataType: "json"
      beforeSend: (xhr) ->
        token = $('meta[name="csrf-token"]').attr('content')
        xhr.setRequestHeader('X-CSRF-Token', token) if token

    _.extend settings, options

    $.ajax settings

  # Renders For Alers Messages
  renderWarning: (data) ->
    $("#alerts_container").html( $("#backboneWarningAlert").tmpl(data) )

  renderError: (data) ->
    $('.alert-message').remove()
    container = $(".columns form:first")

    if container.offset()?
      container.prepend( $("#backboneErrorAlert").tmpl(data) )
      $('html, body').animate({ scrollTop: container.offset().top - 45 }, 'slow')
    else
      $("#alerts_container").html( $("#backboneErrorAlert").tmpl(data) )

  renderSuccess: (data) ->
    $("#alerts_container").html( $("#backboneSuccessAlert").tmpl(data) )

  renderInfo: (data) ->
    $("#alerts_container").html( $("#backboneInfoAlert").tmpl(data) )
