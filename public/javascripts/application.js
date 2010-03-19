// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// ImageMapperTool Viewer handling

// Initialization: IMT will call this when it's ready to load an image
function jsapi_initializeIMW(id) {
	var new_b64 = $$('#'+id+" embed")[0].readAttribute('b64');
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

$('span.image-keyword').live("mouseout", function() {
	var fid = $(this).parents('div.box').find('object.IMTViewer').attr('id');
	var kid = $(this).attr('title');
	getFlashObject(fid).setPolygonHighlighted(false, kid);
	return false;
});


function jsapi_mouseOver(fid, ki) {	
    $$("span#"+ki)[0].toggleClassName('highlighted');
}
function jsapi_mouseOut(fid, ki) {
    $$("span#"+ki)[0].toggleClassName('highlighted');
}
function jsapi_mouseClick(fid, ki) {
	return true;
}