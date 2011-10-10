/* Copyright (c) 2010 Net7 SRL, <http://www.netseven.it/>       */
/* This Software is released under the terms of the MIT License */
/* See LICENSE.TXT for the full text of the license.            */

(function ($) {

    // BVToolbar constructor
    $.BoxToolbar = function (bv, opts) {
        this.options = $.extend({}, $.BoxToolbar.defaults, opts);
		this.boxview = bv;
        this.init();
    }; // $.urlShortener()

    // DEFAULTS
    $.BoxToolbar.defaults = {

		// TODO: let the user supply a selector where 
		// to put the content of the toolbox
		selector: '',

		toolboxShowHistory: true,
		toolboxShowUrlShortener: true,
		toolboxShowLoading: true,
		toolboxShowPreferences: true,

		defaultContainerClass: ''


    }; // defaults

    $.BoxToolbar.prototype = {
        init: function () { 

            var self = this;

			self.urlShortener = false;
			if (typeof($.urlShortener.globalHelperName) === 'string') 
				self.urlShortener = window[$.urlShortener.globalHelperName];

			self.initComponentsHTML();
			self.initListeners();
    	
        }, // init()
        
		initListeners: function() {
			var self = this,
				bvn = self.boxview.boxViewName;

			$('.boxview_toolbar.bv_'+bvn+' a.toolbar_history').click(function() {
				self.boxview.openHistoryBox();
			});

			if (self.urlShortener)
				$('.boxview_toolbar.bv_'+bvn+' a.toolbar_urlshortener').click(function() {
					self.urlShortener.getCurrentShortenedUrl();
				});
			
		}, // initListeners()

		initComponentsHTML: function() {
			var self = this,
				bvn = self.boxview.boxViewName,
				s = '';
			
			s += '<div class="boxview_toolbar_wrapper"><div class="boxview_toolbar bv_'+bvn+'"><ul>';
			
			if (self.options.toolboxShowHistory)
				s += '<li><a class="toolbar_history" title="Check your navigation history">History</a></li>';

			if (self.options.toolboxShowUrlShortener)
				s += '<li><a class="toolbar_urlshortener" title="Get a short link for this page">Link to this page</a></li>';

				/* TODO TODO TODO
			if (self.options.toolboxShowPreferences) 
				s += '<li><a class="toolbar_settings" title="User settings">Settings</a></li>';
				*/
			s += '</ul></div></div>';


			if (self.options.toolboxShowLoading)
				s += '<div style="display: none;" class="boxview_loading_dialog"><p>Caricamento in corso</p></div>';

            // TODO:  Initialize the content of the user pref dialog
			
			// TODO: check if user supplied a selector
			$('body').append(s);
			
		}

    }; // BoxToolbar.prototype
})(jQuery);
