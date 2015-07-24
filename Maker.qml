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
    property var outputIsVideo: true

    property var imagesCount: 0
    property var videoEncoder

    function getImageObject( index ) {
        var qmlimg = imgRep.itemAt(index);
        if (!qmlimg) return {};
        return qmlimg.dom.children[0];
    }

    // ******************** impl

    Grid {
        y: 37
        x: 10
        width: parent.width// -x/2
        height: parent.height -y
        columns: 2
        rows: 2
        id: grid
        spacing: 20

        FileSelect {
            id: imgas
            multiple: true
            onFilesChanged: {
                //console.log("new files=",files);

                imagesCount = files.length;
                for (var i=0; i<files.length; i++)
                    load(i, files[i]);
            }

            function load( i, file )
            {
                var reader = new FileReader();
                reader.onload = function(ee) {
                    var img = getImageObject( i );
                    img.src = ee.target.result;
                }
                reader.readAsDataURL( file );
            }
        } // fileselect



        Button {
            text: "Generate video file"
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
            height: maker.height
            spacing: 2
            id: flow

            css.overflowY: "auto";
            css.overflowX: "hidden";
            css.pointerEvents: "all";
            //css.border: "1px solid grey";

            Repeater {
                id: imgRep
                model: imagesCount
                Image {
                    width: 100
                    height: 100
                    id: imga
                    Component.onCompleted: {
                        //imga.dom.children[0].style.height = "";
                    }
                }
            }
        } // flow

        Column { // encoding
            width: parent.width/2


            TabView {
                id: encoders
                property var currentTab: getTab( currentIndex )
                onCurrentTabChanged: videoEncoder = currentTab.encoder;
                //height: 30 + (currentTab ? currentTab.height : 0)
                height: 100
                width: parent.width
                Tab {
                    title: "WebP"
                    //anchors.fill: parent
                    //width: parent.width
                    //height: parent.height
                    //height: 150
                    //source: "Whammy.qml"
                    property var encoder: whammy
                    EncoderWhammy {
                        id: whammy
                    }
                }
                Tab {
                    title: "Gif"
                    property var encoder: gif
                    EncoderGifJs {
                        id: gif
                    }
                }
            }

            Video {
                visible: outputIsVideo
                source: outputObjectUrl || ""
                width: parent.width
                height: Math.max( 200, maker.height-250 )
                autoPlay: true
                controls: true
            }

            Text {
              text: "To save result, right-click on it and select 'Save as'"
            }

        } // encoding column

    } // grid
}
