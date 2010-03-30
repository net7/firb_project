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

function jsapi_mouseOver(fid, ki) {	
    $$("span#firb_image_zone_"+ki)[0].toggleClassName('highlighted');
}
function jsapi_mouseOut(fid, ki) {
    $$("span#firb_image_zone_"+ki)[0].toggleClassName('highlighted');
}
function jsapi_mouseClick(fid, ki) {
	return true;
}

// Adds dynamically a note to the bottom of the #firb-notes div, 
// uses the same markup as in views/admin/firb_text_pages/new.dryml
// Used in that same dryml template
function textPageAddNote() {
    var markup = "<div class='firb-note'><textarea rows='4' cols='50' name='firb_text_page[note][]'></textarea><span class='firb-remove-note'>Elimina nota</span></div>";
    $$('#firb-notes')[0].insert({bottom: markup});
}

document.observe('click', function(e) {
    if (e.element().match('.firb-remove-note')) {
        e.findElement('.firb-note').remove();
        e.stop();
    }
});