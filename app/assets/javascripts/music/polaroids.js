function getRandomInt(min, max) {
  // https://developer.mozilla.org/en/Core_JavaScript_1.5_Reference/Global_Objects/Math/random
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
function observe_polaroids() {
  $.each($(".polaroid-images a"), function(i, element) {
    setTimeout(function() {
      $(element).addClass(["rotate-2", "rotate-m2", "rotate-5", "rotate-m5", "rotate-2"][getRandomInt(0,4)]);
    }, 500);
  });
}
