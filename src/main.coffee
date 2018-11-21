App = require('./app.coffee')
$ = require("jquery")

$.event.add window,"load",=>
	$(document).click =>
		console.log "fullscreen"
		requestFullscreen(document.getElementById("content"))
	new App()