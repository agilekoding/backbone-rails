<%= js_app_name %>.Helpers =

  jsonData: (url, params = {}) ->
    return if !url
    responseDate = null
    $.ajax(
      url: url
      async: false
      dataType: "json"
      data: params
      beforeSend: (xhr) ->
        token = $('meta[name="csrf-token"]').attr('content')
        xhr.setRequestHeader('X-CSRF-Token', token) if token
      success: (data, textStatus, jqXHR) -> responseDate = data
    )
    responseDate

  jsonCallback: (url, callback, params = {}) ->
    $.ajax
      url: url
      dataType: "json"
      data: params
      beforeSend: (xhr) ->
        token = $('meta[name="csrf-token"]').attr('content')
        xhr.setRequestHeader('X-CSRF-Token', token) if token
      success: callback

  ajax: (options = {}) ->
    return if !options.url

    complete = options.complete
    options.complete = (jqXHR, textStatus) ->
      <%= js_app_name %>.Helpers.showSubmitted()

      complete?()

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
  renderWarning: (data, alertsContainer = "#alerts_container") ->
    $(alertsContainer).prepend( $("#backboneWarningAlert").tmpl(data) )

  renderError: (data, alertsContainer = false) ->
    $('.alert-message.error').remove()

    if alertsContainer is false then container = $(".columns form:first")
    else if _.isString alertsContainer then container = $(alertsContainer)
    else container = alertsContainer

    if container.offset()?
      container.prepend( $("#backboneErrorAlert").tmpl(data) )
      $('html, body').animate({ scrollTop: container.offset().top - 45 }, 'slow')
    else
      $("#alerts_container").prepend( $("#backboneErrorAlert").tmpl(data) )

  renderSuccess: (data, alertsContainer = "#alerts_container") ->
    $(alertsContainer).prepend( $("#backboneSuccessAlert").tmpl(data) )

  renderInfo: (data, alertsContainer = "#alerts_container") ->
    $(alertsContainer).prepend( $("#backboneInfoAlert").tmpl(data) )

  renderProgress: (schedule_id, callback) ->
    if schedule_id?
      $(".alert-message").remove()
      progress = $("#progress_bar")
      schedule = null

      progress.progressbar
        value: 0
        complete: ->
          clearInterval interval
          callback?(schedule)

      interval = setInterval ->
        $.getJSON "schedules/#{schedule_id}", (data) ->
          schedule = data
          count    = (schedule.progress * 100) / schedule.total
          progress.progressbar "option", "value", count
      , 1500

  showSubmitted: ->
    $('.submitted').show()
    $('.submitted').removeClass('submitted')


