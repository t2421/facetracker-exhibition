$ = require('jquery')
TweenMax = require('TweenMax')
View = require('./View.coffee')
Events = require('../Events.coffee')
module.exports = 
	class SendingView extends View
		constructor:->
			html=
			"""
			<div id='sendingView'>
				<p id="complete"><img src="./img/complete.png"></p>
				<p id="uploading"><img src="./img/uploading.png"></p>
				<div id="bar"></div>
			</div>
			"""

			@dom = $(html)
			@bar = $('#bar',@dom)
			@complete = $('#complete',@dom)
			@uploading = $('#uploading',@dom)
		addProcessingEffect:=>
			windowSize = $(window).width()
			@complete.css "opacity",0
			@uploading.css "opacity",1

			uploadingFunc1 = ()=>
				TweenMax.to(@uploading,0.5,{opacity:1,onComplete:=>
					uploadingFunc2()
				})
				return
			uploadingFunc2 = ()=>
				TweenMax.to(@uploading,0.5,{opacity:0,onComplete:=>
					uploadingFunc1()
				})
				return
			
			uploadingFunc1()
			return
		addProcessCompleteEffect:=>
			windowSize = $(window).width()
			

			setTimeout =>
				TweenMax.killTweensOf(@uploading)
				@uploading.css "opacity",0
			,2000
			
			TweenMax.to(@complete,0.03,{opacity:1,delay:2,repeat:30,yoyo:true,onComplete:=>
				#TweenMax.to(@bar,0.1,{height:0,delay:0.2})
				#TweenMax.to(@dom,0.5,{opacity:0,delay:0.4,onComplete:=>
				#	@complete.css('opacity',0)
				#	$(document).trigger(Events.LOAD_PROCESS_COMPLETE)
				#})
				$(document).trigger(Events.LOAD_PROCESS_COMPLETE)
			})
			return
		fadeIn:()=>
			@dom.css 'display','block'
			@dom.css 'opacity','0'
			TweenMax.to(@dom,0.1,{scaleX:0,scaleY:0,rotationZ:-45})
			TweenMax.to(@dom,0.3,{opacity:0.6,scaleX:1,scaleY:1,rotationZ:0,ease:Back.easeOut})
			return
		remove:=>
			console.log "remove"
			TweenMax.to(@dom,0.3,{opacity:0,scaleX:0,scaleY:0,rotationZ:-45,ease:Back.easeIn,onComplete:=>
				#$(@dom).remove()
				
			})

