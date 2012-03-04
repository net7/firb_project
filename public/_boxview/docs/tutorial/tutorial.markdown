My first BoxView    
================

What’s a BoxView
----------------
BoxView is a suite of Open Source JavaScript libraries designed to handle the simultaneous visualization of multiple documents and multimedia objects.

BoxView splits the page in multiple “boxes” where each of them is a container in which any type of content can be visualized (a menu, a fragment of text, an entire html page, a video player, an image viewer and so on).

BoxView handles the boxes’ interactions, including automatically resizing them to fit the container, ordering, letting the user drag them around or collapse some of them.


BoxView’s components
--------------------
BoxView jquery plugin, widgets, providers, bla bla, some nice drawing with thrilling captions.


What you need
-------------
The BoxView itself doesnt need anything special, but your browser.

In order to run all the examples, the tests and the related components of the BoxView family thought, you will need a *PHP* interpreter **((VERSION?))** installed on your server, with *SQLiteDatabase* extension to use the given demo data. For example on Ubuntu systems and alikes just make sure you have the *php5-sqlite* package installed.

*Watch out*! If you plan to use the baked in sqlite database (enabling you to see the awesome dogs example and the url shortener thingie in action), make sure the db.sqlite file is writable by the webserver. Moreover, the web server must have read/write access on the directory containing this file as well.


Get the code
------------
If you already have git just:

> `git clone git@codebasehq.com:net7/libraries/boxview.git boxview`

if not, install it from http://git-scm.com/download (on Ubuntus etc just install the git-core package). 


To manually download the latest release (or any other given tag/release) in a compressed archive, surf to https://net7.codebasehq.com/libraries/boxview/tree/master, and click “Download Archive”.  Some authorization might be needed.


Boxview home page can be found at http://www.muruca.org/boxview/, so be sure to check it out for latest updates and more goodies to download.


Run the examples
----------------
Explode or move the downloaded code to a directory served by your web server (eg. `/var/www/boxview/`, `/Library/WebServer`, or a link to your home will do), and open the `/examples/example_simple.html` page (`http://localhost/boxview/examples/example_simple.html`, if the served directory is public under the name of `boxview`).

More examples can be found in the `/examples/` directory:

- `example_simple.html`: a very simple boxview example, with a link adding a box with a static content.
- `example_simple_widgets.html`: using the `widgets.js` javascript plugin, some links adding a default widget, a customized one and multiple customized widgets into a box.
- `example_ajax_php.html`: a simple `PHP` provider who answers to some Ajax calls about dog breeds. A link will open the index of all breeds, where links to individual dog sheets will open more boxes.
- `example_ajax_anchorman.html`:
- `example_ajax_anchorman_short_urls.html`:
- `example_ajax_anchorman_short_urls_loader.html`:


**((FOR MORE INFORMATIONS ON THE EXAMPLES READ SOMETHING SOMEWHERE BLABLA))**


Use the BoxView Suite
---------------------

To use the BoxView Suite in your page, you just need to include a single file and write one line of code!




Build your very own suite-less first BoxView in 1 line of code!
----------------------------------------------------
Let’s start with an HTML only BoxView, with some placeholder data, just to get it running. In a few we will add widgets too.

Assuming we have boxview’s `css/`, and `src/` directories in the current path, and the jquery files in `jq/` (just copy the given `/jq` in the boxview package!) create a file named `example.html`. 

First of all include the needed javascript and css files:

    <link href="css/boxview.css" media="screen" type="text/css" rel="stylesheet">

and 

	<script src="jq/jquery.js"></script>
	<script src="jq/jquery-ui.js"></script>
	<script src="src/boxview.js"></script>

We will create a default container for BoxView with inside an header, containing some links, and a content part with BoxView. 

So define a `<style>` tag in the `<head>` part and set some fixed heights for the containers:	


    <style>
        #pageExt { height: 100%; }
        #pageHeader { height: 10%; }
        #pageContent { height: 90%; }
	</style>


The HTML code in the `<body>` can then look like this:

	<div id="pageExt">
		<div id="pageHeader">
			<a href="#" id="addBox">Click me!</a>
		</div>
		<div id="pageContent"></div>
	</div>


Finally, inside a `<script>` tag at the bottom part of the page, let’s setup BoxView in the `#pageContent` (to use a css selector) `<div>` element, without any option yet:

	var myBoxView = new $.boxView($('#pageContent'));

and a default click function for the `#addBox` `<a>` tag, to just add a default box with some content:

	$('#addBox').click(function() {
		myBoxView.addBox("Some content?");
	});

The page should look like this now:

    <html><head>
    <link href="css/boxview.css" media="screen" type="text/css" rel="stylesheet">
    	<script src="jq/jquery.js"></script>
    	<script src="jq/jquery-ui.js"></script>
    	<script src="src/boxview.js"></script>
        <style>
            #pageExt { height: 100%; }
            #pageHeader { height: 10%; }
            #pageContent { height: 90%; }
        </style>
    </head>
    <body>
    	<div id="pageExt">
    		<div id="pageHeader">
    			<a href="#" id="addbox">Click me!</a>
    		</div>
    		<div id="pageContent"></div>
    	</div>
    <script>
    	var myBoxView = new $.boxView($('#pageContent'));
    	$('#addbox').click(function() {
    		myBoxView.addBox("Some content?");
    	});
    </script>
    </body></html>

To get this in one line of code as advertised, just remove every new line from the page source! Hey, it’s one line.


Adding widgets
--------------
To add widgets we just need to include the needed files in the HTML page, and call the right javascript functions.

In the `<head>` part add:

    <link href="css/widgets.css" media="screen" type="text/css" rel="stylesheet">
    <script src="src/widgets.js"></script>

We can now initialize the widgets helper object, inside the javascript `<script>` tag:
    
    var myWidgets = new $.widgets();
    
then modify the `#addbox` `click()` function to call `widgetify()`, which returns a simple string with the desired widget’s HTML code. For example let’s put two widgets in the `content` variable:

    var content = myWidgets.widgetify("Title", "And content");
    content += myWidgets.widgetify("Another title", "Another content!");

and then use this new variable to add a box:

    myBoxView.addBox(content);


The final page should, more or less, look like this:

    <html><head>
    <link href="css/boxview.css" media="screen" type="text/css" rel="stylesheet">
    <link href="css/widgets.css" media="screen" type="text/css" rel="stylesheet">
    	<script src="jq/jquery.js"></script>
    	<script src="jq/jquery-ui.js"></script>
    	<script src="src/boxview.js"></script>
        <script src="src/widgets.js"></script>
        <style>
            #pageExt { height: 100%; }
            #pageHeader { height: 10%; }
            #pageContent { height: 90%; }
        </style>
    </head>
    <body>
    	<div id="pageExt">
    		<div id="pageHeader">
    			<a href="#" id="addbox">Click me!</a>
    		</div>
    		<div id="pageContent"></div>
    	</div>
    <script>
    	var myBoxView = new $.boxView($('#pageContent'));
    	$('#addbox').click(function() {
            var content = myWidgets.widgetify("Title", "And content");
            content += myWidgets.widgetify("Another title", "Another content!");
            myBoxView.addBox(content);
    	});
    </script>
    </body></html>


Customize and configure BoxView
-------------------------------
Many BoxView aspects can be set both at startup and run time. In the startup call we will use an object to pass parameters in:

    myBoxView = new $.boxView($('#pageContent'), { animations: true, boxMargin: 10 });

this way we are enabling all the animations and setting a margin of 10 pixels to space boxes apart.

Here is the full list of options available for the boxView configuration object:

###Animations 

BoxView can use some animation to soften the movements like when a box is closed or
when it's dragged. You can either choose to set all of the animation on or off at once 
with the `animations` option or build your preferred combination of the other 
`animate*` options.

* **animateAdd** : (true/false) 
    
    The boxview will add new boxes using an animation. 

* **animateRemove** : (true/false)

    The boxview will remove a box using an animation.

* **animateCollapse** : (true/false)

    The boxview will collapse and expand boxes using an animation.

* **animateResize** : (true/false) 
     
    The boxview will resize, for example after a window resize, boxes using an animation.

* **animations** :(true/false/'string')

    Shortcut to set all of the animations at once, overriding any other 
    given `animate*` parameter. If set to a string will use the animate*
    parameters individually.

* **animationLength** : (milliseconds)

    Boxview's animations length 
    

###Box defaults

* **collapsed** : (true/false)

	Set this to true if you want boxes to get added collapsed.

* **title** : ('string')

	Default title for titleless boxes

* **verticalTitle** : ('string') 

    Default vertical title for verticaltitleless boxes


###Widths and heights
Various aspects of the boxes need to be configured as options and not through css rules.
The margin to space boxes apart, headers heights and widths and more.

* **collapsedWidth** : (pixels)

	Box width when collapsed 

* **collapsedHeaderHeight** : (pixels)
    
    Box header's height when collapsed, usually contains tools like 
    close/expand 

* **headerHeight** : (pixels)

    Box header's height when expanded, contains tools and title (pixels)

* **boxMargin** : (pixels)

	Space between boxes 

###CSS class names
Every box created by the Boxview is a `<div>` container, classed by default
with the `box` classname. Using a css selector `div.box` will apply on 
every box in every configuration: collapsed, expanded or while getting dragged
and more.

Each one of these actions, will make one or more boxes gain or lose one or 
more additional css classnames. For example while it is collapsed, the box 
will have a class, different from the one applied when expanded, and vice-versa.

The following options lets the user configure these names, thought the defaults
usually work fine.

The type of a box is just yet another classname applied to a box, exactly the type
you pass to `addBox()` or `addBoxFromAjax()` functions to add new boxes. Say you 
have boxes for different sports, you could use a type 'volley' and then
in your css stylesheet define rules like `div.box.volley` to apply that sport 
backgrounds or more personalizations.

* **collapsedClass** : ('string')
    
    Css class added to the box when collapsed

* **expandedClass** : ('string')

    Css class added to the box when expanded

* **loadingClass** : ('string')

    Css class added while the box is loading

* **type** : ('string')
	Default type for typeless boxes (every type is used as box css class
	in the HTML markup)

###Images resize handling
BoxView will handle automatically every `<image>` tag that is classed with
`resizeme` classname (`img.resizeme`, if you want). The following values will
be used on automatic resizes, for example on removing or adding boxes. A 
margin is added to the handled images. For example if you want to fit a 
vertical scroll bar in the box, a value around 15 is enough to always have
the image visible in its full width.

* **resizemeImagesForceMaxHeight** : (true/false)

    Enforce max width for images with .resizeme 

* **resizemeImagesMinHeight** : (pixels) 
    
    Minimum height for the .resizeme elements 
    
* **resizemeImagesMaxHeight** : (pixels)

    Maximum height for the .resizeme elements

* **resizemeImagesMargin** :  (pixels)

    Margin for .resizeme images

###AnchorMan - BoxView integration
AnchorMan is a suite's plugin that saves various information about your
boxes into the URL your browser is currently visiting. So if you bookmark 
or share it, the next time you visit it the boxview will read the saved
informations and use them to load exactly that saved configuration of
boxes (see AnchorMan manual for more informations). 

To do this, it just saves the fields you pass in an `addBox()` or 
`addBoxFromAjax()` calls. 

It's easier to see with an example: say we want a box for each sport, 
coming from our Ajax provider. The id of the volley box is 5, to get
its box we call `addBoxFromAjax()` passing an object like:

    { 
      qstring: 'http://site.com/id=5',
      title: 'Sport: Volley', 
      resId: 5, 
      type: 'volley',
      collapsed: false
    }

We want to save all of those fields but collapsed in AnchorMan so we define:

    anchorManDescription: ['qstring', 'title', 'id', 'type'],

an array with the just field names. When the box opens AnchorMan 
will store those selected fields, for every opened box in the current URL. Say
we open fishing, alpine skiing and sailing boxes and call the current page URL1. 

When someone opens direclty URL1 (say clicking on a friend's link) BoxView will
restore the saved configuration in that URL, opening again every box with the 
saved types, titles and ids. 

We decided not to save the `collapsed` field in AnchorMan. This means
that even if you collapse every box of your boxview and share the link, that
URL will show every box expanded, and not collapsed. To change this behaviour 
and save the collapsed state of your boxes, just add a 'collapsed' item to
`anchorManDescription` option.

The following field names are meaningful to boxview:

- `qstring` : the URL to get box contents from 
- `title` : box title when expanded
- `verticalTitle` : box title when collapsed, displayed vertically
- `id` : box id, intended as a whole with its content.
- `type` : box type, used as classname (see Css class names section for more
    informations)
- `collapsed` : is the box collapsed?
    
Other than that, you can add your own fields, as many as you like, passing
them into the `addBoxFromAjax()` object and adding them in the 
`anchorManDescription` configuration field.

If you need to use some strange character in your own fields 
(for example check AnchorManConfig separators!), prepend "encode" to
your veryImportantField name, like: 

    encodeveryImportantField: true

* **anchorManDescription** : (array of strings) 

    Box fields to be saved into AnchorMan, for example 
        
        ['id', 'type', 'qstring', 'title'],

* **encode\*** : (true/false)

    will encode the content of the * field with Base64. For example
    if you're using characters which collide with AnchorMan separators
    you can encode title with: 

        encodetitle: true,

###Callbacks
If you need some custom function to be called on a certain boxview event, set it
here or use the `onRemoveAddCallBack()`, `onSortAddCallBack()` etc functions on 
the boxView object. These will add a callback even at run-time, so you can bind 
as many functions as you want to each action separately. An example function
can be bound to every remove like this:

    onRemove: function() {
        alert("A box has been removed!");
    }

* **onRemove** : (function)
    
    Will be called when a box is removed
    
* **onSort** : (function)

    Will be called when the boxes are sorted

* **onAdd** : (function)

    Will be called when a box is added to the boxview

* **onCollapse** : (function)

    Will be called when a box is collapsed

* **onExpand** : (function)

    Will be called when a box is expanded

* **onReplace** : (function)

    Will be called when the content of a box is replaced

###Troubleshooting

* **debug** : (true/false)

    Shows some VERY verbose output about boxview behaviours using
    browser's console.log or adding a div to the dom.


To configure coloring, font styles and other CSS-related aspects of the result you want to get you can have a look at css.txt.