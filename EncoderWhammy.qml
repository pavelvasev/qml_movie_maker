// uses https://github.com/antimatter15/whammy
Column {
    //    anchors.fill: parent
    //    color: "grey"
    spacing: 5
    property var outputIsVideo: true
    property var outputFileExt: "webm"

    JsLoader {
        //source: Qt.resolvedUrl( "whammy-master/whammy.js" )
        source: "https://cdn.rawgit.com/antimatter15/whammy/master/whammy.js"
        onLoaded: console.log("loaded whammy");
    }

    Text {
        text: "Frames per second:"
    }

    TextField {
        id: fps
        text: "10"
    }
    
    property var video: true

    function generate(images) {
        renderProgress = 0;
        setTimeout( function() { do_generate(images) },200 ); // have to use timeout to update gui
    }

    function do_generate(images) {
        //      debugger;
        var total = images.length;
        console.log("adding");
        var encoder = new Whammy.Video(parseInt( fps.text ));
        var firstImg = getImageObject( 0 );
        var w = firstImg.naturalWidth;
        var h = firstImg.naturalHeight;

        for (var i=0 ;i<total; i++) {
            var img = images[i];

            var canvas = document.createElement("canvas");
            canvas.width = w;
            canvas.height = h;

            // Copy the image contents to the canvas
            var ctx = canvas.getContext("2d");
            ctx.drawImage(img, 0, 0);
            encoder.add( ctx );
        } // for

        console.log("generating"); renderProgress = 1;

        encoder.compile( false, function(blob) {
          console.log("finished");
          maker.generated( blob,"video","webm");
        });
    }

}
