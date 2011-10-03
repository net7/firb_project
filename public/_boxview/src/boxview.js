(function($) {  
	
	// BoxView jQuery object constructor
	$.fn.boxView = function(opts) {

		// get "real" options merging defaults and 
		// opts given by user
		var options = $.extend($.boxView.defaults, opts);

		// Spawn a boxview for every element we are calling this on
		return this.each(function(){
			new $.boxView(this, options)
		});

	}; // $.fn.boxView()


 	// BoxView constructor
	$.boxView = function (element, opts) {
		
		// Global options for this boxView, right into the object
		this.options = $.extend({}, $.boxView.defaults, opts);

		// Boxes container
		this.container = $(element);
		this.init();

	}; // $.boxView()


	// DEFAULTS: Every boxView will be initialized with these defaults
	// if not explicitly overwritten by the user
	$.boxView.defaults = {
		// Class added to the box when collapsed
		collapsedClass: 'collapsedBox',

		// Class added to the box when expanded
		expandedClass: 'expandedBox',
		
		// Class added while the box is loading
		loadingClass: 'loadingContent',
		
		// Default type (used as class in the markup)
		type: 'defType',

		// Is a box collapsable?
		collapsable: true,

		// Is a box draggable?
		draggable: true, 

		// Is a box closable?
		closable: true,

		// Is a box initially collapsed?
		collapsed: 0,

		// Box width when collapsed, pixels
		collapsedWidth: 30,

        // Box header height when collapsed, usually contains tools like close/expand
        collapsedHeaderHeight: 50,

        // Box header height when expanded, contains tools and title
        headerHeight: 30,
        
        // TODO
        headerTitleMargin: 5,

        // TODO
        iconSize: 20,
        
        // TODO 
        iconSlotsHorizontalMargin: 8,
        
        // TODO
        iconsVerticalTopMargin: 4,

        iconsAlignment: 'alignMiddle',

        // Use a fixed width for this box (false/pixels)
        fixedWidth: false,

		// Space between boxes
		boxMargin: 1,
		
		// Pixel to substrat to box width when setting .resizeme images
		resizemeImagesMargin: 15,

        // Maximum width (in pixels) for the .resizeme elements
        resizemeImagesForceMaxHeight: true,
        resizemeImagesMaxHeight: 400,
        resizemeImagesMinHeight: 100,
        
		// Animations
		animateAdd: false,
		animateRemove: false,
		animateCollapse: false,
		animateResize: false,

        // Shortcut to set all of the animations, overrides any other 
        // given animate* parameter
		animations: true,

        // Default fields to be used for anchorman description
        anchorManDescription: ['id', 'resId', 'type', 'collapsed', 'qstring', 'draggable', 'collapsable'],

		// Will check every lazyResizeInterval ms if boxview's container width/height are
		// changed
		lazyResizeInterval: 250,

		// Default title and resource id
		title: "Default box title",
		verticalTitle: "Default vertical title",
		resId: "0",
        
        //////////////// Used internally ////////////////
		isBeingDragged: 0,
		isFirstShow: 1,
		isLoading: false,
		
		debug: false
	};

	
	$.boxView.prototype = {
		init : function() {

            // Used in almost every listener
			var self = this;

            // Will contain the reference to the boxstrapper object, for the loading utils
            this.boxStrapper = false;
            
			// Create a name for this boxView
			this.boxViewName = this.createHash();

			// Add the real boxview container (bvc) and get the jQuery object, 
			// get the son of this container so we can add as many boxViews
			// as needed on the same page
			this.container.append("<div id='"+ this.boxViewName +"' class='boxViewContainer'></div>");
			this.bvc = $('#' + this.boxViewName);

			// Current number of boxes
			this.n = 0;
			
			// Options objects for each box
			this.boxOptions = [];
			
            // Will contain informations about open and closed boxes
			this.history = [];
			
			// Connect some callbacks, if there's any in the options object. Add a function called
			// *AddCallBack (for example .onSortAddCallBack() or .onAddAddCallBack()) to the boxview
			// object, to let the user add his own callbacks
            var callBacks = ["onSort", "onAdd", "onRemove", "onCollapse", "onExpand", "onReplace"];
            for (var i in callBacks) {
                var name = callBacks[i];

                // Sets an empty array or the function supplied in the option object
                self[name + "Functions"] = (typeof(self.options[name]) === "function") ? [self.options[name]] : [];

                // Sets the *AddCallback function
                self[name + "AddCallBack"] = (function (n) {
                    return function(f) {
                        self.log("Adding a callback function to "+n+": "+ f);
                        if (typeof(f) === "function") self[n + "Functions"].push(f);
                    }})(name);
            };

            // Shortcut to set all of the animations, overrides any other 
            // given animate* parameter
            var o = this.options; 
    		if (typeof(o.animations) === 'boolean') 
        		o.animateAdd = o.animateRemove = o.animateCollapse = o.animateResize = o.animations;

            // true if we are dragging a box
            this.dragging = false;

			// Will be used to notice if box order has changed during dragNdrop, 
			// if it's changed the orderChangeFunction will be called passing this
			// order as parameter
			this.lastOrder = [];

			this.lazyResizeTimer = setInterval(function() { 
                if (self.container.height() !== self.bvc.height() || self.container.width() !== self.bvc.width()) {
                    self.log("Lazy resizing spotted a wrong sized boxview!");
                    self.resize();
					self.repaint();
                }
			}, self.options.lazyResizeTime);

			// Adding the event delegation for collapse and remove tool, bind it
			// to this div only so if there are more boxview on the same page we
			// dont bind twice every element
			$("div#"+ self.boxViewName +" div.boxHeader div .removeTool").live("click", function() { 
					self.removeBox($(this).parents('div.box').attr('id'));
					self.resize();
					return false;
				});
			$("div#"+ self.boxViewName +" div.boxHeader div .collapseTool").live("click", function() { 
					self.toggleCollapseBox($(this).parents('div.box').attr('id'));
					self.resize();
					return false;
				});
			$("div#"+ self.boxViewName +" div.box.collapsable div.boxHeader, div#"+ this.boxViewName +" div.box.collapsable div.boxCollapsedContent").live("dblclick", function() { 
				    self.toggleCollapseBox($(this).parents('div.box').attr('id'));
					self.resize();
					return false;
				});

            // Event delegation for history box items
            $("div#"+ self.boxViewName +" div.widget div.history_item span.history_action").live("click", function() {
                self.historyHandleClick(this);
            });

            $("div#"+ self.boxViewName +" div.widget div.history_item")
                .live("mouseenter", function() { self.historyHandleMouseEnter(this); })
                .live("mouseleave", function() { self.historyHandleMouseLeave(this); });

			// Little IE fix: put a timer to buffer mutiple resize events:
			// this will call resize() only after N ms after user stopped 
			// resizing the window
			var resizeTimer = null;
			$(window).resize(function(){
			    if (resizeTimer) clearTimeout(resizeTimer);
			    resizeTimer = setTimeout(function() { self.resize(); }, 100);
			});

			// Initial positioning
			this.resize();

		}, // init()
		
		// Recalculate sizes of all boxes
		resize : function() {

			// Make the box container height match its own container's height
			this.bvc.height(this.container.height());
            this.bvc.width(this.container.width());

			// No boxes -> no resize
			if (this.n == 0) {
				this.bvc.html("");
				return;
			}

			// Set all boxes height to match bvc's height, both the exterior div.box
			// and the internal div.boxContent heights!
			var fooH = this.container.height() - this.options.headerHeight;
			$(this.bvc).find('div.box').height(this.container.height());
			$(this.bvc).find('div.box div.boxContent').height(fooH);

			// num of expanded/collapsed boxes and
			// width available to the expanded boxes
			var expanded = 0, 
				collapsed = 0,
				startingExpandedWidth = expandedWidth = $(this.bvc).width();

			// If we have a collapsed box substract this collapsed box
			// width from the width available to expanded boxes
			for (i=0; i<this.n; i++)
				if (this.boxOptions[i].collapsed) {
					collapsed++;
					expandedWidth -= parseInt(this.boxOptions[i].collapsedWidth);
				} else {
					expanded++;
				}

			// subtract margins from boxes available width
			expandedWidth -= this.options.boxMargin * (this.n - 1);

			// BaseWidth is exactly the expanded boxes available width divided
			// by the num of exp. boxes, WidthRemainder is the division remainder.
			// Eg: avail width=10, exp boxes=4, BaseWidth=10/4=2, remainder=2
			var boxBaseWidth = Math.floor(expandedWidth / expanded);
			var boxWidthRemainder = Math.floor(expandedWidth % expanded);

			// foox will keep the 'left' css value of the current box, to
			// position boxes from left to right.
			// The cycle will add an extra width pixel for each box until
			// boxWidthRemainder is consumed
			var foox = 0;
			for (i=0; i<this.n; i++) {

				// calculate this box width and left position
				if (this.boxOptions[i].collapsed) {
					this.boxOptions[i].width = this.boxOptions[i].collapsedWidth;
				} else {
					// if boxWidthRemainder is greater than 0, we enlarge
					// this box width by 1 pixel, decreasing boxWidhtRemainder by 1
					var correction = (boxWidthRemainder-- > 0) ? 1 : 0;
					this.boxOptions[i].width = boxBaseWidth + correction;
				}

				this.boxOptions[i].left = foox;
				foox += this.boxOptions[i].width + this.options.boxMargin;

			} // for i

			// Finally repaint with the new values
			this.repaint();

            // Double check after repaint:
            var self = this;
			setTimeout(function() { 
		        if (startingExpandedWidth != $(self.bvc).width() || self.boxesDimensionsCheck()) {
		            self.log("Dobule check! Current BVC width doesnt match with real container width, resizing again.");
		            self.resize();
		        } else {
		            self.log("Double check BVC width passed.");
		        }
		    }, 400);
                
		}, // resize()

		boxesDimensionsCheck: function() {
			var self = this;

			for (i in self.boxOptions) {
				var b = self.boxOptions[i],
					left = parseInt($('#'+b.id).css('left').substring(-2)),
					width = parseInt($('#'+b.id).css('width').substring(-2));
				if (left != b.left || width != b.width) {
					self.log('Spotted a box with wrong dimensions!');
					return true;
				}
			}
			return false;
		},

		// Draws/animates the new positions and sizes of all boxes
		repaint : function () {
            var self = this;

			for (i=0; i<this.n; i++) {
				var box = $('#'+this.boxOptions[i].id);

                // Dont redraw everything if we are dragging .. 
                if (!this.dragging) {

				    var hid = '#'+this.boxOptions[i].id+' div.boxHeader',
				        toolsSize = $(hid+" ul li").length * this.options.iconSize;

    				// Resize the collapsed and expanded content to parent's width and height
    				if (this.boxOptions[i].collapsed) {
    				     
    				    // collapsed header height: toolsSize + a singol margin (at bottom)
    				    var headerHeight = Math.max(this.options.collapsedHeaderHeight, toolsSize), //+this.options.iconsVerticalTopMargin),
    				        h = box.height() - headerHeight - this.options.iconsVerticalTopMargin,
                            e = $('#'+this.boxOptions[i].id+' div.boxCollapsedContent');
    				    
    				    // Check if the height is different (is it a vertical resize?)
    				    if (e.height() != h) {
    					    e.height(h);
    					    e.width(this.boxOptions[i].width);

    					    $('#'+this.boxOptions[i].id+' div.boxCollapsedContent .verticalContainer').css({'width': (h)+'px'});
                        }

                        // Do this at least at every add+collapse+expand
                        // Tools: when collapsed they get their minimal height
                        $(hid+" li, "+hid+" li a").css({height: this.options.iconSize+'px', width: this.boxOptions[i].collapsedWidth+'px'});
    				    $(hid).css({'height': headerHeight+'px'});
    				    $('#'+this.boxOptions[i].id+' div.boxCollapsedContent .verticalContainer').css({'height': this.boxOptions[i].collapsedWidth+'px', bottom: -(this.options.collapsedWidth)+'px'});
    				    
    				    // Used to push down icon slots inside boxHeader
    				    $(hid).css({'padding-top': this.options.iconsVerticalTopMargin+'px'});

    				} else {
                        
    				    // Heights for expanded header, tools and A tags
    				    // TODO: make this height follow the content of the title if its too long? 
    				    $(hid+", "+hid+" li, "+hid+" li a").css({'height': this.options.headerHeight+'px'});
    				    $(hid+" li a, "+hid+" li").css({'width': this.options.iconSize+'px'});

                        $(hid+" .leftIcons").css({left: this.options.iconSlotsHorizontalMargin+'px'});
                        $(hid+" .rightIcons").css({right: this.options.iconSlotsHorizontalMargin+'px'});

                        // Reset margins used to push down icon slots when collapsed
    				    $(hid).css({'padding-top': '0px'});

                        // Size content
    				    $('#'+this.boxOptions[i].id+' div.boxContent').height(box.height() - this.boxOptions[i].headerHeight);
    				    
				    }

                    // DEBUG: one time only?
                    // Set vertical title along with its first dimensions
                    $('#'+this.boxOptions[i].id+' div.boxCollapsedContent .verticalContainer').html("<p>"+this.boxOptions[i].verticalTitle+"</p>");
                    var innerP = $('#'+this.boxOptions[i].id+' div.boxCollapsedContent .verticalContainer p'),
                        ph = innerP.height(),
                        collMargin = Math.floor((this.boxOptions[i].collapsedWidth - ph)/2);

                    // TODO: do this once
                    // Icons aligments
                    $(hid+" li a").addClass(this.options.iconsAlignment);

                    // Right and left should be set to give it some vertical margin
                   	innerP.css({"margin-right": this.boxOptions[i].headerTitleMargin+'px',
                   	            'margin-left': this.boxOptions[i].headerTitleMargin+'px'});
                   	
                   	// TODO alignment ?
                   	if (ph < this.boxOptions[i].collapsedWidth)
                   	    innerP.css({"margin-top": collMargin+'px'});
                   	else
                   	    innerP.css({"margin-top": this.boxOptions[i].headerTitleMargin+'px'});
                   	
                   	// Box Header title when expanded
                   	var titleLeft = $(hid+" .leftIcons li").length * this.options.iconSize + this.options.headerTitleMargin + this.options.iconSlotsHorizontalMargin,
                   	    titleRight = $(hid+" .rightIcons li").length * this.options.iconSize + this.options.headerTitleMargin + this.options.iconSlotsHorizontalMargin;
                   	$(hid+" .title").css({'margin-left': titleLeft+'px', 'margin-right': titleRight+'px'});
                   	
                   	var titleHeight = $(hid+" .title h3").height(),
                   	    expMargin = Math.floor((this.boxOptions[i].headerHeight - titleHeight)/2);

                    // TODO: align title
                    if (titleHeight > this.boxOptions[i].headerHeight)
                   	    $(hid+" .title h3").css({'margin-top': this.options.headerTitleMargin+'px'});
                   	else
               	        $(hid+" .title h3").css({'margin-top': expMargin+'px'});
                   	    
				
                    // width of this box minus a resizeme margin
            		var resizemeWidth = this.boxOptions[i].width - 2*this.boxOptions[i].resizemeImagesMargin;

            		// Autoresize "resizeme" class: img just set the width, divs are flash containers
            		// need to get the ratio and act concordingly
            		var img = $("#" + this.boxOptions[i].id + " img.resizeme"),
                        obj = $("#" + this.boxOptions[i].id + " div.resizeme"),
                        ratio = parseInt($(obj).find('object.IMTViewer:first').attr('ratio')) || 10000,
                        objHeight = resizemeWidth*ratio/10000;

        			if (img.width() != resizemeWidth)
        			    if (this.options.animateResize) {
        				    img.animate({width: resizemeWidth}, this.options.animationLength);
                            obj.animate({width: resizemeWidth, height: objHeight}, this.options.animationLength);
        				} else {
                            img.css({width: resizemeWidth});
                            obj.css({width: resizemeWidth, height: objHeight});
    				    }
        		
        		    // .resizing is used for images where the resizable() object is ready.
        		    // Set new Max dimensions to match box width.
        			$(".resizing").each(function(i, e) { self.resizeResizable(e, resizemeWidth); });
    				
    				// .firstresize is a freshly added image. The resizable() object needs to
    				// be initialized when the image is loaded, so we can get real 
    				// image width and height and save the ratio for later use
    				$(".firstresize").each(function(i, e) {
        				$(e).removeClass('firstresize');
        				if (typeof e.onload !== "function") 
                			e.onload = function() {
                                $(e).resizable({aspectRatio: true});
                                $(e).addClass('resizing');
                			    $(e).data('originalRatio', e.height / e.width);

                                self.resizeResizable(e, resizemeWidth);
                			};
            		});

                } // if !this.dragging

				// First time we display this box, animate or not?
				if (this.boxOptions[i].isFirstShow) {

					if (this.options.animateAdd == true) {
						box.css({width: '10px', left: (this.boxOptions[i].left + this.boxOptions[i].width)});
						box.animate({width: this.boxOptions[i].width, left: this.boxOptions[i].left}, this.options.animationLength, function() {
						    WidgetsHelper.resizeWidgets();
						});
					} else {

					    // Added a micro animation of 10msecs to avoid IE's flaws when rendering
					    // Ajax-added content........ thanks IE!
						box.animate({width: this.boxOptions[i].width, left: this.boxOptions[i].left}, 10);
					}
						
					this.boxOptions[i].isFirstShow = false;

				} else {

					// Dont redraw the items which are being dragged!
					if (!this.boxOptions[i].isBeingDragged) 
						if (this.options.animateResize == true) {
							box.stop().fadeTo(0, "1.0")
							    .animate({width: this.boxOptions[i].width, left: this.boxOptions[i].left}, 
							        this.options.animationLength,
							        function() { WidgetsHelper.resizeWidgets();
        						});
						} else {
							box.css({width: this.boxOptions[i].width, left: this.boxOptions[i].left});
							WidgetsHelper.resizeWidgets();
						    
						}
					WidgetsHelper.resizeWidgets();

				} // if isFirtShow()

			} // for i=0..this.n

		}, // repaint()

        resizeResizable : function (e, availableWidth) {
            var ratio = $(e).data('originalRatio'),
		        minH = this.options.resizemeImagesMinHeight,
		        minW = Math.floor(minH / ratio),
		        currW = maxW = availableWidth,
		        currH = maxH = Math.floor(ratio * availableWidth);

            if (this.options.resizemeImagesForceMaxHeight) {
                currH = Math.min(maxH, this.options.resizemeImagesMaxHeight);
                currW = Math.floor(currH/ratio);
            }
		    
		    if ($(e).height() !== currH && $(e).width() !== currW && currW !== 0 && currH !== 0) {
                $(e).css({height: currH+'px', width: currW+'px'});
                $(e).resizable("widget").css({height: currH+'px', width: currW+'px'});
		        $(e).resizable("option", {minHeight: minH, maxHeight: maxH, minWidth: minW, maxWidth: maxW});
		    }
        }, // resizeResizable()
		
		// Will add a box and call the callbacks
		addBox : function(boxContent, opts) {

			for (x in opts)  
				if (opts[x] === 'false') 
					opts[x] = false; 

			this.log("Calling addBox with "+opts);

			if (typeof(opts) !== 'undefined')
			 	if (typeof(opts.resId) !== 'undefined' && opts.resId !== this.options.resId) 
                    // Flash the box if this resId is already open!
			 		if (this.getIdFromResId(opts.resId) !== -1) {
						this.log("There's already a box with resId="+opts['resId']+" .. flashing it");
						// TODO: add an option to animate the flash window or flash it always ..
						// if (this.options.animateResize === true)
						$('#' + this.getIdFromResId(opts.resId)).fadeTo(200, "0.3").fadeTo(200, "1.0").fadeTo(200, "0.3").fadeTo(200, "1.0");
							
						return false;
					}

			// If there's a position supplied, copy the actual boxOptions hash
			// leaving a blank space in the Nth position, then do the
			// usual stuff on boxOptions[n]
			var n = NaN;
			if (typeof(opts) !== "undefined")
				n = parseInt(opts.position);

			var foo = {};
			foo['boxOptions'] = {};
			if (n >= 0) {

				// Cycle over all boxes and just skip the nth box
				for (i=0, j=0; j<this.n; i++) 
					if (i !== n) 
						foo.boxOptions[i] = $.extend({}, this.boxOptions[j++], {});
						
				// Copy back the options in boxOptions
				this.boxOptions = $.extend({}, foo.boxOptions, {});

			} else {
				// Otherwise just add it in the last position
				n = this.n;
			}

			this.log("Adding a box in position "+n);

			// Extend default options with those given by user
			this.boxOptions[n] = $.extend({}, this.options, opts);
			var boxopt = this.boxOptions[n];

			// If there's already an id, use it
			if (typeof(boxopt['id']) === "undefined")
				boxopt['id'] = this.createHash(5);

            // If we are using the default, use the id as resId value
            if (boxopt.resId === $.boxView.defaults.resId)
                boxopt.resId = boxopt['id'];

            // Fix unusual values for collapsed flag
            if (boxopt['collapsed'] === true || boxopt['collapsed'] === 1 || boxopt['collapsed'] === '1')
                boxopt['collapsed'] = 1;
            else
                boxopt['collapsed'] = 0;
            
            // Content of the box and its full HTML markup
			boxopt['content'] = boxContent;
			boxopt['html'] = this.getBoxHtml(n);

			// Adding the box to the boxviewcontainer
			this.bvc.append(boxopt['html']);
			this.n = this.n + 1;

			// Make boxes draggable, sets some properties and attach functions
			// to handle drag, dragstart and dragend inside boxView.
			var self = this;
			if (boxopt['draggable'])
				$('#'+boxopt['id']).draggable({ 
					containment: 'parent', 
					handle: '.boxDragHandle',
					cursor: 'move',
					zIndex: 20,
					stack: 'div.box',
					opacity: 0.70,
					start: function() { self.dragStart($(this).attr('id')); },
					drag: function() { self.drag($(this).attr('id')); },
					stop: function() { self.dragStop($(this).attr('id')); }
				});

			/*
			// DEBUG: this crashes IE ..... fun.
			$("#"+boxopt['id']+" .resizable:not[.resizing]").each(function(i, e) {
				self.log('estiqaatsi');
			    $(e).addClass('firstresize');
				return false;
			});
			*/

			this.log("Added box "+boxopt['id']+" in position " + this.n + " with resId " +  boxopt['resId']);

			// Calculate sizes again
			this.resize();

            this.historyAdd(boxopt);
			
			// Call the onAdd callback
			var f = this.onAddFunctions;
			if (f.length > 0) 
			    for (var i = f.length - 1; i >= 0; i--)
			        if (typeof(f[i]) === "function")
			            f[i].call(this, boxopt.resId);

		}, // addBox()


        // TODO: initial addBoxFromAjax function, to make the user skip the ajax call and
        // control them better
        addBoxFromAjax : function (opts) {
            var self = this;

            // DEBUG: put this into some fixed variable and not into a string
            if (opts.qstring === "history") 
                return false;

            if (self.boxStrapper !== false)
                self.boxStrapper.addLoadingItem("Box: "+opts.title);

		    // DEBUG: random string to trick the cache
		    opts.qstring += '&ie='+((Math.random()*100000)|0);

            // TODO: make some sanity checks, is the box already open? Flash and return?
            // are the informations correct? Set loading?
            $.ajax({
                type: 'GET',
                url: opts.qstring,
                success: function(data) {
	  				self.addBox(data, opts);  
                    if (self.boxStrapper !== false)
                        self.boxStrapper.removeLoadedItem("Box: "+opts.title);
                    return false;
                }
            });
            
        }, // addBoxFromAjax

        getBoxHtml : function (n) {
            var b = this.boxOptions[n],
            	html = "<div class='box " + b['type']+" ";

            html += (b['collapsed']) ? 'collapsed ' : 'expanded ';
            html += (b['collapsable']) ? 'collapsable ' : '';
            html += (b['draggable']) ? 'draggable ' : '';
            html += (b['closable']) ? 'closable ' : '';

            html += "' id='"+b['id']+"'>"+
            		"<div class='boxHeader boxDragHandle'>"+
            			"<div class='leftIcons'>"+
            				"<ul>";

			if (b['collapsable'])
            	html += "<li class='collapseTool'><a class='collapseTool' href=''>Collapse</a></li>";

			html += 		"</ul>"+
            			"</div>"+
            			"<div class='title'>"+
            				"<h3 class='boxHeaderTitle'>" + b['title'] + "</h3>"+
            			"</div>"+
            			"<div class='rightIcons'>"+
            				"<ul>";
							
			if (b['closable'])
    			html += "<li class='removeTool'><a class='removeTool' href=''>Close</a></li>";

			html +=			"</ul>"+
            			"</div>"+
            		"</div>"+
            		"<div class='boxContent'>"+b['content']+"</div>"+
            		"<div class='boxCollapsedContent'><div class='verticalContainer boxDragHandle'></div></div>"+
            		"</div>";
            return html;
        }, // getBoxHtml()

        // Replaces a box's content
        replaceBoxContent: function(boxId, opts) {

            for (i=0; i<this.n; i++) {
                var b = this.boxOptions[i];
				if (b['id'] == boxId) {

				    b.resId = opts.newResId;
				    b.content = opts.newContent;
				    b.title = opts.newTitle;
				    b.verticalTitle = opts.newVerticalTitle;
				    b.qstring = opts.newQstring;
				    
				    $('div#'+boxId+" div.boxContent").html(opts.newContent);
				    $('div#'+boxId+" h3.boxHeaderTitle").html(opts.newTitle);
				    
        			// Call the onReplace callback
        			var f = this.onReplaceFunctions;
        			if (f.length > 0) 
        			    for (var i = f.length - 1; i >= 0; i--)
        			        if (typeof(f[i]) === "function")
        			            f[i].call(this, b.resId);

                    // Call resize mainly for the .resizeme images
        			this.resize();
        			return true;
				} // if 'id' = boxId
			} // for i
			
			return false;
            
        }, // replaceBoxContent

        // Updates the internal 'content' field to reflect external HTML
        // injections
        checkBoxContent: function(boxId) {
			for (var i=0; i<this.n; i++) {
			    var b = this.boxOptions[i];
				if (b['id'] == boxId) {
					if (b.content != $('div#'+boxId+" div.boxContent").html())
					    b.content = $('div#'+boxId+" div.boxContent").html();
					return true;
				}
			}
			return false;
        },


		// Start and stop Drag function just set/unset the isBeingDragged flag
		// into the boxOptions hash
		dragStart: function (id) {
    
            this.bvc.find('div.box').css({"z-index": 1});
			$('#'+id).css({"z-index": 10});

			this.log('DragStart on id '+id);
            
			this.lastOrder = [];
			for (var i=0; i<this.n; i++) {
			
				// Set last order at dragstart, so at drag end we can notice
				// a change
				this.lastOrder[i] = this.boxOptions[i].id;

				if (this.boxOptions[i].id == id) {
					this.boxOptions[i].isBeingDragged = true;
                    this.dragging = true;
				}
			} // for i

		}, // startDrag


		dragStop: function (id) {

			var newOrder = [],
				isOrderChanged = false;
			
			for (var i=0; i<this.n; i++) {

				// Is the new order different from the last one?
				newOrder[i] = this.boxOptions[i].id;
				if (this.lastOrder[i] != newOrder[i])
					isOrderChanged = true;

				if (this.boxOptions[i].id == id) {
					this.boxOptions[i].isBeingDragged = false;
					this.dragging = false;
				}
			}

			if (isOrderChanged) {
				this.lastOrder = newOrder;

    			// Call the onSort callback
    			var f = this.onSortFunctions;
    			if (f.length > 0) 
    			    for (var i = f.length - 1; i >= 0; i--)
    			        if (typeof(f[i]) === "function")
    			            f[i].call(this);
				
			} // if isOrderChanged

			this.resize();
		}, // stopDrag

		// Called at every drag movement of the mouse.. so.. a lot!
		drag : function(id) {

			// Leftmost and rightmost x coordinate of the dragged box, along
			// with its central point x coordinate.
			// drag_box is the index of the dragged box into the boxOptions array,
			// moving_box is the index of the box that should move to make room to drag_box
			var drag_left = parseInt($('#'+id).css('left')),
				drag_right = drag_left + parseInt($('#'+id).css('width')),
				drag_middle = Math.floor((drag_left+drag_right)/2),
				drag_box = -1,
				moving_box = -1,
				changed = false;

			// Find what's the box we are dragging
			for (var i=0; i<this.n; i++)
				if (this.boxOptions[i].id == id)
					drag_box = i;

			// Dragged box was on this coordinates before drag happened
			var old_drag_left = this.boxOptions[drag_box].left,
				old_drag_right = this.boxOptions[drag_box].left + this.boxOptions[drag_box].width;

			// Just skip all boxes but previous and next to dragged box
			for (var i=0; i<this.n; i++) {
				if (i != drag_box && (i==drag_box+1 || i==drag_box-1)) {

					// Current box left, right and middle coordinates
					var left = parseInt(this.boxOptions[i].left),
						right = parseInt(this.boxOptions[i].width) + left,
						middle = Math.floor((left+right)/2);
					
					// Dragging in right direction
					if (old_drag_left < left && drag_right > middle) {
						changed = "right";
						moving_box = i;

						this.boxOptions[moving_box].left = old_drag_left;
						this.boxOptions[drag_box].left += this.boxOptions[moving_box].width + this.options.boxMargin;
					} 

					// Dragging in left direction
					if (old_drag_right > right && drag_left < middle) {
						changed = "left";
						moving_box = i;

						if (this.boxOptions[i].draggable === false) 
							return false;
							
						var foo = this.boxOptions[moving_box].left;
						this.boxOptions[moving_box].left += this.boxOptions[drag_box].width + this.options.boxMargin;
						this.boxOptions[drag_box].left = foo;
					} 
					
				} // if boxOptions[i].id != id
			} // for i

			// Finally switch boxOptions elements and repaint() !
			if (changed != false) {
				var foo = $.extend({}, this.boxOptions[moving_box], {});
				this.boxOptions[moving_box] = this.boxOptions[drag_box];
				this.boxOptions[drag_box] = foo;
				this.repaint();
			} // if changed != -1
			
		}, // drag

        setBoxStrapper : function(bs) {
            this.boxStrapper = bs;
        },

		// Used to toggle the loading class
		setLoading : function(id, val) {
			for (i=0; i<this.n; i++) {
			    var b = this.boxOptions[i];
				if (b['id'] == id) {
					b.isLoading = val;
					if (val) 
						$('#' + id).addClass(b.loadingClass);
					else 
						$('#' + id).removeClass(b.loadingClass);
					
					this.checkBoxContent(id);
					return;
				}
			}
			return;
		},

        isLoading : function(id) {
			for (i=0; i<this.n; i++) 
				if (this.boxOptions[i]['id'] == id) 
				    return this.boxOptions[i]['isLoading'];
			return false;
        },

        openHistoryBox : function() {
            var content = widget = "",
                opts, openBoxesIds = [];

            // Open boxes
            for (var i = this.n - 1; i >= 0; i--) 
                if (this.boxOptions[i].resId !== 'history') {
                    var classes = (this.boxOptions[i].collapsed? "collapsed " : "") 
                                  + " history_item " +this.boxOptions[i].type;
                              
                    widget += "<div class='"+classes+"' about='"+this.boxOptions[i].id+"'>"+
                                "<span class='history_status'></span>"+ this.boxOptions[i].verticalTitle + "</div>";
                    openBoxesIds.push(this.boxOptions[i].resId);
                }

            // TODO: add some sanity check for WidgetsHelper.. and dont use widgets if
            // there's no support..
            content += WidgetsHelper.widgetify("Open boxes", widget, 
                        {type: "open_boxes", draggable: true, collapsable: true, prevnext: false, zoomable: false});

            // Closed boxes
            widget = "";
            for (var i = this.history.length - 1; i >= 0; i--) 
                // if it's not the history box itself and -1, current resId is not present in openBoxesIds
                if (this.history[i].resId !== 'history' && $.inArray(this.history[i].resId, openBoxesIds) === -1) {
                    var classes = this.history[i].type + "closed history_item";
                    widget += "<div class='"+classes+"' about='"+this.history[i].id+"'>"+
                                "<span class='history_status'></span>"+ this.history[i].verticalTitle + "</div>";
                }

            content += WidgetsHelper.widgetify("Closed boxes", widget, 
                        {type: "closed_boxes", draggable: true, collapsable: true, prevnext: false, zoomable: false});

            opts = {title: "History box", verticalTitle: "Session History", type: "history", qstring: "history", resId: "history" };
            this.addBox(content, opts);

        }, // openHistoryBox()

        historyToggleCollapsed : function (id) {
            
            $('div.widget.open_boxes div.history_item[about="'+id+'"]').toggleClass('collapsed');
        }, // updateHistoryBox()

        historyRemove : function (id) {

            // Clone the item in open_boxes to closed_boxes and slide it up
            $('div.widget.open_boxes div.history_item[about="'+id+'"]').clone()
                .removeClass('collapsed').addClass('closed')
                .appendTo('div.widget.closed_boxes div.widgetContent')
                .slideUp(0);

            // Now slideToggle both, when done remove the open_boxes item
            $('div.widget div.history_item[about="'+id+'"]').slideToggle(750, 'easeOutQuint', 
                function() { $('div.widget.open_boxes div.history_item[about="'+id+'"]').remove(); });
            
        },

        historyAdd : function (opts) {
            
            if (opts.resId === 'history') 
                return false;
            
            // Dont push again if we open/close the same box, just move it in
            // the history box
            for (var i = this.history.length - 1; i >= 0; i--) 
                if (this.history[i].resId === opts.resId) {
                    var old_id = this.history[i].id,
                        new_id = opts.id;

                    // Clone the item in closed_boxes into open_boxes and slide it up
                    $('div.widget.closed_boxes div.history_item[about="'+old_id+'"]')
                        .clone()
                        .removeClass('closed')
                        .appendTo('div.widget.open_boxes div.widgetContent')
                        .slideUp(0);

                    // Now slideToggle both, when done remove the closes_boxes item
                    $('div.widget div.history_item[about="'+old_id+'"]')
                        .slideToggle(750, 'easeOutQuint', function() { $('div.widget.closed_boxes div.history_item[about="'+old_id+'"]').remove(); })

                    // Now the box with this same resId has a new id, change 
                    // it in the history box and in the history array
                    $('div.widget.open_boxes div.history_item[about="'+old_id+'"]').attr('about', new_id);
                    this.history[i].id = opts.id;
                    return false;
                }
            
            // Add the item to the history array
            this.history.push(opts);

            // Add an item in the history box, if open
			// TODO: what's this! Rewrite this mess .. !!
            var classes = (opts.collapsed ? "collapsed " : "") +
						 	" history_item " +
							opts.type + " " +
							(opts.collapsable ? 'collapsable ' : '') +
				            (opts.draggable ? 'draggable ' : '') +
				            (opts.closable ? 'closable ' : ''),
           		item = "<div class='"+classes+"' about='"+opts.id+"'>"+
                    	"<span class='history_status'></span>"+ opts.verticalTitle + "</div>";

            $(item).appendTo('div.widget.open_boxes div.widgetContent').slideUp(0).slideDown(750);



        }, // historyAdd()

        // Called when the user clicks on some .history_item .history_action
        // span item
        historyHandleClick : function (item) {
            var history_item = $(item).parent('div.history_item')
                box = this.getOptsFromHistoryId($(history_item).attr('about'));

            this.historyHandleMouseLeave(history_item);

            if ($(item).hasClass('open')) {
                box.collapsed = false;
                this.addBoxFromAjax(box);
            } else if ($(item).hasClass('close')) {
                this.removeBox(box.id);
            } else if ($(item).hasClass('collapse') || $(item).hasClass('expand')) {
                this.toggleCollapseBox(box.id);
            } else if ($(item).hasClass('maximize')) {
                this.maximizeBox(box.id);
            }

        }, // historyHandleClick()

        // Called when the mouse enters an .history_item
        historyHandleMouseEnter : function (item) {

            if ($(item).hasClass('closed')) {
				if ($(item).hasClass('closable'))
					$(item).append("<span class='history_action open'>Open</span>");
            } else {
				if ($(item).hasClass('closable'))
                	$(item).append("<span class='history_action close'>Close</span>");

				if ($(item).hasClass('collapsable'))
					if ($(item).hasClass('collapsed'))
						$(item).append("<span class='history_action expand'>Expand</span>");
					else
						$(item).append("<span class='history_action collapse'>Collapse</span>");

                $(item).append("<span class='history_action maximize'>Maximize</span>");
            }
        }, // historyHandleMouseEnter()

        // Called when the mouse leaves an .history_item
        historyHandleMouseLeave : function (item) {
            $(item).find('span.history_action').remove();
        }, // historyHandleMouseLeave()

		// Removes the box with the given id from the box view container
		removeBox : function (id) {

			// Will contain the options without the removed box
			var foo = {}, 
			    removedResid = this.getResIdFromId(id);
			foo['boxOptions'] = {};

			// Cycle over all boxes and just dont copy the selected
			// id box
			for (i=0,j=0; i<this.n; i++)
				if (this.boxOptions[i]['id'] != id) 
					foo.boxOptions[j++] = $.extend({}, this.boxOptions[i], {});

			// Copy back the options in the boxOptions space
			this.boxOptions = $.extend({}, foo.boxOptions, {});
			this.n--;

			// Remove the element from DOM
			if (this.options.animateRemove == true)
			    $("#"+id).fadeOut(this.options.animationLength).remove();
            else
			    $('#'+id).remove();

            this.historyRemove(id);

			// Call the onRemove callback
			var f = this.onRemoveFunctions;
			if (f.length > 0) 
			    for (var i = f.length - 1; i >= 0; i--)
			        if (typeof(f[i]) === "function")
			            f[i].call(this, removedResid);

			this.resize();

		}, // removeBox()
		
		// Toggle the collapse flag: sets true if it's false
		// and vice-versa
		toggleCollapseBox : function (id) {
            var self = this;
			// Cycling over all boxes options, as soon as we find the given
			// box we toggle its collapsed flag, add/remove collpsed/expanded
			// classes and return
			for (i=0; i<this.n; i++)
				if (this.boxOptions[i]['id'] === id) {

                    // Update the history box if needed
                    this.historyToggleCollapsed(id);

					// Expanding the box
					if (this.boxOptions[i].collapsed) {

						this.boxOptions[i].collapsed = 0;

						if (this.options.animateCollapse) {
						    $('#' + id).removeClass("collapsed").addClass("expanded");
                            
                            $('#'+id+' li').fadeOut(0)
                            $('#'+id+' .boxContent, #'+id+' .title').fadeOut(0)
                                .fadeIn(this.options.animationLength, function() {
                                    $('#'+id+' li').fadeIn(self.options.animationLength);
                                });
                        } else
						    $('#' + id).removeClass("collapsed").addClass("expanded");

            			// Call the onExpand callback
            			var f = this.onExpandFunctions;
            			if (f.length > 0) 
            			    for (var j = f.length - 1; j >= 0; j--)
            			        if (typeof(f[j]) === "function") 
								    setTimeout((
										function(ob, resId) {
											return function() { 
												ob.call(self, resId) 
											}
										})(f[j], this.boxOptions[i].resId),
										20);

					// Collapsing the box
					} else {
						
						this.boxOptions[i].collapsed = 1;
						if (this.options.animateCollapse) {
                            $('#'+id+' li').fadeOut(0);
                            $('#' + id).removeClass("expanded").addClass("collapsed");
                            $('#'+id+' .verticalContainer').fadeOut(0)
                                .fadeIn(this.options.animationLength, function() {
                                    $('#'+id+' li').fadeIn(self.options.animationLength);
                                });
                            $('#'+id+' .boxContent').fadeOut(0);
						} else 
						    $('#' + id).removeClass("expanded").addClass("collapsed");

            			// Call the onCollapse callback
            			var f = this.onCollapseFunctions;
            			if (f.length > 0) 
            			    for (var j = f.length - 1; j >= 0; j--)
            			        if (typeof(f[j]) === "function")
								    setTimeout((
										function(ob, resId) {
											return function() { 
												ob.call(self, resId) 
											}
										})(f[j], this.boxOptions[i].resId),
										20);

					}
        			this.resize();

					return;
				} // if boxOptions[i][id] == id
		}, // toggleCollapseBox()

        // Maximize a box expanding it and minimizing all the others
        maximizeBox : function (id) {
            for (var i=0; i<this.n; i++) {
				if (this.boxOptions[i].id === id) {
                    if (this.boxOptions[i].collapsed === 1)
                        this.toggleCollapseBox(id);
			    } else {
                    if (this.boxOptions[i].collapsed === 0)
                        this.toggleCollapseBox(this.boxOptions[i].id);
			    }
		    }
        }, // maximizeBox()

		// Returns the box html id from the given Resource ID
		getIdFromResId: function (resId) {
			for (var i=0; i<this.n; i++)
				if (this.boxOptions[i].resId == resId)
					return this.boxOptions[i].id;
			return -1;
		}, // getIdFromResId()

		// Returns the box options object from an id, 
		getOptsFromHistoryId: function (id) {
            for (var i = this.history.length - 1; i >= 0; i--) 
                if (this.history[i].id === id) 
                    return this.history[i];

            return false;

		}, // getOptsFromHistoryId()

        getOptsFromId: function (resId) {
			for (var i=0; i<this.n; i++)
				if (this.boxOptions[i].resId == resId)
					return this.boxOptions[i];
			return -1;
        }, // getOptsFromId()

		// Returns the resource id from the given html ID
		getResIdFromId: function (id) {
			for (var i=0; i<this.n; i++)
				if (this.boxOptions[i].id == id)
					return this.boxOptions[i].resId;
			return -1;
		}, // getResIdFromId()

		// Gets an object in the anchorman format: an array of arrays, 
		// containing info on boxes
		getAnchorManDesc : function() {
			var foo = [];
			for (var i=0; i<this.n; i++) 
		        foo[i] = this.encodeFields(this.boxOptions[i]);

			this.log("getAnchorManDesc: "+foo);
			return foo;
		}, // getAnchorManDesc()

        // Takes an object like a boxOptions one (with all of the users fields as well) and
        // encodes the fields the user decided to encode through the init option object
        encodeFields : function (o) {
            var foo = {};
            for (var j = this.options.anchorManDescription.length - 1; j >= 0; j--) {
                var field = this.options.anchorManDescription[j];
                if (typeof(o[field]) !== "undefined") {
                    if (typeof(this.options['encode'+field]) !== 'undefined' && this.options['encode'+field]) {
                        foo[field] = $.base64Encode(o[field]);
                    } else {
                        foo[field] = o[field];
                    }       
                } else { this.log("ERROR: trying to encode unknown field "+field); }
            }; // for j
            return foo;
        },

        // Same as above, just decoding
        decodeFields : function (o) {
            var foo = {};
            for (var j = this.options.anchorManDescription.length - 1; j >= 0; j--) {
                var field = this.options.anchorManDescription[j];
                if (typeof(o[field]) !== "undefined") {
                    if (typeof(this.options['encode'+field]) !== 'undefined' && this.options['encode'+field]) {
                        foo[field] = $.base64Decode(o[field]);
                    } else {
                        foo[field] = o[field];
                    }       
                } else { this.log("ERROR: trying to decode unknown field "+field); }
            }; // for j
            return foo;
        },

        getQStringFromId : function(id) {
			for (var i=0; i<this.n; i++)
				if (this.boxOptions[i].id == id)
					return (this.options.encodeResId == true) ? $.base64Encode(this.boxOptions[i].qstring) : this.boxOptions[i].qstring; 
			return -1;
        },

		// gets an array of boxes ids and sorts the boxes accordingly
		sortLike : function(newOrder) {
			
			// Giving an order whose size doesnt match current boxes number ..
			// .. just return.
			if (newOrder.length !== this.n) {
			    this.log("ERROR SortLike called with a wrong sized array? ..");
				return;
            }
            			
			var foo = {};
			foo['boxOptions'] = {};

			// Crappy cycle to set the boxes in the right order
			for (var i=0; i<this.n; i++) 
				for (var j=0; j<this.n; j++) 
				 	if (this.boxOptions[j]['id'] == newOrder[i]) 
						foo.boxOptions[i] = $.extend({}, this.boxOptions[j], {});

			// Copy back the options in the boxOptions space
			this.boxOptions = $.extend({}, foo.boxOptions, {});
			this.lastOrder = newOrder;
			this.resize();
		}, // sortLike()

		// Toggles animations on or off
		toggleAnimations : function() {
		    var o = this.options;
			o.animations = !o.animations;
			o.animateAdd = !o.animateAdd;
			o.animateRemove = !o.animateRemove;
			o.animateCollapse = !o.animateCollapse;
			o.animateResize = !o.animateResize;
		},
		
		setAnimations : function (value) {
		    var o = this.options;
			o.animateAdd = value;
			o.animateRemove = value;
			o.animateCollapse = value;
			o.animateResize = value;
		},

		setResizemeImagesWidth : function (value) {
		    value = parseInt(value);
		    if (value == 0) 
		        this.options.resizemeImagesForceMaxWidth = false
		    else {
		        this.options.resizemeImagesForceMaxWidth = true;
		        this.options.resizemeImagesMaxWidth = value;
	        }
	        this.repaint();
		},

		// Generates an N items random hash code, to use as box id
		createHash : function(n) {
			var i=0, 
				str="";
				
			if (typeof(n) == "undefined")
				n = 10;

			while (i++ <= n) {
				var rnd = Math.floor(Math.random()*36);
				str += "abcdefghijklmnopqrstuvz0123456789".substring(rnd, rnd+1);
			}
			return str;
		}, // createHash()
		
		log : function(w) {

            if (this.options.debug === false)
                return;

            if (typeof console == "undefined") {
                if ($("#debug_foo").attr('id') == null) 
                    $("body").append("<div id='debug_foo' style='position: absolute; right:2px; bottom: 2px; border: 1px solid red; font-size: 1.1em;'></div>");
                $("#debug_foo").append("<div>"+w+"</div>");
            } else {
                console.log("#BV# "+w);
            }
        
		} // log
		
	}; // $.boxView.prototype
	
})(jQuery);