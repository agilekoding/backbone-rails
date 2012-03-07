Modules.Pagination =

  instanceMethods:

    pagination: (e, collection) ->
      e.preventDefault()
      link      = $(e.currentTarget)
      li        = link.closest("li")
      container = link.closest("#pagination-container")

      unless li.is(".active, .prev.disabled, .next.disabled")
        unless container.attr("data-waiting")
          container.attr("data-waiting", true)
          href = link.attr("href")
          <%= js_app_name %>.Helpers.jsonCallback(href, (data) ->
            collection.reset data
            container.removeAttr("data-waiting")
          )

    renderPagination: (collection) ->
      # Clear Pagination Container
      container = "#pagination-container"
      @$(container).html ""

      if collection.pagination? and !collection.isEmpty()
        pagination = _.clone(collection.pagination || {})

        if pagination.total_pages > 1
          pagination.resources_path = pagination.path || collection.url
          pagination.params         = $.param(pagination.params) unless (_.isEmpty pagination.params)
          pagination.pages          = []

          if (pagination.current_page > 1)
            prevNumber               = (pagination.current_page - 1)
            pagination.paginatePrev  = "#{pagination.resources_path}?page=#{prevNumber}"
            pagination.paginatePrev += "&#{pagination.params}" unless (_.isEmpty pagination.params)

          if (pagination.current_page < pagination.total_pages)
            nextNumber               = (pagination.current_page + 1)
            pagination.paginateNext  = "#{pagination.resources_path}?page=#{nextNumber}"
            pagination.paginateNext += "&#{pagination.params}" unless (_.isEmpty pagination.params)

          # builder pages
          for number in [1..pagination.total_pages]
            page         = {}
            page.liKlass = "active" if pagination.current_page is number
            page.text    = number
            page.path    = "#{pagination.resources_path}?page=#{number}"
            page.path   += "&#{pagination.params}" unless (_.isEmpty pagination.params)
            pagination.pages.push(page)

          @$(container).html $("#backboneTemplatesPagination").tmpl(pagination)
