// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


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

// Adds dynamically a note to the bottom of the #firb-notes div, 
// uses the same markup as in views/admin/firb_text_cards/new.dryml
// Used in that same dryml template
// Fixme: Needs refactoring
function textPageAddNote(model_name) {
    var rand = Math.floor(Math.random()*9999),
        markup = "<div class='firb-note'><textarea rows='4' cols='50' name='"+model_name+"[note][new_"+rand+"]'></textarea><span class='firb-remove-note'>Elimina nota</span></div>";
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



// Click on remove button: remove the entire group!
function remove_group(id) {
    $(''+id).remove();
    return true;
} // remove_group()

// Will add some markup to the DOM, an LI item inside the specified UL object,
// displaying the display_string. values_array elements must be objects with
// this format: {name: "name of the field", value: "value to assign"}. They
// will be used in the hidden fields, so name will be something like
// modelname[param_name][sub_name][some_othername], or similar.
// This function will add the remove button as well.
function populate_with_item(populate_ul, display_string, values_array) {
    var rand_id = "id_" + Math.floor(Math.random()*99999),
        markup = "";

    // console.log("# Called pop with "+populate_ul+", "+display_string+" "+values_array+" id: "+rand_id);
        
    markup += "<li id='"+rand_id+"'>";
    markup += "<span class='display_string'>"+display_string+"</span>";

    // Add all of the needed hidden fields
    for (var i = values_array.length - 1; i >= 0; i--) {
        var name = values_array[i].name,
            value = values_array[i].value;
        markup += "<input type='hidden' value='"+value+"' name='"+name+"'>"
    };
    
    var rem = 'remove_group("'+rand_id+'")';
    markup += "<span class='remove_button' onClick='"+rem+"'>X</span>"
    markup += "</li>";
    
    $(populate_ul).insert({bottom: markup});

} // populate_with_item()
