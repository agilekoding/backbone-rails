(function($) {

  function getNestedObject(el, model){
    var nestedName = el.attr("name");
    var nesteds = nestedName.split("[")
    var nestedObject = null;

    for(var i in nesteds) nesteds[i] = nesteds[i].replace("]", "")
    var name = nesteds[nesteds.length-1];

    for (var i in nesteds) {
      var value = nesteds[i];
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

  function setSelectedValueForInput(container, el, model, name){
    var nestedObject = getNestedObject(el, model);
    var value = nestedObject.get(name)
    if ( el.is("select") )
      el.find("option[value=\""+value+"\"]").attr('selected', true);

    if ( el.is("input:radio") ){
      var radioName = el.attr("name");
      container.find("input[name=\""+radioName+"\"][value=\""+value+"\"]:radio").attr('checked', true);
    }
  }

  function setValues(el, model, name){
    var attrs = {};
    var nestedObject = getNestedObject(el, model);
    var inputValue = el.val();

    if (inputValue === "") inputValue = null;

    attrs[name] = inputValue;
    nestedObject.set(attrs);
    return true;
  }

  return $.extend($.fn, {
    backboneLink: function(model) {
      var container = $(this);
      container.find(":input").each(function() {
        var el, name, nestedName, nesteds, nestedObject;
        el           = $(this);
        nestedName   = el.attr("name");
        nesteds      = nestedName.split("[")
        nestedObject = getNestedObject(el, model);

        for(var i in nesteds) nesteds[i] = nesteds[i].replace("]", "")
        name = nesteds[nesteds.length-1];

        setSelectedValueForInput(container, el, model, name);

        nestedObject.bind("change:" + name, function() {
          return el.val(nestedObject.get(name));
        });
        return $(this).bind("change", function() {
          el = $(this);
          return setValues(el, model, name);
        });
      });
      return $(this);
    }
  });
})(jQuery);
