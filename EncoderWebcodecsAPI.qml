// https://github.com/w3c/webcodecs
// https://w3c.github.io/webcodecs/samples/capture-to-file/capture-to-file.html
// also
// https://web.dev/file-system-access/

// for future:
// https://github.com/mattdesl/mp4-wasm/

Column {
    id: enc

    spacing: 5
    
    JsLoader {
        source: Qt.resolvedUrl( "web-writer2.js" )
        //source: "https://cdn.rawgit.com/Stuk/jszip/master/dist/jszip.js"
        // https://github.com/Stuk/jszip/blob/master/dist/jszip.js
        onLoaded: console.log("loaded jszip.js");
    }
    
    
    Row {
    Button {
      text: "Select target file"
      width: 200
      onClicked: setup_fs()
    }
    
    Button {
      text: "Close file"
      onClicked: restart();
      enabled: writeable ? true : false
      width: 100
    }
    spacing: 5
    }
    
    Row {
    spacing: 5

    Text {
      text: writeable ? "opened for writing" : "not selected"
    }
    
    Text {
      text: "Encoded count:" + encodedFrames + " pending: " + pendingFrames
    }
    
    }
    
    Row {
    spacing: 5
    
    Text {
        text: "Frames per second:"
    }

    TextField {
        id: fps
        text: "25"
        property var value: parseFloat( text )
    }
    
    }

    property var writeable
    property var videoWriter
    property var videoEncoder

    function setup_fs() {
      // close current writeable and videoWriter?
      //writeable = null;
      restart();
      var p = window.showSaveFilePicker({
          //startIn: 'videos',
          suggestedName: "myVideo.webm",
          types: [{
            description: 'Video File',
            accept: {'video/webm' :['.webm']}
            }],
      })
      p.then( function(handle) {
        handle.createWritable().then( function(w) {
          console.log("writeable ok");
          writeable = w;
        });
      });
    }

    function newwriter( w,h, cb ) {
      var codec_string = 'vp09.00.10.08';
      var codec = codec_string == 'vp8'?'VP8':'VP9';
      
      videoWriter = new WebMWriter({
        fileWriter: writeable,
        codec: codec,
        width: w,
        height: h
      });
      
      videoEncoder = new VideoEncoder( 
        {
        output: function(chunk) {
          videoWriter.addFrame(chunk);
          cb();
        },
        error: function (e) {
          console.log(e.message);
          cb();
        }
        }
      );
      
//      debugger;
      videoEncoder.configure({
        codec: codec_string,
        width: w,
        height: h,
        bitrate: 10e6,
        framerate: fps.value // вот это может даже не обязательно
      });
    }

    function getImagePngBlob(img,cb) {
        if (img instanceof Blob)
          return cb( img );
        if (typeof(img) === "string") { // think this is url/dataurl
          var newimage = new Image();
          newimage.src = img;
          newimage.onload = function()
          {
            getImagePngBlob( newimage, cb );
          }
          return;
        }
        // file?
    
        if (img.naturalWidth == 0) {
          console.error("warning, img nat width = 0!");
          //debugger;
        }
        // Create an empty canvas element
        var canvas = document.createElement("canvas");
        canvas.width = img.naturalWidth;
        canvas.height = img.naturalHeight;

        // Copy the image contents to the canvas
        var ctx = canvas.getContext("2d");
        ctx.drawImage(img, 0, 0);

        // Get the data-URL formatted image
        // Firefox supports PNG and JPEG. You could check img.src to
        // guess the original format, but be aware the using "image/jpg"
        // will re-encode the image.
        dataURL = canvas.toBlob(cb); //"image/png");
    }

    function pad(num, size) {
        var s = num+"";
        while (s.length < size) s = "0" + s;
        return s;
    }

    function saveimg( img, cb ) {
    
      var prealimg = maker.anythingToImageBitmapPromise( img )

      prealimg.then( function(realimg) {
          if (!videoWriter) {
            newwriter( realimg.width, realimg.height, cb );
            encodedFrames = 0;
            pendingFrames = 0;
          }
      
          const insert_keyframe = (encodedFrames % 50) == 0;
          pendingFrames = pendingFrames + 1;
          var timeperframe = 1000000.0 / fps.value; // microseconds
          var opts = {duration: timeperframe, timestamp: timeperframe * encodedFrames };
          console.log("encoding frame with opts",opts, "encodedFrames=",encodedFrames, "insert_keyframe=",insert_keyframe );

          var fr = new VideoFrame( realimg,opts );
          videoEncoder.encode( fr, { keyFrame: insert_keyframe });
          videoEncoder.flush();
      });
    }
    
    
    property int encodedFrames: 0
    property int pendingFrames: 0
    property bool bNeedClose: false
    
    property var cbQueue: []

    function saverec( array, cb ) {
      if (array.length == 0) return cb();
      
      // если очередь не пуста - добавим себя в конец очереди
      if (cbQueue.length > 0) {
        cbQueue.push( function() {
          saverec( array, cb );
        });
        return;
      }

      // всегда добавим вызов следующего saverec
      // и если там ничего не остается - сработает вызов каллбеки cb (см выше)
      var more1 = array.slice(1);
      cbQueue.push( function() {
        saverec( more1, cb );
      })
      
      
      // наличие общей очереди callback-ов необходимо, тк. инфа о том что кадр записался
      // хранится в глобальном контексте
      // улучшенный вариант это хранить очередь очередей, чтобы вызовы независимые saverec
      // не перепутались, но пошло оно лесом - все-равно saverec подразумевается выдает каллбеку

      saveimg( array[0], f );

      // каллбека для енкодера (будь он неладен)
      function f() {
        //debugger;
        encodedFrames = encodedFrames + 1;
        pendingFrames = pendingFrames - 1;
        
        if (bNeedClose) {
          restart();
          return;
        }
        
        if (cbQueue.length > 0) {
           var nxt = cbQueue.shift();
           nxt();
        }

      }
    }
    
    //// котовасия на тему сохранения по мере поступления

    function restart() {
      if (videoEncoder) videoEncoder.close();
      videoEncoder = null;

      if (videoWriter) {
        console.log("restart going to wait videoWriter to complete");
        videoWriter.complete().then( function() {
          videoWriter = null;
          restart();
        });
        return;
      }
      
      if (writeable) writeable.close();
      writeable = null;
      
      cbQueue = [];
      
      console.log("restart finished" );
    }

    ////////////////////////////////////////////////
    // API methods

    // input: array of things (img, blob, dataurl...)
    // output: promise when work is done, null if work is postponed to generate stage.
    function append( array ) {
      if (!writeable) {
        return;
        //return maker.keep( array );
      }
  
      var p = new Promise( function(resolve,reject) {
        saverec( array, resolve );
      });
      
      return p;
    }

    function generate(images) {
      saverec( images, finish );
    }
    
    function finish() {
      if (videoEncoder) {
        bNeedClose = true;
      }
      else
        restart();
    }

}
