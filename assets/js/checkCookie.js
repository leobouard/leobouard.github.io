function checkCookie() {
    if (document.cookie.indexOf("cookie=true") !== -1) {
      var cookieInfo = document.getElementById("cookieInfo");
      cookieInfo.style.display = "none";
    }
};

window.onload = checkCookie();