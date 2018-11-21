$ = require('jquery')
TweenMax = require('TweenMax')
View = require('./View.coffee')
Events = require('../Events.coffee')
module.exports = 
	class ShotView extends View
		constructor:->
			html=
			"""
			<div id='shotView'>
			</div>
			"""
			@dom = $(html)
		addShotEffect:=>
			@dom.css({
				opacity:0,
				display:"block"
			})

			TweenMax.to(@dom,0.07,{opacity:1,onComplete:=>
				$(document).trigger(Events.TRANSLATE_IMG)
				return
			})
			return
		removeShotEffect:=>
			TweenMax.to(@dom,0.9,{opacity:0,onComplete:=>
				@dom.css 'display','none'
				$(document).trigger(Events.SHOT_COMPLETE)
				return
			})
			return

