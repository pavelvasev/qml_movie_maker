// May load 1 js or css file, specified by `source`
// emits `loaded` signal upon load.

Item {
  property var source: ""

  onSourceChanged: {
    ola_require( source, loaded )
  }

  signal loaded( string src );

  function ola_path(file) { return file; }

  function ola_require(file,callback){
    if (!file || file.length == 0) return;

    if (!window.xla_required) window.ola_required = {};
    var ola_required = window.ola_required;

    console.log("ola_required[file]=",ola_required[file],"file=",file);
    
    if (ola_required[file] == "1" ) { // means already required
      return callback();
    }

    if (ola_required[file]) { // script requered, but still not loaded
      ola_required[file].onreadystatechange = function() {
        if (this.readyState == 'complete') {
            ola_required[file] = "1";        
            callback();
        }
      }
    }    

    var head=document.getElementsByTagName("head")[0];
    var script;

    if (/\.css$/.test(file)) {
      script=document.createElement('link');
      script.rel ='stylesheet';
      script.href = ola_path(file);
    }
    else
    {
      script=document.createElement('script');
      script.type='text/javascript';
      script.src= ola_path(file);
    }
    
    ola_required[file] = script;
    
    //Internet explorer
    script.onreadystatechange = function() {
        if (this.readyState == 'complete') {
            ola_required[file] = "1"; // mark it loaded
            //console.log(" calling ckb");
            callback( file );
        }
    }
    //real browsers
    script.onload = function() {
      ola_required[file] = "1"; // mark it loaded
      //console.log(" calling ckb 2");
      callback( file );
    }
    
    head.appendChild(script);
  }    
  
}