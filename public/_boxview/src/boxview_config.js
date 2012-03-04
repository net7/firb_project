/* Copyright (c) 2012 Net7 SRL, <http://www.netseven.it/>       */
/* This Software is released under the terms of the MIT License */
/* See LICENSE.TXT for the full text of the license.            */
/**
 * @module BoxView
 * @class BoxViewSuiteConfig
 * @description Default configuration options for the boxview suite:
 * boxview, widgets, anchorman, boxStrapper, boxToolbar, urlshortener
 * and themes.<br /><br />
 * Each of these properties can be individually overridden in your
 * local configuration file.
 */
var 
    // BoxView section name inside AnchorMan description. Just make sure
    // AnchorMan is not used by something else with this same name
    bvAMSectionName = "bv",

    /**
    * @property BoxViewSuiteConfig
    * @type object
    * @description BoxView Suite Configuration object
    */
    BoxViewSuiteConfig = {

        /**
        * @property BoxViewSuiteConfig.theme
        * @type string
        * @default standard
        * @description Theme to be applied to the boxview 
        * suite items. See the manual for more informations on how to roll 
        * your own theme. 
        */
        theme: 'standard',

        /////////////////////////////////////////////////////////////////
        ////// BoxStrapper configuration                           //////
        /////////////////////////////////////////////////////////////////

        /**
        * @property BoxViewSuiteConfig.boxStrapperConfig
        * @type object
        * @description boxview loader (boxStrapper) configuration object
        */
        boxStrapperConfig: {

            /**
            * @property BoxViewSuiteConfig.boxStrapperConfig.useStartupScreen
            * @type boolean
            * @default true
            * @description Use the fancy startup screen while boxview and boxes are
            * loading?  
            */
            useStartupScreen: true,
            
            /**
            * @property BoxViewSuiteConfig.boxStrapperConfig.closeOnDone
            * @type boolean
            * @default true
            * @description Closes automatically the loading dialog when BoxStrapper is
            * done
            */
            closeOnDone: true,

            /**
            * @property BoxViewSuiteConfig.boxStrapperConfig.waitBeforeClose
            * @type milliseconds
            * @default 1000
            * @description Wait time before closing the loading dialog
            */
            waitBeforeClose: 1000,
            
            /**
            * @property BoxViewSuiteConfig.boxStrapperConfig.animationLenght
            * @type milliseconds
            * @default 1500
            * @description Animation lenght of the loading panel
            */
            animationLenght: 1500
            
        },


        /////////////////////////////////////////////////////////////////
        ////// BoxView configuration                               //////
        /////////////////////////////////////////////////////////////////

        /**
        * @property BoxViewSuiteConfig.boxViewName
        * @type string
        * @default 'myBoxView'
        * @description Name of the BoxView object instance in the global
        * scope
        */
        boxViewName: 'myBoxView',
 
        /**
        * @property BoxViewSuiteConfig.boxViewContainer
        * @type jquery object
        * @default $('#pageContent')
        * @description The container for the BoxView, a jQuery object like 
        * $('.someClass') or $('#someId')
        */
        boxViewContainer: $('#pageContent'),

        /**
        * @property BoxViewSuiteConfig.boxViewConfig
        * @type object
        * @description All of the following css classes will be used in the HTML markup.<br/>
        * For example when a box is collapsed collapsedClass will be added as
        * css class to the box HTML markup, and removed when expanded.
        * Changing the names here means that the page must provide a css
        * stylesheet with the needed definitions, to style the elements
        * accordingly. See the manual for more informations and examples.
        */
        boxViewConfig: {

            
            /**
            * @property BoxViewSuiteConfig.boxViewConfig.collapsedClass
            * @type css class
            * @default 'collapsedBox'
            * @description Css class added to the box when collapsed
            */
    		collapsedClass: 'collapsedBox',

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.expandedClass
            * @type css class
            * @default 'expandedBox'
            * @description Css class added to the box when expanded
            */
    		expandedClass: 'expandedBox',
		
            /**
            * @property BoxViewSuiteConfig.boxViewConfig.loadingClass
            * @type css class
            * @default 'loadingContent'
            * @description Css class added while the box is loading
            */
    		loadingClass: 'loadingContent',
		
            /**
            * @property BoxViewSuiteConfig.boxViewConfig.type
            * @type css class
            * @default'defType'
            * @description Default type for typeless boxes (every type is 
            * used as box css class in the HTML markup)
            */
    		type: 'defType',

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.collapsable
            * @type boolean
            * @default true
            * @description Are boxes collapsable by default?
            */
			collapsable: true,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.draggable
            * @type boolean
            * @default true
            * @description Are boxes draggable by default?
            */
			draggable: true, 

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.closable
            * @type boolean
            * @default true
            * @description Are boxes closable by default?
            */
			closable: true,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.collapsed
            * @type boolean
            * @default false
            * @description Do boxes spawn collapsed by default?
            */
    		collapsed: false,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.collapsedWidth
            * @type pixels
            * @default 30
            * @description Box width when collapsed
            */
    		collapsedWidth: 30,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.collapsedHeaderHeight
            * @type pixels
            * @default 50
            * @description Box header's height when collapsed, usually 
            * contains tools like close/expand
            */
            collapsedHeaderHeight: 50,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.headerHeight
            * @type pixels
            * @default 30
            * @description Box header's height when expanded, contains tools and title
            */
            headerHeight: 30,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.headerTitleMargin
            * @type pixels
            * @default 4
            * @description left/right margin for the title of the box, inside 
            * its header part
            */
            headerTitleMargin: 4,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.iconSize
            * @type pixels
            * @default 16
            * @description width and heigth of for the box icons, in its header part
            */
            iconSize: 16,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.
            * @type string
            * @default 'alignMiddle'
            * @description Alignment for the box icons. Possible values are "alignMiddle",
            * "alignTop" and "alignBottom"
            */
            iconsAlignment: 'alignMiddle',

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.iconsVerticalTopMargin
            * @type pixels
            * @default 7
            * @description Top margin when the icons are displayed vertically, box
            * collapsed
            */
            iconsVerticalTopMargin: 7,
            
            /**
            * @property BoxViewSuiteConfig.boxViewConfig.iconSlotsHorizontalMargin
            * @type pixels
            * @default 7
            * @description Horizontal margin for each icon slot in the box header
            */
            iconSlotsHorizontalMargin: 7,
            
            /**
            * @property BoxViewSuiteConfig.boxViewConfig.maxWidth
            * @type boolean/pixels
            * @default false
            * @description If a pixels value is passed, boxview will force the box
            * to have at most this width.
            */
            maxWidth: false,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.minWidth
            * @type boolean/pixels
            * @default false
            * @description If a pixels value is passed, boxview will force the box
            * to have at least this width.
            */
            minWidth: false,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.boxMargin
            * @type pixels
            * @default 1
            * @description Space between boxes
            */
    		boxMargin: 1,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.resizemeImagesForceMaxHeight
            * @type boolean
            * @default true
            * @description Enforces a maximum height for images and containers having 
            * the 'resizeme' css class
            */
            resizemeImagesForceMaxHeight: true,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.resizemeImagesMinHeight
            * @type pixels
            * @default 100
            * @description Enforces a minimum height for images and containers having 
            * the 'resizeme' css class
            */
            resizemeImagesMinHeight: 100,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.resizemeImagesMaxHeight
            * @type pixels
            * @default 400
            * @description Maximum height for the .resizeme elements 
            */
            resizemeImagesMaxHeight: 400,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.resizemeImagesMargin
            * @type pixels
            * @default 15
            * @description  Margin for .resizeme elements
            */
    		resizemeImagesMargin: 15,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.animateAdd
            * @type boolean
            * @default false
            * @description Use an animation when a box is added
            */
    		animateAdd: false,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.animateRemove
            * @type boolean
            * @default false
            * @description Use an animation when a box is removed
            */
    		animateRemove: false,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.animateCollapse
            * @type boolean
            * @default false
            * @description Use an animation when a box is collapsed or expanded
            */
    		animateCollapse: false,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.animateResize
            * @type boxViewConfig
            * @default false
            * @description Use an animation when a box is resized
            */
    		animateResize: false,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.animations
            * @type boolean
            * @default true
            * @description Shortcut to set all of the animations at once, 
            * overrides any other given animate* parameter.
            */
    		animations: true,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.animationLength
            * @type milliseconds
            * @default 750
            * @description Boxview's animations length
            */
        	animationLength: 750,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.title
            * @type string
            * @default "Default box title"
            * @description Box title
            */
    		title: "Default box title",

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.verticalTitle
            * @type string
            * @default "Default vertical title"
            * @description Box title when it is vertical (collapsed)
            */
    		verticalTitle: "Default vertical title",

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.lazyResizeInterval
            * @type milliseconds
            * @default 250
            * @description Will check every lazyResizeInterval ms if boxview's container 
            * width/height are changed and resizes the boxview if needed
            */
    		lazyResizeInterval: 250,

            /**
            * @property BoxViewSuiteConfig.boxViewConfig.anchorManDescription
            * @type array of box properties
            * @default ['id', 'resId', 'type', 'collapsed', 'qstring', 'title', 'verticalTitle', 'closable', 'collapsable', 'draggable', 
                'minWidth', 'maxWidth']
            * @description Box fields to be saved into AnchorMan, encoding some in base64<br/>
            * If you need to use some strange character in your own fields 
            * (for example check AnchorManConfig separators!), prepend "encode" to
            * your veryImportantField name, like: encodeveryImportantField: true.<br/>
            * By default qstring, title and verticalTitle are encoded before getting
            * saved with anchorman
            */
            anchorManDescription: [
                'id', 'resId', 'type', 'collapsed', 'qstring', 
                'title', 'verticalTitle', 
                'closable', 'collapsable', 'draggable', 
                'minWidth', 'maxWidth'
            ],
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

        // Name of widgets object instance
        widgetsName: 'myWidgets',

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

            // true: content will be cloned and current widget collapsed
            // false: content will be moved to the new box
            cloneOnBuddy: true,

            buddyTitlePrefix: 'buddy - ',

            debug: false
        },


        /////////////////////////////////////////////////////////////////
        ////// AnchorMan configuration                             //////
        /////////////////////////////////////////////////////////////////

        // Use AnchorMan? (true/false)
        useAnchorMan: true,

        // Name of AnchorMan object instance, see top of this config file
        anchorManName: 'myAnchorman',

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
                    window[BoxViewSuiteConfig.boxViewName].addBoxFromAjax(window[BoxViewSuiteConfig.boxViewName].decodeFields(o));
    			},
    		onRemove:	
    		    function(o) {
    				window[BoxViewSuiteConfig.boxViewName].removeBox(o.id);
    			},
    		onChange: 
    			function(oldObj, newObj) {
    				// The only thing can change is the collapsed flag
    				if (oldObj.collapsed == 1 && newObj.collapsed == 0 || oldObj.collapsed == 0 && newObj.collapsed == 1) 
    					window[BoxViewSuiteConfig.boxViewName].toggleCollapseBox(newObj.id);
    			},
    		onSort:
    			function(objects_array) {
    				var ids = [];
    				// Collect just the ids from the objects array
    				for (var i=0; i<objects_array.length; i++)
    					ids[i] = objects_array[i].id;
    				window[BoxViewSuiteConfig.boxViewName].sortLike(ids);
    			}
        },


        /////////////////////////////////////////////////////////////////
        ////// boxToolbar configuration                            //////
        /////////////////////////////////////////////////////////////////

		// TODO
		useToolbar: true,
		boxToolbarName: 'myBoxToolbar',
		// TODO 
		boxToolbarConfig: {
			// TODO
			toolbarShowHistory: true,
			toolbarShowUrlShortener: true,
			toolbarShowLoading: true,
			toolbarShowPreferences: true
			
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