package  {
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.ui.Mouse;
	import flash.events.NativeDragEvent;
	import flash.desktop.Clipboard;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import fl.controls.*;

	public class Main extends MovieClip{
		private var _vertices:Vector.<MovieClip>;
		private const NUM_VERTICES:uint = 71;
		private var _targetVertex:MovieClip;
		private var _bitmapData:BitmapData;
		private var _img:Bitmap;
		private var _file:File;
		private var _loader:Loader;
		private var _vertexLayer:MovieClip;
		private var _imgLayer:MovieClip;
		private var _outFile:File;
		private var _save:Button;
		private var _load:Button;
		
		
		private var _sampleVertices:Array = [[55.65,360.05],[53.6,445],[61.7,517.85],[92.05,602.8],[129.45,664.5],[169.9,712],[234.65,752.45],[304.45,760.55],[381.3,753.5],[442,713],[492.55,657.4],[524.9,582.55],[542.1,504.7],[545.15,424.8],[540.1,346.9],[481.4,298.35],[439.95,263.95],[389.4,269.05],[344.9,301.4],[110.25,307.45],[147.65,278.15],[200.25,275.1],[249.8,301.4],[136.55,360.05],[184.1,337.8],[231.65,359.45],[180.05,372.2],[186.1,356],[456.15,350.95],[412.65,330.7],[363.1,356],[412.65,370.15],[413.65,347.9],[297.35,328.7],[248.8,447.05],[226.55,484.45],[244.75,505.7],[299.35,513.8],[355,504.7],[375.25,481.4],[351.95,440.95],[298.35,402.55],[265,496.6],[336.8,492.55],[213.4,592.65],[244.75,571.45],[276.1,565.35],[304.45,563.35],[329.7,557.25],[365.1,571.45],[399.5,588.6],[377.25,618.95],[346.9,641.2],[306.45,640.2],[269.05,640.2],[235.65,622],[259.95,605.8],[302.8,605.45],[354,601.75],[345.9,578.5],[303.4,584.6],[257.9,585.6],[298.25,482.75],[153.75,343.85],[214.4,339.8],[208.35,372.2],[157.8,370.15],[436.9,337.8],[381.3,335.8],[386.35,364.1],[434.9,362.05]];
		public function Main() {
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,onDragEnter);
            this.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,onDragDrop);
			_file = new File();
			_file.addEventListener(Event.SELECT,selectFileHandler);
			_file.addEventListener(Event.CANCEL,cancelHandler);
			
			trace(_sampleVertices);
			_save = this["save_btn"];
			_load = this["load_btn"];
			_vertexLayer = this["vertexLayer"];
			_imgLayer = this["imgLayer"];
			_vertices = new Vector.<MovieClip>(NUM_VERTICES);
			_bitmapData = new ironman();
			_img = new Bitmap(_bitmapData);
			//_imgLayer.addChild(_img);
			for(var i:uint = 0;i<NUM_VERTICES;i++){
				var vertex:MovieClip = new DragVertex();
				_vertices[i] = vertex;
				_vertexLayer.addChild(vertex);
				vertex.x = _sampleVertices[i][0];
				vertex.y = _sampleVertices[i][1];
				vertex.id_txt.text = i;
				vertex.mouseChildren = false;
				vertex.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
				vertex.buttonMode = true;
			}
			
			
			
			_outFile = new File();
			_outFile.addEventListener(Event.SELECT,fileSaveSelectHandler);
			
			_save.addEventListener(MouseEvent.CLICK,saveHandler);
			_load.addEventListener(MouseEvent.CLICK,loadHandler);
			
			
		}
		
		private function saveHandler(e:MouseEvent):void{
			_outFile.browseForSave("ファイルを保存");
		}
		
		private function loadHandler(e:MouseEvent):void{
			var fileFileter:FileFilter = new FileFilter("image関連ファイル","*.jpg;*.png;.gif;");
			_file.browseForOpen("ファイルを開く",[fileFileter]);
		}
		
		
		private function fileSaveSelectHandler(e:Event):void{
			var arrayStr:String = "";
			arrayStr += "[";
			for(var i=0;i<NUM_VERTICES;i++){
				var vertex:MovieClip = _vertices[i];
				if(i!=0){
					arrayStr += ",";
				}
				
				arrayStr += "[" +vertex.x+",";
				arrayStr += vertex.y+"]";
			}
			arrayStr += "]";
			
			var select : File = e.target as File;
			var stream:FileStream = new FileStream();
			stream.open(select, FileMode.WRITE);
			stream.writeUTFBytes(arrayStr);
			stream.close();
		}
		
		private function cancelHandler(e:Event):void{
			

		}
		
		private function selectFileHandler(e:Event):void{
			_file = e.target as File;
			try{
				_imgLayer.removeChild(_loader);
			}catch(e:Error){
				
			}
			_loader = new Loader();
			trace(_file.url);
			_loader.load(new URLRequest(_file.url));
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,imgLoadComplete);
			//_imgLayer.addChild(_loader);

		}
		private function imgLoadComplete(e:Event):void{
			//var bmd:BitmapData = _loader.data
			_imgLayer.addChild(_loader);
			trace("loaded");
		}
		
		private function onDragEnter(e:NativeDragEvent):void{
			var cp:Clipboard = e.clipboard;
			trace(cp);
		}
		
		private function onDragDrop(e:NativeDragEvent):void{
			
		}
		
		private function mouseDownHandler(e:MouseEvent):void{
			_targetVertex = MovieClip(e.target);
			stage.addEventListener(MouseEvent.MOUSE_UP,upHandler);
			stage.addEventListener(Event.ENTER_FRAME,loop);
		}
		
		private function upHandler(e:MouseEvent):void{
			stage.removeEventListener(Event.ENTER_FRAME,loop);
		}
		private function loop(e:Event):void{
			_targetVertex.x = mouseX;
			_targetVertex.y = mouseY;
		}

	}
	
}
