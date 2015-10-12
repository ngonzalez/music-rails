function observe_polaroids() {
  function getRandomInt(min, max) {
    // https://developer.mozilla.org/en/Core_JavaScript_1.5_Reference/Global_Objects/Math/random
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }
  $.each($(".polaroid-images a"), function(i, element) {
    var css_classes = ["rotate-2", "rotate-m2", "rotate-5", "rotate-m5", "rotate-2", "rotate-m2"];
    $(element).addClass(css_classes[getRandomInt(0, css_classes.length - 1)]);
  });
}