/* Copyright (c) 2012 Net7 SRL, <http://www.netseven.it/>       */
/* This Software is released under the terms of the MIT License */
/* See LICENSE.TXT for the full text of the license.            */

(function ($) {

    // anchorMan constructor
    $.anchorMan = function (opts) {

        // Global options
        this.options = $.extend({}, $.anchorMan.defaults, opts);
        this.init();

    }; // $.anchorMan()

    // DEFAULTS: anchorMan will use these as defaults
    $.anchorMan.defaults = {

        // Characters used to separate sections, subsections and values
        separatorSections: '|',
        separatorSubSections: '@',
        separatorValues: '*',

        // Use url/cookie to store data?
        useUrl: true,
        useCookie: false,

        // Name and expiration date of the cookie
        cookieName: 'anchorMan',
        cookieDateName: 'anchorManDate',
        cookieLastBoxviewName : 'LastVisitedBoxView',
        cookieExpireDays: 365,

        // If url's anchor and cookie have some valid values, which one to use?
        useUrlOrCookie: 'url',

        // Save data on every add/remove ?
        saveOnAdd: true,
        saveOnRemove: true,

        // check url timer time, in ms
        checkBackButton: true,
        checkBackButtonTimerMS: 200,

        debug: false

    }; // defaults

    $.anchorMan.prototype = {
        init: function () {

            // Will keep the needed callback functions
            this.addCallbacks = [];
            this.removeCallbacks = [];
            this.changeCallbacks = [];
            this.sortCallbacks = [];

            // The current anchor you can read on the URL
            this.current_anchor = "";
            this.last_parsed_anchor = "";
            
            this.checking = false;

            // Will keep the values taken from the URL's anchor
            this.values = {};

            var url_anchor = "",
                cookie_anchor = "",
                cookie_date = null;

            if (this.options.useCookie) {
                cookie_anchor = this.get_cookie_by_name(this.options.cookieName);
                cookie_date = this.get_cookie_by_name(this.options.cookieDateName);
            }

            if (this.options.useUrl) { 
                url_anchor = document.location.hash; 
            }

            this.log("Url/cookie: -" + url_anchor + "- ||| -" + cookie_anchor + "- (" + cookie_date + ")");

            // Anchorman is configured to use both, choose which one to go
            if (this.options.useCookie && this.options.useUrl) {

                if (url_anchor === cookie_anchor) {
                    // They have the same value, just use one of them
                    this.log("Cookie and url match: pick one!");
                    this.current_anchor = url_anchor;

                } else if (url_anchor !== "" && cookie_anchor === "") {
                    // They dont match and cookie is null
                    this.current_anchor = url_anchor;
                    this.log("Cookie is null, using url");

                } else if (url_anchor === "" && cookie_anchor !== "") {
                    // They dont match and url is null
                    this.current_anchor = cookie_anchor;
                    this.log("URL is null, using cookie");

                } else if (this.options.useUrlOrCookie === "url") {
                    // They dont match... look at the useUrlOrCookie variable
                    this.log("URL/cookie dont match, using useUrlOverCookie = url");
                    this.current_anchor = url_anchor;

                } else if (this.options.useUrlOrCookie === "cookie") {
                    this.log("URL/cookie dont match, using useUrlOverCookie = cookie");
                    this.current_anchor = cookie_anchor;
                } else if (this.options.useUrlOrCookie === "ask") {

                    this.log("They dont match, asking the user");

                    var q = "Mr. AnchorMan found you have a saved session on " + this.get_cookie_by_name(this.options.cookieDateName) + "\n\n" +
                        "Press OK to load it or CANCEL to delete it and load the page you asked from the URL.";

                    if (confirm(q)) {
                        this.current_anchor = cookie_anchor;
                    } else {
                        this.current_anchor = url_anchor;
                    }
                }

            } else if (this.options.useCookie && !this.options.useUrl) {
                // We are not using url
                this.current_anchor = cookie_anchor;

            } else if (!this.options.useCookie && this.options.useUrl) {
                // We are not using cookie
                this.current_anchor = url_anchor;
            }

            // Parse the values from the given string
            this.values = $.extend({}, this.get_values_from_anchor(this.current_anchor), {});


            // Start the check_url timer
            var self = this;
			if (this.options.checkBackButton && this.options.useUrl) {
                this.checkUrlTimer = setInterval(function () { self.check_url(); }, this.options.checkBackButtonTimerMS);
            }

        }, // init()

		// Serialize the values of the tree:
		// ret[name] will be something like: [0 => "val1,val2,val3", 1 => "val1,val2,val3"]
		// ret["s_"+name] will be: ["val1,val2,val3" => 0, "val1,val2,val3" => 1]
		serialize_values : function (values) {
			var ret = {}, name, i;
			for (name in values) {

				ret[name] = [];
				ret["s_" + name] = [];
				
				for (i in values[name]) {
					var foo = values[name][i].join(",");
					ret[name][i] = foo;
					ret["s_" + name][foo] = i;
				}
			}
			return ret;
		}, // serialize_values()
		

        check_url: function () {

            if (this.checking === true) {
                this.log("Already checking, checkBackButtonTimerMS too little?? Skipping this one");
                return false;
            }

            this.checking = true;

            if (document.location.hash.substring(1) !== this.current_anchor) {

                // Copy old values hash into a temporary variable then
                // parse the values from the given string. Finally serialize both
                var oldValues = $.extend({}, this.values, {}),
                    newValues = $.extend({}, this.get_values_from_anchor(document.location.hash), {}),
				    serOld = $.extend({}, this.serialize_values(oldValues), {}), 
					serNew = $.extend({}, this.serialize_values(newValues), {}),
					name;
				
                // The only things we can find here are:
                // ABC -> AB : element has been removed
                // ABC -> ABCD : element has been added
                // ABC -> BCA : order has changed
                // ABC -> ADE : multiple elements has been modified
				// "" -> A
				// A -> ""
                // Cycle over all sections

                for (name in oldValues) {

					this.log("Checking URL " + name + ": " + typeof(serNew[name]) + " // " + typeof(serNew[name]));

					if (typeof(serNew[name]) === "undefined") {

						this.log("Found a removed item: " + serOld[name][0] + " (was " + name + ")");

						if (typeof(this.removeCallbacks[name]) === "function") {
	                        this.log("Calling REMOVE callback for " + name + " with values: " + oldValues[name][0]);
	                        this.removeCallbacks[name].call(this, this.values2Object(name, oldValues[name][0]));
		                }
						continue;

					} // typeof serNew[name] == undefined

					// This section didnt change, skip it
					if (serOld[name].join(",") === serNew[name].join(",")) {
					    this.log("Section " + name + ": old == new, SKIPPING");
						continue;
					} else {
					    this.log("Section " + name + " old != new: " + serOld[name].join(",") + " >> " + serNew[name].join(","));
					}

					// #OLD > #NEW: back action removed an item
					if (oldValues[name].length > newValues[name].length) {

						this.log("#OLD > #NEW: Removed item?");

						for (var i = 0; i < serOld[name].length; i++) {

							var foo = serOld[name][i];
							this.log("Section " + name + " #OLD > #NEW: " + foo + " -> " + serNew["s_" + name][foo] + " len: " + serOld[name].length);

							if (typeof(serNew["s_" + name][foo]) === "undefined") {

								this.log("Section " + name + ", removed item: " + serOld[name][i]);

								if (typeof(this.removeCallbacks[name]) === "function") {
			                        this.log("Section " + name + " calling REMOVE callback: " + oldValues[name][i]);
			                        this.removeCallbacks[name].call(this, this.values2Object(name, oldValues[name][i]));
				                }
							} // if typeof serOld == undefined
						} // for i

						
					// #NEW > #OLD: back action added an item
					} else if (oldValues[name].length < newValues[name].length) {

						this.log("#OLD < #NEW: Added item?");

						for (var i=0; i<serNew[name].length; i++) {
						
							var foo = serNew[name][i];
							this.log("Section "+ name +" #OLD > #NEW: "+foo+ " -> " + serOld["s_"+name][foo] + " len: " + serNew[name].length);
							
							if (typeof(serOld["s_"+name][foo]) === "undefined") {

								this.log("Section "+ name +", added item: " + serNew[name][i]);

								if (typeof(this.addCallbacks[name]) === "function") {
			                        this.log("Section "+ name +" calling ADD callback: " + newValues[name][i]);
			                        this.addCallbacks[name].call(this, this.values2Object(name, newValues[name][i]));
				                }
							} // if typeof serOld == undefined
						} // for i


					// #NEW = #OLD: they got sorted? value changed?
					} else { 
						
						var changedCalled = false;
						
						// Cycle over serialized items and look for an item
						// who is not in the old array: the changed one!
						for (var i=0; i<serNew[name].length; i++) {
							
							var foo = serNew[name][i];
							if (typeof(serOld["s_"+name][foo]) === "undefined") {

								this.log("Section "+ name +", changed item: " + oldValues[name][i] + " >> " + newValues[name][i]);
								if (typeof(this.removeCallbacks[name]) === "function") {
			                        this.log("Section "+ name +" calling CHANGE callback: " + oldValues[name][i]);
			                        this.changeCallbacks[name].call(this, this.values2Object(name, newValues[name][i]), this.values2Object(name, oldValues[name][i]));
									changedCalled = true;
				                }
								
							} // if typeof == undefined

						} // for i
						
						// Did we call the onChange callback? If some value has changed, they
						// didnt get sorted; on the other hand, if no value has changed but
						// hash has, for sure boxes got sorted.
						if (changedCalled === false) {
	                        this.log("Section "+ name +" calling SORT callback: " + newValues[name]);
							this.sortCallbacks[name].call(this, this.multipleValues2Objects(name, newValues[name]));
						}
						
						
					} // else #NEW = #OLD

                } // for name

                // this.last_parsed_anchor = document.location.hash.substring(1);
                this.current_anchor = document.location.hash.substring(1);
            } // if doc.loc.hash != current_anchor
    
            this.checking = false;
 
       	}, // check_url()

        // Calls the init callbacks, add to be precise!
        call_init_callbacks: function() {

            var values = [], i;
			values = $.extend({}, this.values, {});

            // Cycle over sections, if there's an addCallback with the same name ..
            // cycle over all subsections and call the callback with
            // the values from the current subsection
            for (var name in values) 
                if (typeof(this.addCallbacks[name]) === "function") 
                    for (i in values[name]) {
                        this.log("Section " + name + "/" + i + ", calling INIT (ADD) with values: " + values[name][i]);
                       	this.addCallbacks[name].call(this, this.values2Object(name, values[name][i]));
                    }

        }, // call_init_callbacks()

        // Fills the anchors
        get_values_from_anchor: function(currentAnchor) {

            // No anchor?  .. just return
            if (!currentAnchor)
                return;

            currentAnchor = $.base64Decode(currentAnchor);
            this.log("Parsing decoded anchor: " + currentAnchor);

            // TODO: Put some try-catch here .......
            // Divide anchor in sections

            var sections = currentAnchor.substring(1).split(this.options.separatorSections),
                foo = [],
                i, j, name;

            for (i in sections) {
                name = null;

                // Divide this section in subsections
                var subsections = sections[i].split(this.options.separatorSubSections);
                for (j in subsections) {

                    if (name === null) {
                        // First item is always the section name
                        name = subsections[j]
                        foo[name] = [];
                    } else {
                        // Finally set the values on the section 'name', on the subsection
                        // with index j-1, splitting this subsection
                        foo[name][j - 1] = new Array();
                        foo[name][j - 1] = subsections[j].split(this.options.separatorValues);
                    } // if name == null
                } // for j in subsections

            } // for i in sections

            if (this.options.debug) {
                this.log("Final anchor parse: ");
            	for (var s in foo) 
                	for (var t in foo[s]) 
                    	this.log(s + "/" + t + ": " + foo[s][t]);
            }

            // Return the object with the values
            return foo;

        }, // get_values_from_anchor()

        // Sets the AnchorMan cookie with the current anchor value
        set_cookie: function() {

            var date = new Date();
            date.setTime(date.getTime() + (this.options.cookieExpireDays * 24 * 60 * 60 * 1000));
            var expires = '; expires=' + date.toUTCString();

            document.cookie = [this.options.cookieName, '=', encodeURIComponent(this.current_anchor), expires].join('');
            document.cookie = [this.options.cookieDateName, '=', new Date(), expires].join('');
            document.cookie = [this.options.cookieLastBoxviewName, '=', encodeURIComponent(document.location.href), expires].join('');

            this.log("Setting cookie: " + [this.options.cookieName, '=', encodeURIComponent(this.current_anchor), expires].join(''));

        }, // set_cookie()

        // Gets the value of the cookie with the given name,
        // returns "" if it's not found/defined
        get_cookie_by_name: function(name) {
            var cookieValue = "", cookie, cookies;

            if (document.cookie && document.cookie != '') {

                cookies = document.cookie.split(';');
                for (var i = 0; i < cookies.length; i++) {
                    cookie = jQuery.trim(cookies[i]);
                    if (cookie.substring(0, name.length + 1) === (name + '=')) {
                        cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                        break;
                    }
                } // for i
            } // if document.cookie

            return cookieValue;

        }, // get_cookie_by_name()

        // Builds the current anchor from the hash values then saves it
        // into url's anchor and cookie, if needed
        save: function() {

            // build the anchor from the saved hash
            this.current_anchor = $.base64Encode(this.build_anchor(this.values));

			// save cookie and url's anchor if needed
            if (this.options.useUrl && document.location.hash.substring(1) !== this.current_anchor) {
                this.log("Saving new current anchor "+this.current_anchor+ " (old was "+document.location.hash+")");
				document.location.hash = this.current_anchor;
			} else {
			    this.log("@@@@@@@@@@@@@@@@@@ Not saving the anchor?? WHY");
			}
			
            if (this.options.useCookie)
            	this.set_cookie();

        }, // save()

        // resets every value and save 
        reset: function() {
            this.values = [];
            this.save();
        }, // reset()

        // Update the current anchor with the given values hash
        build_anchor: function(values) {

            var s = "#";
            for (var name in values) {

                // Add this section's name with SubSections separator, if there's elements!
				if (values[name].length > 0)
                	s += name + this.options.separatorSubSections;

                // Add values joined by the values separator and add a SubSections separator
                for (var i in values[name])
                	s += values[name][i].join(this.options.separatorValues) + this.options.separatorSubSections;

                // Trim off the trailing SubSections separator and add the sections separator
                s = s.substring(0, s.length - 1) + this.options.separatorSections;

            } // for name in values

            // Trim off the trailing sections separator
            s = s.substring(0, s.length - 1);

            this.log("Final anchor is: " + s);

            return s;
        }, // build_anchor()

        // Adds a callback to be called at page startup
        setCallbacks: function(name, callbacks) {

            if (typeof(callbacks['onAdd']) === "function")  
            	this.addCallbacks[name] = callbacks['onAdd'];

            if (typeof(callbacks['onRemove']) === "function")
            	this.removeCallbacks[name] = callbacks['onRemove'];

	        if (typeof(callbacks['onChange']) === "function")
	          	this.changeCallbacks[name] = callbacks['onChange'];

	        if (typeof(callbacks['onSort']) === "function")
	          	this.sortCallbacks[name] = callbacks['onSort'];

        }, // addCallbacks()

        // Adds a section to the values hash
        add_section: function(name, values) {

            if (this.values[name] === undefined) {
                this.log("Creating section " + name);
                this.values[name] = [];
            }

            var len = this.values[name].length;
            this.values[name][len] = values;
            this.log("Adding to section " + name + " values " + values);

            if (this.options.saveOnAdd)
            	this.save();

        }, // add_section()

        describeSection: function(name, fields) {
            this.log("Section " + name + ", described with fields: " + fields);
            this.set_section_from_values("desc_"+name, [fields]);
            this.save();
        },

        // Overwrites an entire section with the given values,
        // it's like remove/add actions at once
        set_section_from_values: function(name, values) {

            this.log("Section " + name + ", setting values to: " + values);

            this.values[name] = values;
            this.save();

        }, // set_section_from_values()

        set_section_from_object: function(name, object) {

            this.log("Section " + name + ", setting values to: " + object);

            this.values[name] = this.object2Values(name, object);
            this.save();

        }, // set_section_from_object()

        // Removes a section from the values hash
        remove_section: function(name) {

            if (this.values[name] === undefined) {
                this.log("Section " + name+", called remove but there's no section..");
                return;
            }

            var foo = {};
            for (item in this.values)
            	if (item != name)
            		foo[item] = this.values[item];

            this.values = $.extend({}, foo, {});

            this.log("Section " + name+" succesfully removed");
            if (this.options.saveOnRemove)
            	this.save();

        }, // remove_section()
        
        multipleValues2Objects: function (name, values_array) {
            var ret = [];
            for (var i = values_array.length - 1; i >= 0; i--)
                ret[i] = this.values2Object(name, values_array[i]);

            return ret;

        }, // multipleValues2Objects()
        
        values2Object: function(name, values) {

            // Return if there's no description of the given section
            if (this.values["desc_"+name] === undefined) {
                this.log("Section desc_" + name + ", called values2object but there's no section description");
                return;
            }

            var desc = this.values["desc_"+name][0], 
                ret = {};

            // Lenght mismatch?? Something went terribly wrong here??!
            if (desc.length !== values.length){
                this.log("Section desc_" + name + ", values2object length mismatch between desc ("+desc.length+") and values ("+values.length+") arrays");
                return;
            }

            this.log("Values to object "+desc+" -> "+values);

            for (var i = values.length - 1; i >= 0; i--) 
                ret[desc[i]] = values[i];
            
            return ret;
            
        }, // values2Object()
        
        object2Values: function(name, objects_array) {
            // Return if there's no description of the given section
            if (this.values["desc_"+name] === undefined) {
                this.log("Section desc_" + name + ", called values2object but there's no section description");
                return;
            }
            
            var desc = this.values["desc_"+name][0], 
                ret = [];
                
            for (var j = objects_array.length -1; j >= 0; j--) {
                ret[j] = [];
                for (var i = desc.length - 1; i >= 0; i--) {
                    var foo = desc[i];
                    ret[j][i] = objects_array[j][foo];
                }
            }

            this.log("Object to values "+desc+" -> "+objects_array+ " -> "+ret);

            return ret;
            
        }, // object2Values()
        
		log : function(w) {

            if (this.options.debug === false) return;

            if (typeof console === "undefined") {
                if ($("#debug_foo").attr('id') == null) 
                    $("body").append("<div id='debug_foo' style='position: absolute; right:2px; bottom: 2px; border: 1px solid red; font-size: 1.1em;'></div>");
                $("#debug_foo").append("<div>"+w+"</div>");
            } else {
                console.log("#AMan# "+w);
            }
        
		} // log

    }; // $.anchorMan.prototype

})(jQuery);