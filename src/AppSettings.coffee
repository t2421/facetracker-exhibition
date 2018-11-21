$ = require('jquery')
Events = require('./Events.coffee')
module.exports = 
	class AppSettings
		@DEBUG:false
		@FACEBOOK_PAGE_ID:"XXXXXXXXX"
		@FACEBOOK_PAGE_TOKEN:"XXXXXXXXX"
		@WIDTH:800
		@HEIGHT:600
		constructor:->
			@param1 = 0
			@param2 = 1
			@animate = =>
				$(document).trigger(Events.ANIMATION_START)
			@post = =>
				$(document).trigger(Events.POST_IMAGE)
			@startContents = =>
				$(document).trigger(Events.CONTENTS_START)
			@translateImg = =>
				$(document).trigger(Events.TRANSLATE_IMG)
			@maskChange = =>
				$(document).trigger(Events.MASK_CHANGE)
