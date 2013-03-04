Modules.Pagination =

  instanceMethods:

    pagination: (e, collection) ->
      e.preventDefault()
      link      = $(e.currentTarget)
      li        = link.closest("li")
      container = link.closest("#pagination-container")

      unless li.is(".active, .prev.disabled, .next.disabled, .separator.disabled")
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
          number  = 1                       # Initial page
          pages   = pagination.total_pages  # Total number of pages
          current = pagination.current_page # The current page we are on
          before  = 3                       # Number of links to display before current
          after   = 3                       # Same as above but after
          start   = (current - before)      # The number of the first link
          end     = (current + after)       # Number of the end link

          pagination.resources_path = pagination.path || collection.url
          pagination.params         = $.param(pagination.params) unless (_.isEmpty pagination.params)
          pagination.pages          = []

          if (current > 1)
            prevNumber               = (current - 1)
            pagination.paginatePrev  = "#{pagination.resources_path}?page=#{prevNumber}"
            pagination.paginatePrev += "&#{pagination.params}" unless (_.isEmpty pagination.params)

          if (current < pages)
            nextNumber               = (current + 1)
            pagination.paginateNext  = "#{pagination.resources_path}?page=#{nextNumber}"
            pagination.paginateNext += "&#{pagination.params}" unless (_.isEmpty pagination.params)

          # builder pages
          while number <= pages

            if(start > number && number == (before + 1))
              number = start
              pagination.pages.push(builderPath("...", "#", false, "separator disabled"))

            if((pages - after) > number && number == (current + after + 1))
              number = (pages - after)
              pagination.pages.push(builderPath("...", "#", false, "separator disabled"))

            path  = "#{pagination.resources_path}?page=#{number}"
            path += "&#{pagination.params}" unless (_.isEmpty pagination.params)

            if(number == current) then page = builderPath(number, path, true)
            else page = builderPath(number, path)

            pagination.pages.push(page)

            number += 1

          @$(container).html $("#backboneTemplatesPagination").tmpl(pagination)

builderPath = (text, path, current = false, liKlass = "") ->
  page = {}
  page.liKlass = liKlass
  page.liKlass += " active" if current
  page.text    = text
  page.path    = path
  page
