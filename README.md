# simple_movie_maker

A web app to generate video file online.

Run online: http://pavelvasev.github.io/simple_movie_maker/

Run via qmlweb.run: http://pavelvasev.github.io/qmlweb.run/?s=https%3A%2F%2Fgithub.com%2Fpavelvasev%2Fsimple_movie_maker%2Fgh-pages%2FMaker.qml
(but gif encoding wont work maybe..)

# features
* generate gif, webm
* download all image files as zip
* write images as png files to selected dir

# api
simple_movie_maker recognizes following messages.
All commands are sent using postMessage with event data, within a key `cmd`.

### reset
Prepare a new recording session.

Example:
```
// a special way to open window in another OS process:
recorderWindow = window.open( "about:blank","_blank", "width=1200, height=700" );
recorderWindow.opener = null;
recorderWindow.document.location = "https://viewzavr.com/apps/viewzavr-system-a/lib/simple_movie_maker/";

// ... wait for window to be loaded ...
recorderWindow.postMessage( {cmd:"reset"},"*");
```

### append
Append image to session. An image should be specified in `args` key which should be an array.
Image may be an url, data url, and probably blob. Also it may be an array of such things.

Example:
```
var img = renderer.domElement.toDataURL("image/png");
recorderWindow.postMessage( {cmd:"append",args:[img],ack:subcounter},"*");
```

Example 2, appending many images:
```
recorderWindow.postMessage( {cmd:"append",args:[img1, img2, img3],ack:subcounter},"*");
```

### finish
Finish recording session.

Example:
```
recorderWindow.postMessage( {cmd:"finish"},"*");
```

## api replies
simple_movie_makers replies to every message with `cmd` and `ack` keys from original message. 
It is useful to track these replies because if one sends too many images per second, 
simple_movie_maker may drop them. The reply gives some guaranties that image is processed.

Example:
```
window.addEventListener("message", receiveMessageAck, false);
function receiveMessageAck(event) {
  if (event.source === recorderWindow && event.data.cmd == "appendDataUrl")
      bWaitingFromRecorder = false; // or some other action
}
```

# todo and ideas
* convert to html-based app (e.g. include qmlweb in repo).
* add viewer.html for output zip, to see images with some simple slider.
* optimize memory, including revokeObjectURL().
* accept "string annotation" parameter via postMessage.
this will allow to add things like "t=10".
(but probably this should be rendered right in client).
* maybe allow user to add text annotations to all images together.
* extra guide for modules, for example - example scripts for ffpmeg images to video processing,
or information about codec in Webcodecs module.

# done
* add `append` method to append not urls (data urls), but say files or blobs.
Or is it better to make another methods for these data types?
* maybe change `append` to process many images. in that case, only 1 reply should be sent?


2015-2021 (c) Pavel Vasev
