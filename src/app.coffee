#@see http://blog.livedoor.jp/aki_mana/archives/6696749.html toDataUrlの実装について

Stats = require('Stats')
dat = require('datgui')
$ = require('jquery')
React = require('react')
AppSettings = require('./AppSettings.coffee')
FacebookHelper = require('./FacebookHelper.coffee')
CanvasUtil = require("./CanvasUtil.coffee")
Events = require('./Events.coffee')
SendingView = require('./view/SendingView.coffee')
ShotView = require('./view/ShotView.coffee')
HomographyObject = require './HomographyObject.coffee'
module.exports =  
  class App
    constructor: ->
      @audioList = {
        "shot": new Audio('./sound/se.mp3')
      }
      #requestAnimationFrameの初期化
      @requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame
      @cancelAnimationFrame = window.cancelAnimationFrame || window.mozCancelAnimationFrame || window.webkitCancelAnimationFrame || window.msCancelAnimationFrame
      window.requestAnimationFrame = @requestAnimationFrame
      window.cancelAnimationFrame = @cancelAnimationFrame
      @start = window.mozAnimationStartTime
      @animationID;

      #シャッターの状態を管理 true　以外の時はシャッターを切れないようにする
      @isActive = true

      @maskID = 0
      @numMask = $('.masks').length;
      
      @homoObj = new HomographyObject()
      @container = document.getElementById('container')
      @canvas = document.getElementById('webgl')
      @canvasUtil = new CanvasUtil(@canvas)
      @settings = new AppSettings()
      @facebookHelper = new FacebookHelper()

      @view = new SendingView()
      @view.appendTo @container
      @shotView = new ShotView()
      @shotView.appendTo @container
      @changeFrame()
      startVideo()
      #uploading エフェクトを開始するよ
      $(document).bind Events.POST_IMAGE,(e)=>
        #console.log "post start"
        #@facebookHelper.postImageByBlob blobObj,AppSettings.FACEBOOK_PAGE_ID,AppSettings.FACEBOOK_PAGE_TOKEN
        @view.hide(false)
        setTimeout =>
          @view.fadeIn()
          @view.addProcessingEffect()
        ,1000
        #@view.addProcessCompleteEffect()
        return

      #KeyboradEventで操作するよ
      document.addEventListener "keydown",(e)=>
        if e.key is "Enter"
          #console.log "shot!!!!"
          if @isActive
            @audioList.shot.play()
            $(document).trigger(Events.SHOT)
        else
          if e.key is "ArrowRight" or e.key is "Right"
            if @isActive
              $(document).trigger(Events.MASK_CHANGE,["next"])
          else
            if e.key is "ArrowLeft" or e.key is "Left"
              if @isActive
                $(document).trigger(Events.MASK_CHANGE,["prev"])
        return

      #シャッターが押された！
      $(document).bind Events.SHOT,(e)=>
        @isActive=false
        @shotView.addShotEffect()
        stopDraw()
        return
      #シャッターが押されて画面が白くなった時に、Facebookへ画像を送るための準備をして、それが完了した時に呼び出されるよ
      $(document).bind Events.POST_IMAGE_READY,(e)=>
        @shotView.removeShotEffect()
        if window.isUseFacebook
          @facebookHelper.postImageByBlob @blobObj,window.facebookMessage,AppSettings.FACEBOOK_PAGE_ID,AppSettings.FACEBOOK_PAGE_TOKEN  
        else
          @fakeFacebookSend()
        return
      #シャッターのエフェクトが完全に終了したよ
      $(document).bind Events.SHOT_COMPLETE,(e)=>
        $(document).trigger(Events.POST_IMAGE)
        return

      #Facebookの投稿が完了したよ
      $(@facebookHelper).bind FacebookHelper.POST_COMPLETE,(e)=>
        #console.log "post complete"
        @view.addProcessCompleteEffect()
        
        return
      #uploadingが終わったよ
      $(document).bind Events.LOAD_PROCESS_COMPLETE,(e)=>
        #console.log "processComplete"
        @homoObj.init "#shotImg img"
        @homoObj.change "shrink",0.05,0.79
        @animationID = requestAnimationFrame @update
        
        return
      #コンテンツの準備ができたらスタートするよ
      $(document).bind Events.CONTENTS_START,(e)=>
        startVideo()
        return
      #キャンバスをFacebookに送信出来る形式に変換するよ
      $(document).bind Events.TRANSLATE_IMG,(e)=>
        #console.log "translate"
        @canvasToImg()
        return
      #マスクを切り替える
      $(document).bind Events.MASK_CHANGE,(e,direction)=>
        #console.log "maskChange"

        @changeMask(direction)
        return

      #homography変換アニメーションが終わったら、いろいろ削除するよ
      $(@homoObj).bind HomographyObject.ANIMATION_COMPLETE,(e)=>
        #console.log "recieve Homo Event"
        $('#shotImg img').remove()
        @view.remove()
        cancelAnimationFrame(@animationID)
        @isActive = true
        setTimeout =>
          startDraw()
        ,600
        
        return

      if AppSettings.DEBUG
        @initDebug()

    fakeFacebookSend:()=>
      setTimeout =>
        $(@facebookHelper).trigger FacebookHelper.POST_COMPLETE
      ,2000
      return
    #videoタグ canvasタグ imgタグのFrameをがっちゃんこして、画像にするよ
    canvasToImg:()=>
      tmpCanvas = document.createElement("canvas")
      tmpCanvas.width = AppSettings.WIDTH
      tmpCanvas.height = AppSettings.HEIGHT
      facebookCanvasUtil = new CanvasUtil(tmpCanvas)
      
      webglCanvas = document.getElementById('webgl')
      data_src = webglCanvas.toDataURL "image/png"
      #console.log data_src
      tmpImg = new Image()
      tmpImg.src = data_src
      frameStr = "frame"+@maskID
      #console.log frameStr
      frameImg = document.getElementById(frameStr)

      #tmpImgのonload後に画像化しないとうまくいかない
      tmpImg.onload = =>
        ctx = tmpCanvas.getContext '2d'

        #canvasを反転させて画像化する
        ctx.translate(vid.width,0)
        ctx.scale(-1,1);
        ctx.msImageSmoothingEnabled = true
        ctx.drawImage(vid, 0, 0, vid.width, vid.height)
        ctx.drawImage(tmpImg, 0, 0, vid.width, vid.height)

        #フレーム画像はソースを反転させて使おう！！
        ctx.drawImage(frameImg,0,0, vid.width, vid.height)

        finalImage = new Image()
        final_data_src = tmpCanvas.toDataURL "image/png"
        finalImage.src = final_data_src
        finalImage.onload = =>
          $('#shotImg').append($(finalImage))
          @blobObj = facebookCanvasUtil.getBlob()
          $(document).trigger(Events.POST_IMAGE_READY)
          return
        return
      return
    #maskを切り替える。ついでにFrameも切り替え
    changeMask:(direction)=>
      if(direction is "next")
        @maskID++  
      else
        @maskID--
      if @maskID >= @numMask
        @maskID = 0
      else
        if @maskID < 0
          @maskID = @numMask-1
      updateMask @maskID
      @changeFrame()
      return
    #frameを切り替え。maskの数と等しくする必要ある
    changeFrame:()=>
      $("#frame img").removeClass "currentFrame"
      $("#frame#{@maskID}").addClass "currentFrame"
      return
    initDebug: =>
      #console.log("initDebug")
      @stats = new Stats()
      @container.appendChild(@stats.domElement)
      @gui = new dat.GUI()
      @gui.add(@settings,'post')
      @gui.add(@settings,'startContents')
      @gui.add(@settings,'translateImg')
      #@gui.add(@settings,'maskChange')
      return
    #upload完了後のアニメーションを管理
    update:=>
      try
        @homoObj.update()
      catch e
        #console.log "error"
      
      @animationID = requestAnimationFrame(@update)
      return
    facebookReady=()->
      
      #facebookHelper.postImageByBlob blobObj,AppSettings.FACEBOOK_PAGE_ID,AppSettings.FACEBOOK_PAGE_TOKEN



