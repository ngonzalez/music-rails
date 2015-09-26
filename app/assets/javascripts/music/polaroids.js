$(document).ready(function(e) {
  $.each($('.polaroid-images a'), function(i, element) {
    var i = parseInt(Math.random() * 10);
    var m = Math.random() < 0.5 ? -0.5 : 0.5;
    $(element).css('transform', 'rotate(' + i * m + 'deg)');
  });
});