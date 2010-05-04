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
// uses the same markup as in views/admin/firb_text_cards/new.dryml
// Used in that same dryml template
function textPageAddNote() {
    var rand = Math.floor(Math.random()*9999),
        markup = "<div class='firb-note'><textarea rows='4' cols='50' name='firb_text_card[note][new_"+rand+"]'></textarea><span class='firb-remove-note'>Elimina nota</span></div>";
    $$('#firb-notes')[0].insert({bottom: markup});
}

function addIconclassTerm() {
    var rand = Math.floor(Math.random()*9999);
    var markup = "<div class='firb-iconclass-term'>"+currentIconterm.content+"<input type='hidden' name='firb_illustrated_memory_depiction_page[iconclass_term][new_"+rand+"]' value='"+currentIconterm.val+"' /><span class='firb-remove-iconclass-term'>Elimina iconterm</span></div>";
    $$('#firb-iconclass-terms')[0].insert({bottom: markup});
    
}

document.observe('click', function(e) {

    // Remove iconterm
    if (e.element().match('.firb-remove-iconclass-term')) {
        e.findElement('.firb-iconclass-term').remove();
        e.stop();
    }

    // Remove note: in text_card new and edit actions
    if (e.element().match('.firb-remove-note')) {
        e.findElement('.firb-note').remove();
        e.stop();
    }
});