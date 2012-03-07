// FadeOut Notices
// $('div.alert-message').fadeOutNotices();

(function($) {
  $.fn.fadeOutNotices = function(options){
	  // default configuration properties
	  var defaults = { time : 15000 };
	  var options = $.extend(defaults, options);

	  this.each(function() {
	    var obj = $(this);
	    setTimeout(function() {
		    obj.fadeOut('slow', function(){
		      obj.remove();
		    });
	    }, options.time);
	  });
  };
})(jQuery);
