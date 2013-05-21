(function(){

  window.TmplCustomFormats = {}
  var parseDateString;

  $.extend(jQuery.tmpl.tag, {
      'format_currency': {
          open: '_.push($.formatNumber(parseFloat($1), {format:"$#,###.00", locale:"us"}));'
      },

      'format_currency_without_space': {
          open: '_.push($.formatNumber(parseFloat($1), {format:"$#,###.00", locale:"us"}));'
      },

      'format_currency_without_decimals': {
        open: '_.push($.formatNumber(parseFloat($1), {format:"$ #,###", locale:"us"}));'
      },

      'format_number': {
          open: '_.push($.formatNumber(parseInt($1), {format:"#,###", locale:"us"}));'
      },

      'format_date': {
          open: '_.push(TmplCustomFormats.format_date($1));'
      },

      'format_datetime': {
          open: '_.push(TmplCustomFormats.format_datetime($1));'
      },

      't': {
          open: '_.push(TmplCustomFormats.t($1));'
      },

      'format_boolean': {
          open: '_.push(TmplCustomFormats.format_boolean($1));'
      },

      'format_text_area': {
          open: '_.push(TmplCustomFormats.format_text_area($1));'
      }

  });

  // TmplCustomFormats Format Functions
  // =================================================================

  TmplCustomFormats.format_date = function(datetime){
    if (datetime == null) return "";

    if (datetime.split(/[T|t]/).length === 1)
      datetime = datetime + "T00:00:00"

    var date   = datetime.split(/[T|t]/)[0];
    var d      = parseDateString(date).split(/-|\//);

    var time   = datetime.split(/[T|t]/)[1].split("-")[0];
    var t      = time.split(":");

    var myDate = new Date(d[0], (parseInt(d[1], 10) - 1), d[2], t[0], t[1], t[2]);

    return $.datepicker.formatDate("dd-M-yy", myDate)
  }

  TmplCustomFormats.format_datetime = function(datetime){
    if (datetime == null) return "";

    if (datetime.split(/[T|t]/).length === 1)
      datetime = datetime + "T00:00:00"

    var date = TmplCustomFormats.format_date(datetime);
    var time = datetime.split(/[T|t]/)[1].split("-")[0];

    return date + " " + time
  }

  TmplCustomFormats.t = function(value){
    if (_.isArray(value)) value = value.join(".");
    return Modules.I18n.t(value);
  }

  TmplCustomFormats.format_boolean = function(value){
    value = value == true;
    return Modules.I18n.t("helpers.booleans." + value);
  }

  TmplCustomFormats.format_text_area = function(value){
    if (value == null) value = "";
    return value.replace(/\n/g, "<br />");
  }


  // TmplCustomFormats Format Helpers
  // =================================================================

  parseDateString = function(date){
    // yyyy/mm/dd
    if (/^(19|20)\d\d[- \/.](0[1-9]|1[012])[- \/.](0[1-9]|[12][0-9]|3[01])$/.test(date)) return date;

    var dateArray = date.split(/-|\//);

    if (/^(0[1-9]|[12][0-9]|3[01])[- \/.](0[1-9]|1[012])[- \/.](19|20)\d\d$/.test(date)){
      date = dateArray[2] + "/" + dateArray[1] + "/" + dateArray[0];
    } // dd/mm/yyyy

    else if (/^(0[1-9]|1[012])[- \/.](0[1-9]|[12][0-9]|3[01])[- \/.](19|20)\d\d$/.test(date)){
      date = dateArray[2] + "/" + dateArray[0] + "/" + dateArray[1];
    } // mm/dd/yyyy

    else if (/^(19|20)\d\d[- \/.](0[1-9]|[12][0-9]|3[01])[- \/.](0[1-9]|1[012])$/.test(date)){
      date = dateArray[0] + "/" + dateArray[2] + "/" + dateArray[1];
    } // yyyy/dd/mm

    return date; // return format: yyyy/mm/dd
  }

}).call(this);
