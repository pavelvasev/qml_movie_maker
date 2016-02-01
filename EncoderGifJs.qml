// uses https://github.com/jnordberg/gif.js
Column {
    id: enc
    //    anchors.fill: parent
    //    color: "grey"
    spacing: 5
    property var outputIsVideo: false
    property var outputFileExt: "gif"

    JsLoader {
        //source: Qt.resolvedUrl( "whammy-master/whammy.js" )
        //source: Qt.resolvedUrl( "gif.js-master/dist/gif.js" )
        //this is hack too
        source: "https://pavelvasev.github.io/simple_movie_maker/gif.js-master/dist/gif.js"
        // https://cdn.rawgit.com/jnordberg/gif.js/master/dist/gif.js"
        
        onLoaded: console.log("loaded gif.js");
    }
    //property var workerPath: Qt.resolvedUrl( "gif.js-master/dist/gif.worker.js" )
    // may apply for ugly hack and use this link
    // http://pavelvasev.github.io/simple_movie_maker/gif.js-master/dist/gif.worker.js
    // which allows to run maker from qmlweb.run
    // OK so we use hack.
    property var workerPath: {
        if (window.location.host.indexOf(".github.io") >= 0)
        {
            return window.location.protocol + "//" + window.location.host + "/simple_movie_maker/gif.js-master/dist/gif.worker.js";
        }
        return Qt.resolvedUrl( "gif.js-master/dist/gif.worker.js" )
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
                              workerScript: workerPath
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
            try {
              ctx.drawImage(img, 0, 0);
            } catch (msg) {
              console.log( msg );
            }
            gif.addFrame( ctx, {delay: delay} );
            
        } // for

        console.log("generating gif");
        gif.on('finished', function(blob) {
            console.log("so finished !!");
            renderProgress = 1;
            maker.generated( blob, "image", "gif" );
        });
        gif.on('progress', function(progress) {
            renderProgress = progress;
        });

        renderProgress = 0;
        gif.render();
    } // generate func

}
