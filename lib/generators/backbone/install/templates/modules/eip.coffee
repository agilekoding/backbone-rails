Modules.EIP = (options = {}) ->

  # Callbacks
  # ==========================================================
  beforeInitialize: ->
    @eipBuildFunctions()
    _.extend @events, @eipEvents()

  afterInitialize: ->
    @eipBindCallbacks()
    @eipSetDefault()

  beforeRemove: ->
    @eipUnbindCallbacks()

  instanceMethods: () ->

    options.eipNodes ||= {}

    _.extend options,

      # Events For EIP
      # ================================================================
      eipEvents: ->
        events = {
          "click .eip-btn"         : "eipPrintListBtn"
          "click .eip-node"        : "eipShowNode"
          "click .delete-eip"      : "eipDestroyNested"
          "click .eip-delete-node" : "eipDestroyNested"
        }
        _.each(@eipNodes, (node, key) ->
          events["click .add_#{key}"] = "eip_create_#{key}".toCamelize("lower")
        )
        events

      # Print Functions For EIP
      # ================================================================

      # Print List
      eipPrintList: (nodeName, eipAnimate = true) ->
        container = this.$("#eip-container")

        if eipAnimate
          $('html, body').animate({ scrollTop: container.offset().top }, 'slow')

        if nodeName?
          eipListTemplate = @eipGetListTemplate(nodeName)
          collection      = @eipGetCollection(nodeName)

          container.html eipListTemplate

          collection.each(@eipPrintNode, @)

      # Print Node And Form
      eipPrintNodeWithForm: (nested_model) ->
        @eipPrintNode nested_model, true
        @eipPrintForm nested_model

      # Print Node
      eipPrintNode: (nested_model, nodeActive = false) ->
        dom = @eipGetNodeTemplate(nested_model)

        @eipBeforeRenderNode(dom, nested_model)

        if nested_model.eip_node_dom? and nested_model.eip_node_dom.is(":visible")
          nested_model.eip_node_dom.replaceWith dom
        else
          @$("#eip-list").append dom
          nested_model.prepareToEdit()
          nested_model.unbind("change", @eipPrintNode, @)
          nested_model.bind("change", @eipPrintNode, @)

        nested_model.eip_node_dom = dom
        $(dom).data('nested_model', nested_model)

        @eipSetNodeActive dom if nodeActive

      # Print Form
      eipPrintForm: (nested_model) ->
        dom       = @eipGetFormTemplate(nested_model)
        container = @$("#eip-form")

        @eipBeforeRenderForm(dom, nested_model)

        container.html dom.backboneLink(@model)
        $('html, body').animate({ scrollTop: container.offset().top }, 'slow')

        @eipAfterRenderForm(dom, nested_model)

        nested_model.eip_form_dom = dom
        dom.find(".delete-eip").data('nested_model', nested_model)

      eipShowNode: (e) ->
        unless $(e.target).is("a.eip-delete-node")
          node = $(e.currentTarget)
          @eipSetNodeActive node
          nested_model = node.data('nested_model')
          @eipPrintForm nested_model

      eipSetNodeActive: (node) ->
        @$('.eip-node').removeClass('active')
        node.addClass('active')

      eipPrintListBtn: (e) ->
        e.preventDefault()
        link = $(e.currentTarget)

        if link.is(".info")
          @eipPrintList null # Just run the animation
        else
          nodeName = @eipGetNodeName(link)
          @eipPrintList nodeName
          @eipSetBtnListActive(link)

      # Destroy Functions For EIP
      # ================================================================
      eipDestroyNested: (e) ->
        e.preventDefault()

        dom          = $(e.currentTarget)
        model_object = dom.data('nested_model')

        if model_object is undefined or model_object is null
          model_object = dom.parents('.eip-node').data('nested_model')

        unless model_object.isNew()
          msg = $(e.currentTarget).attr("data-confirm")
          if msg? and !confirm(msg) then return false

        model_object.destroy({
          error: (model, jqXHR) =>
            data = $.parseJSON(jqXHR.responseText)
            @renderErrors( model, (data.error || data.errors) )

        })

      eipRemoveNestedFromDom: (nested_model) ->
        nested_model.eip_form_dom?.remove?()
        nested_model.eip_node_dom?.remove?()

      # Get Templates For EIP
      # ================================================================
      eipGetNodeTemplate: (nested_model) ->
        templateName = "#{nested_model.paramRoot}_template".toCamelize()

        if _.isFunction(@["eipNode#{templateName}"])
          @["eipNode#{templateName}"](nested_model.toJSON(true))
        else
          templateName = "#{nested_model.urlRoot}_template".toCamelize()
          @["eipNode#{templateName}"](nested_model.toJSON(true))

      eipGetFormTemplate: (nested_model) ->
        templateName = "#{nested_model.paramRoot}_template".toCamelize()

        if _.isFunction(@["eipForm#{templateName}"])
          @["eipForm#{templateName}"](nested_model.toJSON(true))
        else
          templateName = "#{nested_model.urlRoot}_template".toCamelize()
          @["eipForm#{templateName}"](nested_model.toJSON(true))

      eipGetListTemplate: (nodeName) ->
        templateName = "#{nodeName}_template".toCamelize()
        @["eipList#{templateName}"]()

      eipGetCollection: (nodeName) ->
        collection = @eipNodes[nodeName].collection || nodeName
        @model[collection]


      # Build Functions For EIP
      # ================================================================
      eipBuildFunctions: () ->
        _.each(@eipNodes, (node, key) =>
          templateName = "#{key}_template".toCamelize()
          functionName = "eip_create_#{key}".toCamelize("lower")

          # Templates
          @["eipNode#{templateName}"] = (data) -> $("#eipNode#{templateName}").tmpl(data)
          @["eipForm#{templateName}"] = (data) -> $("#eipForm#{templateName}").tmpl(data)
          @["eipList#{templateName}"] = (data) -> $("#eipList#{templateName}").tmpl(data)

          # Functions
          @[functionName] = (e) ->
            e.preventDefault()
            @eipGetCollection(key).add() if @eipBeforeAddNested() is true
        )

      # Bind Add Callback For Collections
      # ================================================================
      eipBindCallbacks: ->
        _.each(@eipNodes, (node, key) =>
          @eipGetCollection(key).bind("add", @eipPrintNodeWithForm, @)
          @eipGetCollection(key).bind("destroy", @eipRemoveNestedFromDom, @)
          @eipGetCollection(key).bind("error", @renderErrors, @)
        )
      eipUnbindCallbacks: ->
        _.each(@eipNodes, (node, key) =>
          @eipGetCollection(key).unbind("add", @eipPrintNodeWithForm, @)
          @eipGetCollection(key).unbind("destroy", @eipRemoveNestedFromDom, @)
          @eipGetCollection(key).unbind("error", @renderErrors, @)
        )

      # Other Functions
      # ================================================================
      eipGetNodeName: (link) ->
        name = null
        _.each(@eipNodes, (node, key) =>
          name = key if link.is(".eip_#{key}")
        )
        name

      eipSetDefault: () ->
        if @eipDefault?
          _this = @
          $("a.eip_#{@eipDefault}").livequery(() ->
            link = $(this)
            _this.eipSetBtnListActive(link)
            _this.eipPrintList(_this.eipDefault, false)
          )

      eipSetBtnListActive: (link) ->
        @$("#eip-buttons .eip-btn").removeClass("info")
        link.addClass("info")

      eipBeforeRenderForm: ->
      eipAfterRenderForm: ->

      eipBeforeRenderNode: ->

      eipBeforeAddNested: -> true


  # Class Methods
  # ================================================================

  #classMethods:

    #class_method: ->
