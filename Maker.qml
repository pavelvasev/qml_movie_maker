import qmlweb.components

Item {
    id: maker
    anchors.margins: 5

    Text {
        x:5
        y:5

        text: "this is movie maker"
        font.pixelSize:15
    }

    // ********************** encoders interop
 
    // used by encoders
    function getImageObject( index ) {
        var qmlimg = imgRep.itemAt(index);
        if (!qmlimg) return {};
        return qmlimg.dom.children[0];
    }

    // sent by encoders on work finish
    signal generated( object blob, bool isvideo, string ext );
    
    onGenerated: {
      outputBlob = blob;
      outputIsVideo = isvideo;
      outputFileExt = ext;
      outputTime = resetTime;
    }

    // ********************* program state
    
    property var outputBlob
    property var outputObjectUrl: outputBlob ? window.URL.createObjectURL(outputBlob) : null;
    property var outputIsVideo: false
    property var outputFileExt
    property var outputFilePrefix: "animation"

    property var outputTime: { return new Date(); }
    property var resetTime: { return new Date(); }

    property var outputFileName: {
      function pad(num) {
        var s = "000000000" + num;
        return s.substr(s.length-2);
      }
      //var d = new Date();
      var d = outputTime;
      //var f = d.getFullYear() + "-" + pad(1+d.getMonth()) + "-" + pad(d.getDate()) + "-" + pad(d.getHours()) + "-" + pad(d.getMinutes()) + "-" + pad(d.getSeconds());
      var f = d.getFullYear() + "" + pad(1+d.getMonth()) + "" + pad(d.getDate()) + "-" + pad(d.getHours()) + "" + pad(d.getMinutes()) + "-" + pad(d.getSeconds());
      return outputFilePrefix + "-" + f + "." + outputFileExt;
    }
    
    property var imagesCount: 0
    property var videoEncoder
    property var renderProgress: 1

    // ******************** api
    
    function clear() {
        imagesCount = 0;
        resetTime = new Date();
    }
    function reset() { clear(); }
    
    function loadFile( i, file )
    {
        var reader = new FileReader();
        reader.onload = function(ee) {
            var img = getImageObject( i );
            img.src = ee.target.result;
            //adjustSize(i);
        }
        reader.readAsDataURL( file );
    }

    function appendFile( file ) {
        imagesCount = imagesCount+1;
        loadFile( imagesCount-1, file );
    }

    function appendDataUrl( dataurl )
    {
        imagesCount = imagesCount+1;
        var img = getImageObject( imagesCount-1 );
        img.src = dataurl;
        //adjustSize(imagesCount-1);
    }

    function finish() {
        console.log("got finish command, generating.")
        videoEncoder.generate();
    }

    function adjustHeight(i) {
        var qmlimg = imgRep.itemAt(i);
        if (!qmlimg) return 100;

        var img = getImageObject( i );
        var screenW = qmlimg.width; // то что задали на экране после слайдера
        var natW = img.naturalWidth; // исходное
        var ratio = screenW / natW; // соотношение экран/исходное
        qmlimg.height = qmlimg.naturalH * ratio; // naturalH will be updated upon image load
    }
    
    // ********************* window messages
    function initWindowMessages() {
        window.addEventListener("message", receiveMessage, false);
    }
    // call cmd as raw func
    function receiveMessage(event) {
        var cmd = event.data.cmd;
        var args = event.data.args;
        console.log("cmd=",cmd)
        maker[cmd].apply( maker, args );
        //debugger;
    }

    Component.onCompleted: {
        initWindowMessages();
        maker.widthChanged();
        maker.heightChanged();
        encColumn.layoutChildren(); // hack
    }

    // ******************** gui


    Text {
        text: "Choose image files or drop them here. Then press 'generate video output'."
        anchors.fill: flow
        anchors.margins: 10
        visible: imagesCount == 0
    }


    FileDrop {
        dropZone: flow
        onFilesChanged: {
            maker.reset();
            for (var i=0; i<files.length; i++)
                maker.appendFile( files[i] );
        }
    }

    Slider {
      anchors.bottom: flow.bottom
      anchors.right: flow.right
      anchors.rightMargin: 30
      z: 5
      id: imgSizeSlider
      value: 0.25
      minimumValue: 0.2
    }

    Grid {
        y: 37
        x: 10
        width: parent.width// -x/2
        height: parent.height -y
        columns: 2
        rows: 2
        id: grid
        spacing: 20
        //css.border: "1px solid red";

        Row {

        FileSelect {
            id: imgas
            multiple: true
            onFilesChanged: {
                //console.log("new files=",files);
                maker.reset();
                imagesCount = files.length;
                for (var i=0; i<files.length; i++)
                    loadFile(i, files[i]);
            }

        } // fileselect

    Text {
        y: 3
        text: "Images count: " + imagesCount
    }

    }



        Button {
            text: "Generate video output"
            width: 200
            onClicked: videoEncoder.generate();
            enabled: imagesCount>0
        }

        /*        Text {
            text: "Generate output"
        }
*/

        Flow {
            width: maker.width/2
            height: maker.height - 100
            spacing: 2 + 7*imgSizeSlider.value  
            id: flow

            css.overflowY: "auto";
            css.overflowX: "hidden";
            css.pointerEvents: "all";
            css.border: "1px dashed grey";

            Repeater {
                id: imgRep
                model: imagesCount
                Image {
                    width: maker.width * 0.47 * imgSizeSlider.value
                    height: adjustHeight( index );
                    property var naturalH: 100
                    onWidthChanged: adjustHeight(index);
                    onNaturalHChanged: adjustHeight(index);
                    
                    id: imga
                    css.pointerEvents: "all";
                    Component.onCompleted: {
                        // this hack will mantain aspect ratio
                        imga.dom.children[0].style.height = "";
                        imga.dom.children[0].onload = function() { naturalH = imga.dom.children[0].naturalHeight; } 
                    }
                }
            }
        } // flow

        Column { // encoding
            id: encColumn
            
            TabView {
                id: encoders
                property var currentTab: getTab( currentIndex )
                onCurrentTabChanged: videoEncoder = currentTab.encoder;
                //height: 30 + (currentTab ? currentTab.height : 0)
                height: 100
                width: parent.width
                //width: maker.width/2 - 60

                Tab {
                    title: "Gif"
                    property var encoder: gif
                    EncoderGifJs {
                        id: gif
                    }
                }
                Tab {
                    title: "WebM"
                    property var encoder: whammy
                    EncoderWhammy {
                        id: whammy
                    }
                }
                
            }

            Text {
                //text: "To save result "+ outputFileExt+", click <a href='"+maker.outputObjectUrl+"' download='"+ outputFileName +"' >here</a>."
                //text: "Click to save <a href='"+maker.outputObjectUrl+"' download='"+ outputFileName +"' >result " + outputFileName + "</a>."
                text: "Click to save <a href='"+maker.outputObjectUrl+"' download='"+ outputFileName +"' >" + outputFileName + "</a>"
                font.pixelSize:15
                z: 1000
                height: 40
                visible: outputBlob
            }

            ProgressBar {
                indeterminate: renderProgress < 0.001
                value: renderProgress
                visible: renderProgress < 1
            }

            Video {
                visible: outputIsVideo
                source: outputObjectUrl || ""
                //width: parent.width
                width: maker.width*0.4
                height: Math.max( 200, maker.height-350 )
                autoPlay: true
                controls: true
            }
            
            Image {
                //width: parent.width
                width: maker.width*0.4
                height: Math.max( 200, maker.height-350 )
                visible: !outputIsVideo
                source: outputObjectUrl || ""
                id: rimga
                css.pointerEvents: "all";

                Component.onCompleted: {
                    rimga.dom.children[0].style.height = "";
                    rimga.dom.children[0].style.border = "1px solid grey";
                }
            }
            
        } // encoding column

    } // grid
}
