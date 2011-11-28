String.prototype.toUnderscore = () ->
  @replace( /([A-Z])/g, ($1) -> "_"+$1.toLowerCase() ).
  replace( /^_/, '' )

String.prototype.toCamelize = (type) ->
  value = @replace(/(_| )/g, "-").
  replace(/(\-[a-z])/g, ($1) -> $1.toUpperCase().replace('-','') ).
  replace( /^([a-z])/g, ($1) -> $1.toUpperCase() )

  switch type
    when "lower" then value = value.replace( /^([A-Z])/g, ($1) -> $1.toLowerCase() )
    else value

  value
