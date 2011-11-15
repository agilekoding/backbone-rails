(function($) {

  function getNestedName(el){
    var nestedName = el.attr("name").replace("[]", "");
    var nesteds = nestedName.split("[");

    for(var i in nesteds) nesteds[i] = nesteds[i].replace("]", "")
    return nesteds[nesteds.length-1];
  }

  function getNestedObject(el, model){
    var nestedName = el.attr("name");
    var nesteds = nestedName.split("[")
    var nestedObject = null;

    for (var i in nesteds) {
      var value = nesteds[i].replace("]", "");
      nestedObject = nestedObject == null ? model : nestedObject;
      if ( /^.+_attributes$/.test(value) ) {
        value = value.replace("_attributes", "");
        nestedObject = nestedObject[value];
      } else if ( /^backboneCid_.+$/.test(value) ) {
        value = value.replace("backboneCid_", "");
        nestedObject = nestedObject.getByCid(value);
      }
    }
    return nestedObject;
  }

  function setSelectedValueForInput(container, el, nestedObject){
    var name = getNestedName(el);
    var value = nestedObject.get(name)

    if ( el.is("input:text") )
      el.val(value)

    if ( el.is("select") )
      el.find("option[value=\""+value+"\"]").attr('selected', true);

    if ( el.is("input:radio") ){
      var radioName = el.attr("name");
      container.find("input[name=\""+radioName+"\"][value=\""+value+"\"]:radio").attr('checked', true);
    }

    if ( el.is("input:checkbox") ) {
      // HABTM
      if ( /_ids$/.test(name) ) {
        var list = (value === null || value === undefined) ? [] : value;
        var checkboxValue = parseInt(el.val(), 10);
        if ( _.include(list, checkboxValue) )
          el.attr("checked", true);
      } else {
        var inputValue = _.include([true, "true", 1, "1"], el.val());
        var booleanValue = _.include([true, "true", 1, "1"], value);
        var shouldMarked = inputValue === booleanValue;
        el.attr("checked", shouldMarked)
      }
    }
  }

  function setValues(container, el, nestedObject){
    var attrs = {};
    var name = getNestedName(el);
    var inputValue = el.val();

    if ( el.is("input:checkbox") ) {
      // HABTM
      if ( /_ids$/.test(name) ) {
        var checkeds = container.find("input[name$=\"_ids][]\"]:checkbox:checked");
        inputValue = [];
        for(var i = 0, l = checkeds.length; i < l; i++){
          var checkbox = $(checkeds[i]);
          inputValue.push(checkbox.val());
        }
      } else {
        if ( el.is(":checked") )
          inputValue = el.val();
        else {
          var checkboxName = el.attr("name");
          inputValue = el.parent().find("input[type=\"hidden\"][name=\""+checkboxName+"\"]").val();
        }
      }
    }

    if (inputValue === "") inputValue = null;

    attrs[name] = inputValue;
    nestedObject.set(attrs);
    return true;
  }

  function bindChangeEvents(container, el, nestedObject){
    var name = getNestedName(el);
    nestedObject.bind("change:" + name, function() {
      return setSelectedValueForInput(container, el, nestedObject);
    });
  }

  return $.extend($.fn, {
    backboneLink: function(model) {
      var container = $(this);
      container.find(":input").each(function() {
        var el, nestedObject;
        el           = $(this);
        nestedObject = getNestedObject(el, model);

        setSelectedValueForInput(container, el, nestedObject);
        bindChangeEvents(container, el, nestedObject);

        return el.bind("change", function() {
          return setValues(container, el, nestedObject);
        });

      });
      return container;
    }
  });
})(jQuery);
