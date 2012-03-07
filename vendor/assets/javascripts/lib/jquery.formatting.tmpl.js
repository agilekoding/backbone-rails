function tmplDatetimeParse(datetime){
  if (datetime == null) return "";

  if (datetime.split("T").length === 1)
    datetime = datetime + "T00:00:00"

  var date   = datetime.split("T")[0];
  var d      = date.split("-");

  var time   = datetime.split("T")[1].split("-")[0];
  var t      = time.split(":");

  var myDate = new Date(d[0], (parseInt(d[1], 10) - 1), d[2], t[0], t[1], t[2]);

  return $.datepicker.formatDate("dd-M-yy", myDate)
}

$.extend(jQuery.tmpl.tag, {
    'format_currency': {
        open: '_.push($.formatNumber(parseFloat($1), {format:"$ #,###.00", locale:"us"}));'
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
        open: '_.push(tmplDatetimeParse($1));'
    }

});
