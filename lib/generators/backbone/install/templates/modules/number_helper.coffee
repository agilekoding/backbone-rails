Modules.NumberHelper =

  instanceMethods:

    numberToCurrency: (number) ->
      $.formatNumber(
        parseFloat(number, 10)
        format: "$ #,###.00", locale:"us"
      )
