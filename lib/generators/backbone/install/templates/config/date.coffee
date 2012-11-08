Date.prototype.getWeek = ->
  onejan = new Date(@getFullYear(),0,1)
  Math.ceil((((this - onejan) / 86400000) + onejan.getDay()+1)/7)
