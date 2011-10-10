<?php

// DEBUG: put the visualizer path as parameter somewhere?

$what = isset($_GET['what']) ? $_GET['what'] : 'html_index';
$id = isset($_GET['id']) ? $_GET['id'] : 'html_index';

// Create SQLiteDatabase object
if (!$db = new SQLiteDatabase('db.sqlite', 0666)) 
    die("Cant connect to the file database. Make sure the db file is in the right place and the directory is writable by the web server.");

switch ($what) {

    // Ask for all breeds and just shows them as text
    case 'html_index':
        $q = 'SELECT id,breed_name,picture,description FROM dogs ORDER BY breed_name';
        @$result = $db->arrayQuery($q);

        if ($result === false) die("Cant execute $q. Make sure the db file is in the right place and the directory is writable by the web server.");
        else {
            foreach ($result as $dog) 
                echo 'Id '.$dog['id'].'Breed: '.$dog['breed_name'].', picture: '.$entry['picture'];
        }
    break;

    // Ask for all breeds in an index format
    case 'breeds':
    $q = 'SELECT id,breed_name,description,picture FROM dogs ORDER BY breed_name';
    @$result = $db->arrayQuery($q);

    if ($result === false) die("Cant execute $q. Make sure the db file is in the right place and the directory is writable by the web server.");
    else {
        echo'<div class="widget widget_draggable">'.
            '  <div class="widgetHeader toBeResized">'.
            '     <div class="leftIcons"><ul>'.
            '         <li class="collapse"><a class="expanded" href="#" title="Collapse">Collapse</a></li>'.
            '     </ul></div>'.
            '     <div class="title"><h4 class="widgetHeaderTitle">Breeds A-Z</h4></div>'.
            '     <div class="rightIcons"><ul>'.
            '         <li class="drag"><a href="#" title="Drag">Drag</a></li>'.
            '     </ul></div>'.
            '  </div>'.
            '  <div class="widgetContent expanded"><div>';
        echo '<ul>';
        foreach ($result as $dog) {
            echo '<li>'.
                 '<div class="indexIcon"><a class="indexLink" href="visualizer.php?what=dog&id='.$dog['id'].'"><img src="dogs/'.$dog['picture'].'" /></a></div>'.
                 '<div class="indexContent"><h5 class="indexItemTitle"><a class="indexLink" href="visualizer.php?what=dog&id='.$dog['id'].'">'.$dog['breed_name'].'</a></h5>'.
                 '<p  class="indexItemDescription">'.substr($dog['description'],0,80).'.. </p></div>'.
                 '</li>';
        }
        echo '</div></div></div>';
        echo '</ul>';
    }
    break;

    // Show a dog sheet
    case 'dog':
    $q = 'SELECT id,breed_name,picture,description FROM dogs where id='.$id;
    @$result = $db->arrayQuery($q);

    if ($result === false) die("Cant execute $q. Make sure the db file is in the right place and the directory is writable by the web server.");
    else {
        // DEBUG: widgetify this in some PHP-nice-way
        foreach ($result as $dog) {
            echo'<div class="widget widget_draggable">'.
                '  <div class="widgetHeader toBeResized">'.
                '     <div class="leftIcons"><ul>'.
                '         <li class="collapse"><a class="expanded" href="#" title="Collapse">Collapse</a></li>'.
                '     </ul></div>'.
                '     <div class="title"><h4 class="widgetHeaderTitle">Picture</h4></div>'.
                '     <div class="rightIcons"><ul>'.
                '         <li class="drag"><a href="#" title="Drag">Drag</a></li>'.
                '     </ul></div>'.
                '  </div>'.
                '  <div class="widgetContent expanded"><div class="picture"><img class="resizable" src="dogs/'.$dog['picture'].'"/></div></div>'.
                '</div>'.
                '<div class="widget widget_draggable">'.
                '  <div class="widgetHeader toBeResized">'.
                '     <div class="leftIcons"><ul>'.
                '         <li class="collapse"><a class="expanded" href="#" title="Collapse">Collapse</a></li>'.
                '     </ul></div>'.
                '     <div class="title"><h4 class="widgetHeaderTitle">General description</h4></div>'.
                '     <div class="rightIcons"><ul>'.
                '         <li class="drag"><a href="#" title="Drag">Drag</a></li>'.
                '     </ul></div>'.
                '  </div>'.
                '  <div class="widgetContent expanded">'.$dog['description'].'</div>'.
                '</div>';
        } // foreach
    } // if result === false
    break;

} // switch what
    
?>