Column {
    //    anchors.fill: parent
    //    color: "grey"
    spacing: 5

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
        console.log("adding");
        var encoder = new Whammy.Video(parseInt( fps.text ));
        var firstImg = getImageObject( 0 );
        var w = firstImg.naturalWidth;
        var h = firstImg.naturalHeight;

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
            encoder.add( ctx );

            /*

            if ((/^data:image/ig).test(img.src))
          encoder.add( img.src );
        else {
          console.log("skip ",i);
        }
        */

        } // for
        console.log("generating");
        outputBlob = encoder.compile();
        outputIsVideo = true;
        console.log("finished");
        /*
      var url = window.URL.createObjectURL(output);
      console.log("showing");
      window.open(url);
      */
    }

}
