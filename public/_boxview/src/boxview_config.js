var 
    // BoxView section name inside AnchorMan description. Just make sure
    // AnchorMan is not used by something else with this same name
    bvAMSectionName = "bv",

    // BoxView object that will be availabe to the user! If you use
    // 'fooView' here, then you will be able to call fooView.addBoxFromAjax() and 
    // all of the methods from the fooView object.
    boxViewName = "myBoxView",

    // AnchorMan object name, same as above.
    anchorManName = "myAnchorman",

    // BoxView Suite Configuration object!
    BoxViewSuiteConfig = {

        // Theme to be applied to the boxview suite items. See the manual
        // for more informations on how to roll your own theme. The default
        // theme is called .. 'default'!
        theme: 'default',

        /////////////////////////////////////////////////////////////////
        ////// BoxStrapper configuration                           //////
        /////////////////////////////////////////////////////////////////

        boxStrapperConfig: {

            // Use the fancy startup screen while boxview and boxes are
            // loading? (true/false)
            useStartupScreen: true,
            
            // Close automatically the loading dialog when BoxStrapper is
            // done?
            closeOnDone: true,

            // Wait some time before closing the loading dialog? (milliseconds)
            waitBeforeClose: 1000,
            
            // Lenght of the fade animation (milliseconds)
            animationLenght: 1500,
            
        },


        /////////////////////////////////////////////////////////////////
        ////// BoxView configuration                               //////
        /////////////////////////////////////////////////////////////////

        // Name of BoxView object instance, see top of this config file
        boxViewName: boxViewName,

        // boxView container, a jQuery object like $('.someClass') or $('#someId')
        boxViewContainer: $('#pageContent'),

        // boxView options object
        boxViewConfig: {

            // All of the following css classes will be used in the HTML markup.
            // For example when a box is collapsed collapsedClass will be added as
            // css class to the box HTML markup, and removed when expanded.
            // Changing the names here means that the page must provide a css
            // stylesheet with the needed definitions, to style the elements
            // accordingly. See the manual for more informations and examples.
            
            // Css class added to the box when collapsed
    		collapsedClass: 'collapsedBox',

    		// Css class added to the box when expanded
    		expandedClass: 'expandedBox',
		
    		// Css class added while the box is loading
    		loadingClass: 'loadingContent',
		
    		// Default type for typeless boxes (every type is used as box css class
    		// in the HTML markup)
    		type: 'defType',

			// Is a box collapsable? (true/false)
			collapsable: true,

			// Is a box draggable? (true/false)
			draggable: true, 

			// Is a box closable? (true/false)
			closable: true,

    		// Is a box initially collapsed? (true/false)
    		collapsed: false,

    		// Box width when collapsed (pixels)
    		collapsedWidth: 30,

            // Box header's height when collapsed, usually contains tools like 
            // close/expand (pixels)
            collapsedHeaderHeight: 50,

            // Box header's height when expanded, contains tools and title (pixels)
            headerHeight: 30,

            // TODO
            headerTitleMargin: 4,

            // TODO
            iconSize: 16,

            // TODO alignMiddle / alignTop / alignBottom
            iconsAlignment: 'alignMiddle',

            // TODO 
            iconsVerticalTopMargin: 7,
            
            // TODO
            iconSlotsHorizontalMargin: 7,
            
            // Use a fixed width for every box (false/pixels) // TODOTODO, should this stay here?
            fixedWidth: false,

    		// Space between boxes (pixels)
    		boxMargin: 1,

            // Enforce max width for images with .resizeme (true/false)
            resizemeImagesForceMaxHeight: true,

            // Minimum height for the .resizeme elements (pixels) 
            resizemeImagesMinHeight: 100,

            // Maximum height for the .resizeme elements (pixels) 
            resizemeImagesMaxHeight: 400,

    		// Margin for .resizeme images (pixels)
    		resizemeImagesMargin: 15,

    		// Animations (true/false)
    		animateAdd: false,
    		animateRemove: false,
    		animateCollapse: false,
    		animateResize: false,

            // Shortcut to set all of the animations at once, overrides any other 
            // given animate* parameter. If set to a string will use the animate*
            // parameters individually (true/false/'')
    		animations: true,

            // Boxview's animations length (milliseconds)
        	animationLength: 750,

    		// Default titles for the titleless boxes
    		title: "Default box title",
    		verticalTitle: "Default vertical title",

    		// Will check every lazyResizeInterval ms if boxview's container width/height are
    		// changed and resize the boxview if needed (milliseconds)
    		lazyResizeInterval: 250,

            // If you need to use some strange character in your own fields 
            // (for example check AnchorManConfig separators!), prepend "encode" to
            // your veryImportantField name, like: encodeveryImportantField: true

            // Box fields to be saved into AnchorMan, encoding some in base64
            anchorManDescription: ['id', 'resId', 'type', 'collapsed', 'qstring', 'title', 'verticalTitle', 'collapsable', 'draggable'],
            encodeqstring: true,
            encodetitle: true,
            encodeverticalTitle: true,

            // If you need some custom function to be called on some boxview event, set them
            // here or use the onRemoveAddCallBack(), onSortAddCallBack() etc functions on 
            // the boxView object.
            // onRemove: function() {},
            // onSort: function() {},
            // onAdd: function() {},
            // onCollapse: function() {},
            // onExpand: function() {},
            // onReplace: function() {},

            // Shows some VERY verbose output about boxview behaviours using
            // browser's console.log or adding a div to the dom. (true/false)
            debug: false
        },


        /////////////////////////////////////////////////////////////////
        ////// Widgets configuration                               //////
        /////////////////////////////////////////////////////////////////

        // Use Widgets? (true/false)
        useWidgets: true,

        // Name of widgets object instance, see top of this config file
        widgetsName: 'myWidgetsHelper',

        // Widgets options object
        widgetsConfig : {

            // Widget's options defaults for the widgetify() method
            defaults: {
                draggable: true,
                collapsable: true,
                prevnext: false,
                zoomable: false,
                type: ''
            },

            // TODO
            iconSize: 20,

            // TODO
            iconSlotsHorizontalMarginLeft: 4,

            // TODO
            iconSlotsHorizontalMarginRight: 0,

            // TODO
            headerTitleMargin: 5,

            // TODO 
            iconsAlignment: 'alignMiddle',

            // Use animations to collapse widgets?
            animations: true,

            // Animation lenght
            animationsLenght: 750,

            // Collapse widgets by double-clicking on the header?
            collapseOnDoubleClick: true,

            debug: false
        },


        /////////////////////////////////////////////////////////////////
        ////// AnchorMan configuration                             //////
        /////////////////////////////////////////////////////////////////

        // Use AnchorMan? (true/false)
        useAnchorMan: true,

        // Name of AnchorMan object instance, see top of this config file
        anchorManName: anchorManName,

        // AnchorMan options object
        anchorManConfig : {

            // Characters used to separate sections, subsections and values.
            // IMPORTANT! No content value must contain any of these characters!
            // Use encodeYOURFIELDNAME in boxview options if you want that content
            // to be automatically encoded with base64. 
            separatorSections: '|',
            separatorSubSections: '@',
            separatorValues: '*',

            // Use url/cookie to store data? (true/false)
            useUrl: true,
            useCookie: false,

            // Cookies expiration date (days)
            cookieExpireDays: 365,

            // Will contain the current saved data
            cookieName: 'anchorMan',

            // Will contain data's expire date
            cookieDateName: 'anchorManDate',

            // Will contain the full URL of your last visited boxview, can be
            // used in visualizers to produce a back link
            cookieLastBoxviewName : 'LastVisitedBoxView',

            // If url's anchor and cookie both have valid values, which one 
            // to use? ('url'/'cookie')
            useUrlOrCookie: 'url',

            // Save data on every add/remove? (true/false)
            saveOnAdd: true,
            saveOnRemove: true,

            // Check browser's back button? (true/false)
            checkBackButton: true,

            // Time between each browser's back button check (milliseconds)
            checkBackButtonTimerMS: 200,

            // Shows some VERY verbose output about boxview behaviours using
            // browser's console.log or adding a div to the dom. (true/false)
            debug: false
        },
    
        // AnchorMan will use this section name for the boxview
        boxViewSectionName: bvAMSectionName,

        // Anchorman > BoxView functions, they get called at startup time
        // when the user opens a page with a long AnchorMan data URL
        // or when he hits the browser's back button
        anchorManCallbacks: {
    	    onAdd: 
    			function(o) {
    			    // Use the decodeFields() function to automatically decode the 
    			    // fields the user decided to encode, and pass the object to addBoxFromAjax()
                    window[boxViewName].addBoxFromAjax(window[boxViewName].decodeFields(o));
    			},
    		onRemove:	
    		    function(o) {
    				window[boxViewName].removeBox(o.id);
    			},
    		onChange: 
    			function(oldObj, newObj) {
    				// The only thing can change is the collapsed flag
    				if (oldObj.collapsed == 1 && newObj.collapsed == 0 || oldObj.collapsed == 0 && newObj.collapsed == 1) 
    					window[boxViewName].toggleCollapseBox(newObj.id);
    			},
    		onSort:
    			function(objects_array) {
    				var ids = [];
    				// Collect just the ids from the objects array
    				for (var i=0; i<objects_array.length; i++)
    					ids[i] = objects_array[i].id;
    				window[boxViewName].sortLike(ids);
    			}
        },

        
        /////////////////////////////////////////////////////////////////
        ////// URLShortener configuration                          //////
        /////////////////////////////////////////////////////////////////

        // Use URL Shortener??!
        useUrlShortener: true,

        // Name of URLShortener object instance, see top of this config file
        urlShortenerName: 'myUrlShortener',

        // URLShortener options object
        URLShortenerConfig: {

            // Path to reach the ZeroClipboard.swf file
            zeroClipboardPath: '../swf/ZeroClipboard.swf',

            // URL shortener dialog title
            dialogTitle: 'Shortened URL for this page',

            // Show an alert to the user when the URL has been copied to
            // the clipboard? (true/false)
            alertOnCopy: true,

            // Automatically close the URL shortener dialog window after
            // copy? (true/false)
            closeOnCopy: true,

            // Autoselect the URL in the input text element as the mouse
            // goes over it or gets focus? (true/false)
            autoSelectOnHover: true,

            // URL to reach the url shortener script
            urlShortenerURL: 'data_providers/url_shortener.php',

            // Css selector for the "shorten this URL" button, will trigger
            // an ajax call to the shortener script and open the dialog 
            // window with the shortened url
            buttonCssSelector: 'a#urlShortenerLink'
        }
    };