window.onload = function() {
    if (document.cookie.indexOf("cookieOK=true") !== -1) {
      var cookieInfo = document.getElementById("cookieInfo");
      cookieInfo.style.display = "none";
    }
};