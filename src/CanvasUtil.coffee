module.exports = 
	class CanvasUtil
		constructor: (canvas)->
			@canvas = canvas
		getImage: =>
			data_src = @canvas.toDataURL("image/png")
			imageObj = new Image()
			imageObj.src = data_src
			return imageObj
		getBlob: =>
			data_src = @canvas.toDataURL("image/png")
			return dataURItoBlob.call(@,data_src)
		dataURItoBlob = (dataURI)=>
			byteString = atob(dataURI.split(',')[1])
			ab = new ArrayBuffer(byteString.length)
			ia = new Uint8Array(ab)

			i = 0
			len = byteString.length
			while i<len
				ia[i] = byteString.charCodeAt(i)
				i++
			blob = new Blob([ab],{
				type:'image/png'	
			})
			return blob