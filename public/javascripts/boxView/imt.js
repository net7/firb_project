
// ImageMapperTool Viewer handling

// Initialization: IMT will call this when it's ready to load an image
function jsapi_initializeIMW(id) {
    var new_b64;
    if (navigator.appName.indexOf("Microsoft") != -1) new_b64 = $(id).readAttribute('b64');
    else new_b64 = $$('#'+id+" embed")[0].readAttribute('b64');
    getFlashObject(id).initialize(new_b64, 1);
} // jsapi_initializeIMW()

function getFlashObject(movieName) {
	if (navigator.appName.indexOf("Microsoft") != -1) {
		return window[movieName];		
	} else {
		var obj = document[movieName];
		if (obj.length != 'undefined') {
			for(var i=0;i<obj.length;i++) { 
				if(obj[i].tagName.toLowerCase() == 'embed') return obj[i]; 
			}
		}
		return obj;
	}
}


function jsapi_mouseOver(fid, ki) {	
    $$("span#image_zone_"+ki)[0].toggleClassName('highlighted');
}
function jsapi_mouseOut(fid, ki) {
    $$("span#image_zone_"+ki)[0].toggleClassName('highlighted');
}
function jsapi_mouseClick(fid, ki) {
	return true;
}
