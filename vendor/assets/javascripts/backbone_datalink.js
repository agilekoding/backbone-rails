(function($) {

  function setValues(el, model){
    var attrs = {};
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
        nestedObject = nestedObject.getByCid(value)
      }
    }
    attrs[name] = el.val();
    nestedObject.set(attrs);
    return true;
  }

  return $.extend($.fn, {
    backboneLink: function(model) {
      $(this).find(":input").each(function() {
        var el, name;
        el = $(this);
        name = el.attr("name");
        model.bind("change:" + name, function() {
          return el.val(model.get(name));
        });
        return $(this).bind("change", function() {
          el = $(this);
          return setValues(el, model);
        });
      });
      return $(this);
    }
  });
})(jQuery);
