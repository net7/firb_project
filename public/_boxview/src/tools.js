function BoxStrapper(path, config) {

    if (typeof(path) !== 'undefined') {
        this.path = path;
        this.log("Setting path to "+path);
    } else
        this.path = '../'
        
    if (typeof(config) !== 'undefined') 
        this.userConfig = config;

    this.startedAt = new Date().getTime();
    this.showOverlay();
    this.init();
};

BoxStrapper.prototype = {

    // Items currently being loaded
    loadingItems: 0, 
    // Total number of items to load
    itemsToLoad: 0, 
    // Items already loaded
    loadedItems: 0,
    // Queue with items to load, indexed by prio
    loadingQueue: [],
    // Lowest and highest prio
    lowestPrio: 99999, 
    highestPrio: -1,
    levelsDone: 0,

    // Time in ms to signal a job as 'done'. Used to call the remove
    // callback after a function or event which doesnt fire a proper
    // onLoad event
    forceRemoveTime: 100,

    // Will be set to true when and if the startup screen gets initialized
    isStartupScreenActive: false,
    isQueueDone: false,

    debug: false,

    init: function() {
        var self = this;

        // The browser can load js and css together.. 
        self.loadCss(10, "BoxView Stylesheet", 'css/boxview.css');
        self.loadCss(10, "Widgets Stylesheet", 'css/widgets.css');

        // Load jquery if it's not already loaded
        if (typeof($) !== "function") 
            self.loadScript(10, "JQuery core", 'jq/jquery.js');

        // Load jquery-ui if it's not already loaded, after jquery to avoid UI to be
        // initialized before jQuery ..
        if (typeof($) !== "function" || typeof($.ui) !== "object") 
            self.loadScript(20, "JQuery UI", 'jq/jquery-ui.js');

        // Load the configuration file
        if (typeof(BoxViewSuiteConfig) !== 'object') 
            self.loadScript(30, "Suite config", 'src/boxview_config.js');

        self.loadCall(35, "User's custom config files", 
                    function() {
                        self.loadScriptCheck(36, "User's configuration files config.js", 'config.js', 37);
                        self.loadScriptCheck(36, "User's configuration files ../config.js", '../config.js', 37);
                        if (typeof(self.userConfig) !== 'undefined')
                            self.loadScriptCheck(37, "User's configuration via BoxStrapper()", self.userConfig, 38);
                    });

        // Load the css at run time, when we know which theme to use
        self.loadCall(40, "Theme stylesheets", 
                    function() {
                        self.loadScriptCheck(41, "Theme's configuration files", self.path+'themes/'+BoxViewSuiteConfig.theme+'/config.js', 42);
                        self.loadCss(41, "Theme Jquery UI stylesheet", 'themes/'+BoxViewSuiteConfig.theme+'/jquery-ui/jquery-ui-1.8.10.custom.css');
                        self.loadScript(41, "Theme general config", 'themes/'+BoxViewSuiteConfig.theme+'/config.js');
                        self.loadCss(41, "Theme general stylesheet", 'themes/'+BoxViewSuiteConfig.theme+'/css/style.css');
                    });

        // Show the startup screen if it's needed, AFTER the css.. 
        // DEBUG: if the css is loaded after the startup screen.. it screws up .. :\
        self.loadCall(50, "Showing startup screen", 
                    function() { 
                        if (BoxViewSuiteConfig.boxStrapperConfig.useStartupScreen) 
                            self.addStartupScreenCode();
                        $('#foo_remove_me').fadeOut();
                    });

        // Let's get all the code we need
        self.loadScript(60, "URL Shortener core", 'src/urlshortener.js');
        self.loadScript(60, "BoxView core", 'src/boxview.js');
        self.loadScript(60, "AnchorMan core", 'src/anchorman.js');
        self.loadScript(60, "Base64 Lib", 'jq/base64.js');
        self.loadScript(60, "Widgets core", 'src/widgets.js');

        self.loadCall(70, "Initializing Components", function() { self.initComponents(); });
        self.loadCall(80, "Initializing User's code", function() { if (typeof(onInitDone) === "function") onInitDone(); });

        // Let's start loading!
        self.loadNextFromQueue();
        
    }, // init()

    // Will be called when everything is loaded and the queue is empty
    end: function() {
        this.log("Everything is loaded. BoxStrapper is done.");
        this.addToStartupScreen("Done!!");

        $('#startupProgress').html("<span class='done'>BoxView is ready!</span>");

        if (BoxViewSuiteConfig.boxStrapperConfig.closeOnDone) {
            var sd = $('#startupScreenDialog'),
                wi = $('.ui-widget-overlay'),
                co = BoxViewSuiteConfig.boxStrapperConfig;
            setTimeout(function() {  
                    wi.fadeOut(co.animationLength);
                    sd.slideUp(co.animationLength, function() { sd.dialog('close'); wi.fadeIn(0); }); 
                }, co.waitBeforeClose);
        }
    }, // end()

    addLoadingItem: function(name) {
        this.loadingItems++;
        this.itemsToLoad++;
        this.log(this.loadingItems+"/"+this.itemsToLoad+": Loading "+name);
    },

    removeLoadedItem: function(name) {
        this.loadedItems++;
        this.log(this.loadedItems+"/"+this.itemsToLoad+": DONE "+name);
        this.addToStartupScreen(name);
        
        if (this.isQueueDone && this.loadedItems === this.itemsToLoad)
            this.end();
    },

    // WIll load a css script adding this.path
    loadCss: function(prio, name, file) {
        this.pushLoadingQueue({file: file, name: name, type: 'css', prio: prio});
    },
    // WIll load a script file adding this.path
    loadScript: function(prio, name, file) { 
        this.pushLoadingQueue({file: file, name: name, type: 'js', prio: prio});
    },
    loadCall: function(prio, name, fun) {
        this.pushLoadingQueue({fun: fun, prio: prio, name: name});
    },
    // Will check if a script exists and load it, without adding any path
    loadScriptCheck: function(prio, name, checkFile, nextPrio) {
        this.pushLoadingQueue({checkfile: checkFile, prio: prio, name: name, nextprio: nextPrio});
    },

    pushLoadingQueue: function(o) {

        this.lowestPrio = Math.min(this.lowestPrio, o.prio);
        this.highestPrio = Math.max(this.highestPrio, o.prio);

        if (typeof(this.loadingQueue[o.prio]) === 'undefined')
            this.loadingQueue[o.prio] = [];

        // DEBUG: can add properties to this onbject such as "reloading" "tryed N times" "whatever"
        o.valid = true;

        if (typeof o.file === 'string') {
            this.log("Pushing new file into prio "+o.prio+" list: "+o.name);
            this.loadingQueue[o.prio].push(o);
        }
        if (typeof o.fun === 'function') { 
            this.log("Pushing new function call into prio "+o.prio+" list: "+o.name);
            this.loadingQueue[o.prio].push(o);
        }
        if (typeof o.checkfile === 'string') {
            this.log("Pushing new checkfile into prio "+o.prio+" list: "+o.name);
            this.loadingQueue[o.prio].push(o);
        }
    },

    // Removes an item from the queue by name. Will search through all levels and
    // remove it. Once per level, the last item will trigger next level.
    removeFromLoadingQueue: function(name) {

        // debug: invert for
        for (var k=0; k<=this.highestPrio; k++) {

            // skip empty or non-existent levels, if we get over highestPrio.. we're already done.
            // DEBUG: who's calling this when we are alredy done?!
            while (typeof this.loadingQueue[k] === "undefined" || this.loadingQueue[k].length === 0) 
                if (k++ > this.highestPrio) return;

            // Find the item with that name and remove it
            for (var j=0; j<this.loadingQueue[k].length; j++)
                if (this.loadingQueue[k][j].name === name) {
                    this.loadingQueue[k].splice(j, 1);
                    this.removeLoadedItem(name);

                    // The last item that gets removed triggers next priority level
                    if (this.loadingQueue[k].length === 0) {
                        this.log("* Priority #"+k+" is done. Going for next");
                        this.levelsDone++;
                        var self = this;
                        setTimeout(function() { self.loadNextFromQueue(); }, self.forceRemoveTime);
                    }

                    // As soon as we removed something, return
                    return;
                } // if .name === name 
        } // for k

    }, // removeFromLoadingQueue()

    // This gets called every time an
    loadNextFromQueue: function() {
        
        // Skip undefined and empty levels and if there's nothing left, return or call end()
        while (typeof this.loadingQueue[this.lowestPrio] === "undefined" || this.loadingQueue[this.lowestPrio].length === 0) 
            if (++this.lowestPrio > this.highestPrio) {
                this.log("** The queue is empty, loaded "+this.loadedItems+" items on "+this.levelsDone+" priority levels.");
                this.isQueueDone = true;
                
                // If the queue ended after loading all of the items, end!
                // If the queue is empty but there's still items to load, the 
                // last removed item will trigger end()
                if (this.loadedItems === this.itemsToLoad)
                    this.end();

                return;
            }

        if (typeof(this.loadingQueue[this.lowestPrio]) === 'object') { 
            this.log("Prio #"+this.lowestPrio+" is loading "+this.loadingQueue[this.lowestPrio].length+" items:");
            for (var i=0; i < this.loadingQueue[this.lowestPrio].length; i++) {
                var item = this.loadingQueue[this.lowestPrio][i];
                this.addLoadingItem(item.name);
                if (typeof(item.fun) === "function") {
                    // Call the remove when the funcion is finished
                    item.fun.call(this);
                    self = this;
                    setTimeout(function() { self.removeFromLoadingQueue(item.name); }, self.forceRemoveTime);
                }

                if (typeof(item.checkfile) === "string")
                    this.checkFile(item.checkfile, item.name, item.nextprio);

                if (typeof(item.file) === "string")
                    this._loadResource(item.file, item.name, item.type);
                
            };
        } else {
            this.log("Tried "+this.lowestPrio+" but there was no object, going for next prio");
        }
    }, // loadNextFromQueue()

    // Will check if the given file exist, looking from the current
    // page's path and adding a loadScript() call into the queue at 
    // the given prio
    checkFile: function(file, name, prio) {
        var self = this,
            l = document.location,
            h = l.pathname,
            p = (l.port !== '') ? ':'+l.port : '',
            // DEBUG: is this cross browser enough?? Changed twice for firefox.. :|
            absolutePath = l.protocol+"//"+l.hostname+p+h.substring(0, h.lastIndexOf('/')+1),
            absoluteFile = absolutePath + file + '?x='+Math.floor(Math.random()*100000);

        // DEBUG: if the given file is already an absolute URL, just use it
        $.ajax({
            type: "HEAD",
            async: true,
            url: absoluteFile,
            success: function(){ 
                self.loadScript(prio, "Checked file "+absoluteFile, absoluteFile);
                self.removeFromLoadingQueue(name);
            },
            error: function(){ 
                self.log("CheckFile FAILED on "+absoluteFile+", not loading."); 
                self.removeFromLoadingQueue(name);
            }
        });    
    }, // checkFile()
    
    _loadResource: function(file, name, type) {
        var s, field;

        // If it's an absolute URL, load it.. else add path and load it
        if (file.match(/http:/) === null) 
            file = this.path + file;

        // DEBUG: random string to trick the cache
        file += '?x='+Math.floor(Math.random()*100000);

        if (type === "css") {
            s = document.createElement('link');
            s.type = 'text/css';
            s.rel = 'stylesheet';
            s.media = 'screen';
            field = 'href';
        }

        if (type === "js") {
            s = document.createElement('script');
            s.rel = 'stylesheet';
            s.media = 'screen'
            field = 'src';
            s.type = 'text/javascript';
        }

        var self = this;
        s.onload = function () { self.removeFromLoadingQueue(name); };
        
        // Little hack: poll every 100ms if the stylesheet has been loaded, since
        // some browsers dont fire the onload event for certain tags (LINK!).
        if (type === "css")
            (function() {
    			try {
    				s.sheet.cssRules;
    			} catch (e) {
    				setTimeout(arguments.callee, 100);
    				return;
    			};
                s.onload(); 
    		})();
        
        s.onerror = function () { 
            // DEBUG: do something here, errors with just SCRIPTS not loading
            self.log("ERROR LOADING "+name); 
            self.removeFromLoadingQueue(name); 
        };

        s[field] = file; 
        document.getElementsByTagName('head')[0].appendChild(s);

    }, // _loadResource
    
    showOverlay: function() {
        // DEBUG: any better ideas than appending a div
        foo = document.createElement('div');
        foo.style.background = "#180c0c";
        foo.style.height = '100%';
        foo.style.width = '100%';
        foo.style['z-index'] = "10";
        foo.style.position = 'absolute';
        foo.id = 'foo_remove_me';
        document.getElementsByTagName('body')[0].appendChild(foo);
    }, // showOverlay()

    addStartupScreenCode: function() {

        // Remove the temporary black overlay and show the loading dialog
        $('body').prepend("<div id='startupScreenDialog'><div id='startupProgress'><span class='loaded'>0</span>/<span class='total'>0</span></div>"+
                            "<div id='startupProgressBar'></div><div id='startupScreenContainer'></div>");

        // Initialize the content of the startup screen dialog
        $('#startupScreenDialog').dialog({
            title: 'BoxView is loading ...',
        	draggable: false, resizable: false,	bgiframe: true,
    		autoOpen: true, height: 300, width: 420,
    		clearStyle: true, modal: true, 
    		buttons: { hide: function() { $(this).dialog('close'); } },
    		close: function() { return false; } 
    	});

        // Initialize the progress bar
        $('#startupProgressBar').progressbar({value: 10});
        this.isStartupScreenActive = true;
    }, // addStartupScreenCode()
    
    addToStartupScreen: function(name) {

        // Dont update if there's no screen active!
        if (this.isStartupScreenActive === false)
            return;

        $('#startupProgressBar').progressbar({value: Math.floor(this.loadedItems/this.itemsToLoad*100)});
        $('#startupProgress .loaded').html(this.loadedItems);
        $('#startupProgress .total').html(this.itemsToLoad);

        for (var i=5; i>=0; i--) $('#startupScreenContainer .fade'+i).removeClass('fade'+i).addClass('fade'+(i+1));
        $('#startupScreenContainer').prepend("<div class='fade0'><span class='ui-icon ui-icon-check' style='float:left;'></span>"+name+"</div>");
    }, // addToStartupScreen()

    initComponents: function() {

        var bvn = BoxViewSuiteConfig.boxViewName,
            amn = BoxViewSuiteConfig.anchorManName,
            sen = BoxViewSuiteConfig.boxViewSectionName,
            usn = BoxViewSuiteConfig.urlShortenerName,
            win = BoxViewSuiteConfig.widgetsName,
            callBacks = ["onSort", "onAdd", "onRemove", "onCollapse", "onExpand", "onReplace"];

        // Create the BoxView
        window[bvn] = new $.boxView(BoxViewSuiteConfig.boxViewContainer, BoxViewSuiteConfig.boxViewConfig);

        // Create the widgets helper object
        window[win] = new $.widgets(BoxViewSuiteConfig.widgetsConfig);

        // Set the BoxStrapper reference before the call_init_callback
        window[bvn].setBoxStrapper(this);

        // Create the URLShortener
        window[usn] = new $.urlShortener(BoxViewSuiteConfig.URLShortenerConfig);

        // Create the AnchorMan and connect some callbacks
        window[amn] = new $.anchorMan(BoxViewSuiteConfig.boxViewConfig);
        for (var i in callBacks) {
            name = callBacks[i];
            window[bvn][name+"AddCallBack"](function() { window[amn].set_section_from_object(sen, window[bvn].getAnchorManDesc())});
        }

    	window[amn].setCallbacks(sen, BoxViewSuiteConfig.anchorManCallbacks);
        window[amn].describeSection(sen, window[bvn].options.anchorManDescription);
    	window[amn].call_init_callbacks();
    }, // initComponents()
 
	log: function(w) {

        if (this.debug === false)
            return;

        if (typeof console == "undefined") {
            if ($("#debug_foo").attr('id') == null) 
                $("body").append("<div id='debug_foo' style='position: absolute; right:2px; bottom: 2px; border: 1px solid red; font-size: 1.1em;'></div>");
            $("#debug_foo").append("<div>"+w+"</div>");
        } else {
            var foo = new Date().getTime();
            console.log("#BoxStrapper# ("+(new Date().getTime() - this.startedAt)/1000+") "+w);
        }
    
	}// log
    
};