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

    // ******************** api

    property var outputBlob
    property var outputObjectUrl: outputBlob ? window.URL.createObjectURL(outputBlob) : null;
    property var outputIsVideo: videoEncoder.outputIsVideo

    property var imagesCount: 0
    property var videoEncoder
    property var renderProgress: 1

    function getImageObject( index ) {
        var qmlimg = imgRep.itemAt(index);
        if (!qmlimg) return {};
        return qmlimg.dom.children[0];
    }

    function clear() {
        imagesCount = 0;
    }
    function reset() { clear(); }

    function loadFile( i, file )
    {
        var reader = new FileReader();
        reader.onload = function(ee) {
            var img = getImageObject( i );
            img.src = ee.target.result;
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
    }

    function finish() {
        console.log("got finish command, generating.")
        videoEncoder.generate();
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
    }

    // ******************** impl


    Text {
        text: "Select image files or drop them here. Then press 'generate video'."
        anchors.fill: flow
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

        FileSelect {
            id: imgas
            multiple: true
            onFilesChanged: {
                //console.log("new files=",files);

                imagesCount = files.length;
                for (var i=0; i<files.length; i++)
                    loadFile(i, files[i]);
            }

        } // fileselect



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
            spacing: 2
            id: flow

            css.overflowY: "auto";
            css.overflowX: "hidden";
            css.pointerEvents: "all";
           // css.border: "1px dashed grey";

            Repeater {
                id: imgRep
                model: imagesCount
                Image {
                    width: 100
                    height: 100
                    id: imga
                    css.pointerEvents: "all";
                    Component.onCompleted: {
                        // this hack will mantain aspect ratio
                        imga.dom.children[0].style.height = "";
                    }
                }
            }
        } // flow

        Column { // encoding
            width: parent.width/2 - 40

            TabView {
                id: encoders
                property var currentTab: getTab( currentIndex )
                onCurrentTabChanged: videoEncoder = currentTab.encoder;
                //height: 30 + (currentTab ? currentTab.height : 0)
                height: 100
                width: parent.width
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
                text: "To save result, right-click on it and select 'Save as'"
                font.pixelSize:15
                z: 1000
                height: 40
            }

            ProgressBar {
                intermediate: true
                visible: renderProgress < 1
            }

            Video {
                visible: outputIsVideo
                source: outputObjectUrl || ""
                width: parent.width
                height: Math.max( 200, maker.height-350 )
                autoPlay: true
                controls: true
            }
            
            Image {
                width: parent.width
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
