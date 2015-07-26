Rectangle {
  id: rect
  property var dropZone: rect

  property var files: []
  
  property var visualFeedback: true

  signal drop();

  Component.onCompleted: {
    // actual work
    dropZone.dom.addEventListener('dragover', handleDragOver, false);
    dropZone.dom.addEventListener('drop', handleFileSelect, false);  
    
    // visual feedback
    if (visualFeedback) {
      dropZone.dom.addEventListener('dragenter', dragEnter  , false);
      dropZone.dom.addEventListener('dragleave', dragLeave  , false);    
    }
  }

  function handleDragOver(evt) {
    evt.stopPropagation();
    evt.preventDefault();
    evt.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
  }  

  function handleFileSelect(evt) {
    evt.stopPropagation();
    evt.preventDefault();

    files = evt.dataTransfer.files; // FileList object.

    drop();

    if (visualFeedback)
      event.target.style.border = prevBorder;
  }
  
   property var prevBorder: "none"

   function dragEnter(event) {
     event.target.style.border = "2px dashed green";
   }

   function dragLeave(event) {
     event.target.style.border = prevBorder;
   }

}