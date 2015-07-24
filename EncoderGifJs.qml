Column {
    id: enc
    //    anchors.fill: parent
    //    color: "grey"
    spacing: 5

    JsLoader {
        //source: Qt.resolvedUrl( "whammy-master/whammy.js" )
        source: "http://cdn.rawgit.com/jnordberg/gif.js/master/dist/gif.js"
        onLoaded: console.log("loaded gif.js");
    }

    Text {
        text: "Gif Frames per second:"
    }

    TextField {
        id: fps
        text: "10"
    }

    /*
    Button {
            text: "Generate video file"
            width: 200
            onClicked: generate();
            enabled: imagesCount>0
    }
*/    

    
    //    property var outputBlob: null
    //    property var outputObjectUrl: outputBlob ? window.URL.createObjectURL(outputBlob) : null;
    property var video: true

    function generate() {
        //      debugger;
        var total = imagesCount;
        console.log("adding to gif");


        var firstImg = getImageObject( 0 );
        var w = firstImg.naturalWidth;
        var h = firstImg.naturalHeight;

        var afps = parseInt( fps.text );
        var delay = 1000/afps;

        var gif = new GIF({
				  workers: 2,
				  quality: 10,
				  width: w,
				  height: h,
				  workerScript: "http://cdn.rawgit.com/jnordberg/gif.js/master/dist/gif.worker.js"
				});
        

        for (var i=0 ;i<total; i++) {
            var img = getImageObject( i );
            
            var canvas = document.createElement("canvas");
            //canvas.width = img.naturalWidth;
            //canvas.height = img.naturalHeight;
            canvas.width = w;
            canvas.height = h;

            // Copy the image contents to the canvas
            var ctx = canvas.getContext("2d");
            ctx.drawImage(img, 0, 0);
            gif.addFrame( ctx, {delay: delay} );
            
        } // for
        console.log("generating gif");
				gif.on('finished', function(blob) {
				  outputBlob = blob;
				  outputIsVideo = false;
				  console.log("finished");
				  //window.open(URL.createObjectURL(blob));
				});        
        gif.render();
        
        //outputBlob = encoder.compile();
        
        
        /*
      var url = window.URL.createObjectURL(output);
      console.log("showing");
      window.open(url);
      */
    }

}
