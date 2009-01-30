$(document).ready(function() {
  $('ul.status li:first').addClass('selected');

  $(this).everyTime(10000, function() {
    prev = $('li.selected');
    next = prev.next('li:first');

    if (next.length == 0) {
      next = $('ul.status li:first');
    }
    
    prev.hide().removeClass('selected');
    next.show().addClass('selected');
  });
});
