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
            type: '',
        },

        // Use animations to collapse widgets?
        animations: true,

        // Animation lenght
        animationsLenght: 750,

        // Collapse widgets by double-clicking on the header?
        collapseOnDoubleClick: true,

        // Used internally by the suite: provides a reference to
        // the $.widgets object in the global scope under this name
        globalHelperName: "WidgetsHelper",

        debug: false

    }; // defaults

    $.widgets.prototype = {
        init: function() { 

            $('.boxViewContainer').bind('contentchange', function() {
                // DEBUG: if it's already sortable, dont do this again :)
                // Add a class or something? 
                $('.boxContent').sortable({ containment: 'parent', handle: 'div.widgetHeaderTools', items: 'div.widget.widget_draggable'});
            });
            
            var _foo = ".boxViewContainer div.box div.widget div.widgetHeader",
                self = this;
            // DEBUG: need to add && collapsable===true someway?
            if (this.options.collapseOnDoubleClick)
                $(_foo+" .widgetHeaderTitle,"+_foo+" .widgetHeaderTools").live("dblclick", function() { return self.collapseWidget(this); });

            // Bind widget collapse button
            $(_foo+" span.collapse a").live("click", function() { return self.collapseWidget(this); });

            // Bind widget drag button to nothing ..
            $(_foo+" span.drag a").live("click", function() { return false; });

            if (this.options.animations === false)
                this.options.animationsLenght = 0;

            window[this.options.globalHelperName] = this;

        }, // init()
        
        widgetify: function(title, content, opts) {

            var self = this,
                options = $.extend({}, self.options.defaults, opts),
                widget_class = ((options.draggable) ? "widget_draggable " : "") + options['type'],
                w = "<div class='widget "+widget_class+"'><div class='widgetHeader'><h4 class='widgetHeaderTitle'>#TITLE#</h4><div class='widgetHeaderTools'>";

            if (options.collapsable)
                w += "<span class='collapse'><a class='expanded' href='#' title='Collapse'>Collapse</a></span>";

            if (options.prevnext)
                w += "<span class='next'><a href='#' title='Next'>Next</a></span>"+
                    "<span class='previous'><a href='#' title='Previous'>Previous</a></span>";

            if (options.zoomable)
                w += "<span class='zoom'><a href='#' title='Zoom'>Zoom</a></span>";

            // Default true
            if (options.draggable)
                w += "<span class='drag'><a href='#' title='Drag'>Drag</a></span>";

            w += "</div></div><div class='widgetContent expanded'>#CONTENT#</div></div>";

            return w.replace("#TITLE#", title).replace("#CONTENT#", content);
        }, // widgetify()
        
        collapseWidget: function(clicked_item) {
            var widget = $(clicked_item).parents('div.widget'),
                t = $(widget.find('span.collapse a')),
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