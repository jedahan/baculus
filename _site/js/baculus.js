$(document).ready(function () {
  if (window.location.host.includes('mesh')) {
    $("a.logo-link").href = "http://baculus.mesh/portal"
  }

	$("#nav-mobile").html($("#nav-main").html())
	
	$("#nav-trigger span").click(function () {
	  const nav = $("nav#nav-mobile ul")
 		  .toggleClass("expanded")
 		  .toggleClass("mobile")
 		
	  if (nav.hasClass('expanded')) {
	    nav.slideDown(250)
    } else {
	    nav.slideUp(250)
	  }
	})
});
