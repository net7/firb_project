// Adding a special "contentchange" event to jquery, triggers when the 
// given item content.. changes.
(function(){
    var interval;
    jQuery.fn.contentchange = function(fn) {
        return this.bind('contentchange', fn);
    };
    jQuery.event.special.contentchange = {
        setup: function(data, namespaces) {
            var self = this,
                $this = $(this),
                $originalContent = $this.text();
            interval = setInterval(function() {
                if ($originalContent != $this.text()) {
                    $originalContent = $this.text();
                    jQuery.event.special.contentchange.handler.call(self);
                }
            }, 100);
        },
        teardown: function(){ clearInterval(interval); },
        handler: function(event) { jQuery.event.handle.call(this, {type:'contentchange'}); }
    };
})();

(function ($) {

    // Widgets constructor
    $.widgets = function (opts) {
        this.options = $.extend({}, $.widgets.defaults, opts);
        this.init();
    }; // $.widgets()

    // DEFAULTS
    $.widgets.defaults = {

        // Widget's options defaults for the widgetify() method
        defaults: {
            draggable: true,
            collapsable: true,
            prevnext: false,
            zoomable: false,
            type: ''
        },

        // Use animations to collapse widgets?
        animations: true,

        // Animation lenght
        animationsLenght: 750,

        // Collapse widgets by double-clicking on the header?
        collapseOnDoubleClick: true,

        // TODO
        iconSize: 20,

        // TODO
        iconSlotsHorizontalMarginLeft: 40,

        // TODO
        iconSlotsHorizontalMarginRight: 10,

        // TODO
        headerTitleMargin: 5,

        // TODO 
        iconsAlignment: 'alignMiddle',
        
        // Used internally by the suite: provides a reference to
        // the $.widgets object in the global scope under this name
        globalHelperName: "WidgetsHelper",

        debug: false

    }; // defaults

    $.widgets.prototype = {
        init: function() { 

            var _foo = ".boxViewContainer div.box div.widget div.widgetHeader",
                self = this;

            $('.boxViewContainer').bind('contentchange', function() {
                // DEBUG: if it's already sortable, dont do this again :)
                // Add a class or something? 
                $('.boxContent').sortable({ containment: 'parent', handle: 'div.widgetHeader .title, div.widgetHeader .drag', items: 'div.widget.widget_draggable'});
                self.resizeWidgets();
            });
            
            // DEBUG: need to add && collapsable===true someway?
            if (this.options.collapseOnDoubleClick)
                $(_foo+" .widgetHeaderTitle,"+_foo+" .widgetHeaderTools").live("dblclick", function() { return self.collapseWidget(this); });

            // Bind widget collapse button
            $(_foo+" .collapse a").live("click", function() { return self.collapseWidget(this); });

            // Bind widget drag button to nothing ..
            $(_foo+" .drag a").live("click", function() { return false; });

            if (this.options.animations === false)
                this.options.animationsLenght = 0;

            window[this.options.globalHelperName] = this;

        }, // init()
        
        widgetify: function(title, content, opts) {

            var self = this,
                options = $.extend({}, self.options.defaults, opts),
                widget_class = ((options.draggable) ? "widget_draggable " : "") + options['type'],
                w = "<div class='widget "+widget_class+"'><div class='widgetHeader toBeResized'>";
            
            // LEFT icons: 
            w += "<div class='leftIcons'><ul>";
            if (options.collapsable)
                w += "<li class='collapse'><a class='expanded' href='#' title='Collapse'>Collapse</a></li>";
            w += "</ul></div>";

            // Widget TITLE
            w += "<div class='title'><h4 class='widgetHeaderTitle'>" + title + "</h4></div>";
			
            // RIGHT icons
            w += "<div class='rightIcons'><ul>";
            
            if (options.prevnext)
                w += "<li class='next'><a href='#' title='Next'>Next</a></li>"+
                    "<li class='previous'><a href='#' title='Previous'>Previous</a></li>";

            if (options.zoomable)
                w += "<li class='zoom'><a href='#' title='Zoom'>Zoom</a></li>";

            if (options.draggable)
                w += "<li class='drag'><a href='#' title='Drag'>Drag</a></li>";
            
            w += "</ul></div>";

            // Widget CONTENT
            w += "</div><div class='widgetContent expanded'>"+content+"</div></div>";

            return w;
        }, // widgetify()

        // TODO: call this just once per widget added?
        // Resizes widgets: headers, icons and the rest
        resizeWidgets: function() {
            var self = this;
            
            // For each .widgetHeader.toBeResized element .. resize its left/right
            // icon slots and icons, along with the title
            $('div.widget div.widgetHeader.toBeResized').each(function (i, e) {
                var left = $(e).find('.leftIcons li'),
                    right = $(e).find('.rightIcons li'),
                    titleLeft = left.length * self.options.iconSize + self.options.iconSlotsHorizontalMarginLeft + self.options.headerTitleMargin,
                    titleRight = right.length * self.options.iconSize + self.options.iconSlotsHorizontalMarginRight + self.options.headerTitleMargin;

                // Set title's margin left/right to make space for icons
                $(e).find('.title').css({'margin-left': titleLeft+'px', 'margin-right': titleRight+'px'});
    
                // Resize the icons
                // $(e).find('li, li a').css({'width': self.options.iconSize+'px', height: self.options.iconSize+'px'});
                $(e).find('li, li a').css({'width': self.options.iconSize+'px'});

                // Add the icon alignment classes
                $(e).find("li a").addClass(self.options.iconsAlignment);

                // Set the margin for left/right icon slots
                $(e).find(".leftIcons").css({left: self.options.iconSlotsHorizontalMarginLeft+'px'});
                $(e).find(".rightIcons").css({right: self.options.iconSlotsHorizontalMarginRight+'px'});

                // Remove the class to avoid resizing more than once
                $(e).removeClass('toBeResized');
            });
            
            $('div.box.expanded div.widgetContent.notes-displayed').each(function (i, e) {
                var th = $(e).find('div.transcription_text').height();
                $(e).find('div.transcription_notes_content').height(th);
            });
            
        }, // resizeWidgets()
        
        collapseWidget: function(clicked_item) {
            var widget = $(clicked_item).parents('div.widget'),
                t = $(widget.find('.collapse a')),
                h = t.parents('div.widgetHeader').next(),
                box = t.parents('div.box'),
                len = this.options.animationsLenght,
                e = 'expanded', c = 'collapsed';

            // Interrupt if the box is already loading something else
            if (box.hasClass('loadingContent'))
                return false;

            // No class, we expect it to be expanded
            if (!(t.hasClass(e) || t.hasClass(c))) 
                t.addClass(e);

            if (t.hasClass(e)) {
                // expanded: collapse with the animation then set the class
                t.addClass(c).removeClass(e);
                if (len == 0) h.addClass(c).removeClass(e);
                else h.removeClass(e).slideToggle(len, 'easeOutQuint', function() { h.addClass(c); });
            } else {
                // collapsed: hide, switch class then start the animation
                t.addClass(e).removeClass(c);
                if (len == 0) h.addClass(e).removeClass(c).show();
                else h.hide().removeClass(c).addClass(e).slideToggle(len, 'easeOutQuint');
            }

            return false;    
        } // collapseWidget()
        

    } // widgets.prototype
})(jQuery);