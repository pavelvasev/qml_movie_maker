// uses https://stuk.github.io/jszip/
Column {
    id: enc
    //    anchors.fill: parent
    //    color: "grey"
    spacing: 5

    JsLoader {
        source: "https://cdn.rawgit.com/Stuk/jszip/master/dist/jszip.js"
        // https://github.com/Stuk/jszip/blob/master/dist/jszip.js
        onLoaded: console.log("loaded jszip.js");
    }

    function getBase64Image(img) {
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
        var dataURL = canvas.toDataURL("image/png");

        return dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
    }

    function pad(num, size) {
        var s = num+"";
        while (s.length < size) s = "0" + s;
        return s;
    }

    function generate() {
        var total = imagesCount;
        console.log("adding to zip");

        var zip = new JSZip();

        var padding = Math.ceil( Math.log10(total) );
        for (var i=0;i<total; i++) {
            var img = getImageObject( i );
            var imgData = getBase64Image( img );
            zip.file("image-"+pad(i,padding)+".png", imgData, {base64: true});
        }

        var blob = zip.generate({type:"blob"});

        maker.generated( blob, "file", "zip" );
    } // generate func

}
