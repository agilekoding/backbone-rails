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

    if ( el.is("select") ) {
      // SELECT MULTIPLE
      if ( _.isArray(value) ){
        _.each(value, function(v){
          el.find("option[value=\""+v+"\"]").attr('selected', true);
        });
      } else {
        el.find("option[selected]").attr('selected', false);
        el.find("option[value=\""+value+"\"]").attr('selected', true);
      }
    }

    if ( el.is("input:radio") ){
      var radioName = el.attr("name");
      container.find("input[name=\""+radioName+"\"][value=\""+value+"\"]:radio").attr('checked', true);
    }

    if ( el.is("input:checkbox") ) {
      // HABTM
      if ( /_ids$/.test(name) ) {
        var list = (value === null || value === undefined) ? [] : value;
        var checkboxValue = parseInt(el.val(), 10);

        for(var i = 0, l = list.length; i < l; i++) { list[i] = parseInt(list[i], 10); }
        if ( _.include(list, checkboxValue) )
          el.attr("checked", true);
      } else {
        var booleanValues = [true, "true", 1, "1"];
        var inputValue = _.include(booleanValues, el.val());
        var booleanValue = _.include(booleanValues, value);
        var shouldMarked = false;
        if (inputValue === true && booleanValue === true) shouldMarked = true;
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
        var checkeds = container.find("input[name$=\"" + name + "][]\"]:checkbox:checked");
        inputValue = [];
        for(var i = 0, l = checkeds.length; i < l; i++){
          var checkboxValue = parseInt($(checkeds[i]).val(), 10);
          inputValue.push(checkboxValue);
        }
      } else {
        if ( el.is(":checked") ) inputValue = true;
        else inputValue = false;
      }
    }

    //if (inputValue === "") inputValue = null;

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
      container.find(":input:not(:checkbox.children_checkbox)").each(function() {
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
