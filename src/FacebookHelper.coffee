$ = require('jquery')
module.exports = 
	class FacebookHelper
		@POST_COMPLETE = "postComplete"
		constructor: (settings)->
			
		postImageByBlob: (blob,message,id,token)=>
			fd = new FormData()
			fd.append "access_token",token
			fd.append "source",blob
			fd.append "message",message
			api = "https://graph.facebook.com/#{id}/photos?access_token=#{token}"
			console.log api
			$.ajax({
				url:api,
				type:"POST",
				data:fd,
				processData:false,
				contentType:false,
				cache:false,
				success:(data)=>
					console.log "success #{data}"
					$(@).trigger(FacebookHelper.POST_COMPLETE)
					return
				error:(shr,status,data)=>
					console.log "error #{data} Status #{shr.status}"
					console.log shr
					return
				complete:()=>
					console.log "Posted"
					return
			})
			return
