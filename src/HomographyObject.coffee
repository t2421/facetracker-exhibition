$ = require "jquery"
TweenMax = require "TweenMax"
sylvester = require "sylvester"


module.exports =  
  class HomographyObject
    @ANIMATION_COMPLETE = "animationComplete"
    constructor: ->
      @animateOrder = [0,3,1,2]
    init:(targetDom)=>
      @target = $(targetDom)
      @targetwidth = @target.width()
      @targetheight = @target.height()
      #console.log @target

      #元のターゲットの形
      @origin = [
        [ - @targetwidth / 2, - @targetheight / 2],
        [@targetwidth / 2, - @targetheight / 2],
        [@targetwidth / 2, @targetheight / 2],
        [ - @targetwidth / 2, @targetheight / 2]
      ]

      #変換していくための行列
      @objMatrix = [
        [ - @targetwidth / 2, - @targetheight / 2],
        [@targetwidth / 2, - @targetheight / 2],
        [@targetwidth / 2, @targetheight / 2],
        [ - @targetwidth / 2, @targetheight / 2]
      ]
      #console.log @objMatrix
      #tweenさせるときのobject
      @obj = {
        x0 : @objMatrix[0][0],
        y0 : @objMatrix[0][1],
        x1 : @objMatrix[1][0],
        y1 : @objMatrix[1][1],
        x2 : @objMatrix[2][0],
        y2 : @objMatrix[2][1],
        x3 : @objMatrix[3][0],
        y3 : @objMatrix[3][1]
      }
      #requestAnimationFrame.call window,@update
      return

    #tweenでアニメーションした値を行列に反映させる
    update: =>
      #console.log @obj
      @objMatrix[0][0] = @obj.x0;
      @objMatrix[0][1] = @obj.y0;
      @objMatrix[1][0] = @obj.x1;
      @objMatrix[1][1] = @obj.y1;
      @objMatrix[2][0] = @obj.x2;
      @objMatrix[2][1] = @obj.y2;
      @objMatrix[3][0] = @obj.x3;
      @objMatrix[3][1] = @obj.y3;
      @homographyTransform(@target, @origin, @objMatrix);
      #requestAnimationFrame.call window,@update
      return
    homographyTransform: (target,orgMatrix,transformMatrix)=>
      len = transformMatrix.length
      M = []
      V = []
      
      for val,i in transformMatrix
        x = orgMatrix[i][0]
        y = orgMatrix[i][1]
        X = transformMatrix[i][0]
        Y = transformMatrix[i][1]
        M.push([x, y, 1, 0, 0, 0, - x * X, - y * X])
        M.push([0, 0, 0, x, y, 1, - x * Y, - y * Y])
        V.push(X)
        V.push(Y)
      
      #console.log sylvester.Matrix.create(M).inspect()
      #console.log sylvester.Vector.create(V).inspect()
      ans = sylvester.Matrix.create(M).inv().x(sylvester.Vector.create(V))
      ##console.log(ans.inspect())
      transform = "perspective(1px)scaleZ(-1)translateZ(-1px)matrix3d(" + ans.e(1) + ',' + ans.e(4) + ',' + ans.e(7) + ',0,' + ans.e(2) + ',' + ans.e(5) + ',' + ans.e(8) + ',0,' + ans.e(3) + ',' + ans.e(6) + ',1,0,' + '0,0,0,1)translateZ(1px)';
      target.css 'transform',transform
      return
    change:(type,delay,dulation)=>
      console.log "shrink"
      if type is "shrink"
        scale = 0
      else
        scale = 1.0
      for val,i in @animateOrder
        target = {}
        animateElemIndex = @animateOrder[i]
        propNameX = String "x"+animateElemIndex
        propNameY = String "y"+animateElemIndex
        target[propNameX] = @origin[animateElemIndex][0] * scale;
        target[propNameY] = @origin[animateElemIndex][1] * scale;
        target.ease = Quart.easeInOut
        
        target.delay = i*delay
        if i == 3
          target.onComplete = =>
            #console.log "complete"
            $(@).trigger(HomographyObject.ANIMATION_COMPLETE)
            return
        TweenMax.to($(@obj),dulation,target)
      return







