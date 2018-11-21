$ = require('jquery')
TweenMax = require('TweenMax')
module.exports = 
	class View
		constructor:->
			html=
			"""
			<div class='view'>
				<p>please override this tag</p>
			</div>
			"""
			@dom = $(html)
		appendTo: (container)=>
			$(container).append @dom
		hide:(bool)=>
			if bool
				@dom.css 'display','none'
			else
				@dom.css 'display','block'
			return
		remove: =>
			$(@dom).remove()
			return
		fadeIn:()=>
			@dom.css 'display','block'
			@dom.css 'opacity','0'
			TweenMax.to(@dom,0.3,{opacity:1})
