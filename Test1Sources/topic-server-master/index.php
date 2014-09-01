<?php
ini_set('display_errors', true);
require 'vendor/autoload.php';
$app = new \Slim\Slim();
$app->config('debug', true);
$app->view(new \JsonApiView());
$app->add(new \JsonApiMiddleware());

$app->container->singleton('db', function () {
    return new PDO('mysql:host=localhost;dbname=iphone;charset=utf8', 'root', '', array(PDO::ATTR_EMULATE_PREPARES => false, PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION));
});

$db = $app->db;

function CurlGet($sURL)
{
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
    curl_setopt($ch, CURLOPT_URL, $sURL);
    curl_setopt($ch, CURLOPT_POST, false);
    curl_setopt($ch, CURLOPT_HEADER, false);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    $sResult = curl_exec($ch);
    if (curl_errno($ch)) {
        // Fehlerausgabe
        print curl_error($ch);
    } else {
        // Kein Fehler, Ergebnis zurückliefern:
        curl_close($ch);
        return $sResult;
    }
}

function validateToken($token)
{
    // jSON String for request
    $url = 'https://graph.facebook.com/me?access_token=' . $token;
    $response = CurlGet($url);

    // get the result and parse to JSON
    $result = json_decode($response);

    if ($result->id == null) {
        $app->render(401, array(
            'error' => true,
            'msg' => 'Unauthorized!',
        ));
    }
}

$app->get('/', function () use ($app) {
    $app->render(200, array(
        'msg' => 'The Topic API!',
    ));
});

$app->get('/user/auth', function () use ($app) {
    $token = $app->request->headers->get('TOKEN');
    validateToken($token);

    $app->render(200, array(
        'msg' => 'success!',
    ));
});

$app->get('/topic/:fbUserId', function ($fbUserId) use ($app, $db) {
    $token = $app->request->headers->get('TOKEN');
    validateToken($token);

    $stmt = $db->query('SELECT topic.*, friends.name AS friend_name, friends.avatarURL FROM topic
                            LEFT JOIN friendsInTopic ON topic.id = topicID
                            LEFT JOIN friends ON friendID = friends.id');
    if (!$stmt) {
        $app->render(500, array(
            'error' => true,
        ));
    }
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $queryNotes = $db->query('SELECT topic.*, notes.name as note_name, notes.description as note_description, notes.date as note_date FROM topic
                            LEFT JOIN notesInTopic ON topic.id = topicID
                            LEFT JOIN notes ON noteID = notes.id');
    $notes = $queryNotes->fetchAll(PDO::FETCH_ASSOC);

    $tmpResponse = array();
    foreach ($results as $friends) {
        if (empty($tmpResponse[$friends['id']])) {
            $tmpResponse[$friends['id']] = array(
                'startdate' => $friends['startdate'],
                'enddate' => $friends['enddate'],
                'category' => $friends['category'],
                'creatorimage' => $friends['creatorimage'],
                'name' => $friends['name'],
                'fbUserId' => $friends['fbUserId']
            );
        }

        if (!empty($friends['friend_name'])) {
            $tmpResponse[$friends['id']]['friends'][] = array('avatarURL' => $friends['avatarURL'], 'name' => $friends['friend_name']);
        }
    }

    foreach ($notes as $note) {
        if (!empty($note['note_name'])) {
            $tmpResponse[$note['id']]['notes'][] = array('name' => $note['note_name'], 'description' => $note['note_description'], 'date' => $note['note_date']);
        }
    }

    $rsp = array();
    foreach ($tmpResponse as $id => $row) {
        $rsp[] = array(
            'id' => $id,
            'startdate' => $row['startdate'],
            'enddate' => $row['enddate'],
            'category' => $row['category'],
            'creatorimage' => $row['creatorimage'],
            'name' => $row['name'],
            'friends' => empty($row['friends']) ? null : $row['friends'],
            'notes' => empty($row['notes']) ? null : $row['notes'],
            'fbUserId' => $row['fbUserId']
        );
    }


    $app->render(200, array(
        'msg' => $rsp,
    ));

});
                       
                       
$app->post('/topic', function () use ($app, $db) {
    $token = $app->request->headers->get('TOKEN');
    validateToken($token);

    $body = $app->request()->getBody();
    $post = json_decode($body);

    $topicId = $post->id;
    $name = $post->name;
    $startdate = $post->startdate;
    $enddate = $post->enddate;
    $category = $post->category;
    $creatorimage = $post->creatorimage;
    $fbUserId = $post->fbUserId;

    $topicCheck = $db->prepare('SELECT id FROM topic WHERE id = ?');
    $topicCheck->execute(array($topicId));
    if ($topicCheck->rowCount()) {
        $app->render(400, array(
            'msg' => 'Topic already exists'
        ));
    }

    $stmt = $db->prepare("INSERT INTO topic(id,name,startdate,enddate,category,creatorimage,fbUserId) VALUES(:id,:name,:startdate,:enddate,:category,:creatorimage,:fbUserId)");
    $stmt->execute(array(':id' => $topicId, ':name' => $name, ':startdate' => $startdate, ':enddate' => $enddate, ':category' => $category, ':creatorimage' => $creatorimage, ':fbUserId' => $fbUserId));
    //$id = $db->lastInsertId();
    $id = $topicId;
    $affected_rows = $stmt->rowCount();


    if ($affected_rows > 0) {
        $friends = $post->friends;
        foreach ($friends as $friend) {
            $query = $db->prepare('SELECT id FROM friends WHERE name = :name');
            $query->execute(array(':name' => $friend->name));
            if ($query->rowCount()) {
                $friendId = $query->fetch(PDO::FETCH_ASSOC);
                $relationInsert = $db->prepare('INSERT INTO friendsInTopic (topicID, friendID) VALUES(:topicId,:friendId)');
                $relationInsert->execute(array(':topicId' => $id, ':friendId' => $friendId['id']));
            } else {
                $friendInsert = $db->prepare('INSERT INTO friends (name, avatarURL) VALUES(:name,:avatarURL)');
                $friendInsert->execute(array(':name' => $friend->name, ':avatarURL' => $friend->avatarURL));
                $friendId = $db->lastInsertId();
                $relationInsert = $db->prepare('INSERT INTO friendsInTopic (topicID, friendID) VALUES(:topicId,:friendId)');
                $relationInsert->execute(array(':topicId' => $id, ':friendId' => $friendId));
            }
        }

        $notes = $post->notes;
        foreach ($notes as $note) {
//            $query = $db->prepare('SELECT id FROM notes WHERE name = :name');
//            $query->execute(array(':name' => $note->name));
//            if ($query->rowCount()) {
//                $noteId = $query->fetch(PDO::FETCH_ASSOC);
//                $relationInsert = $db->prepare('INSERT INTO notesInTopic (topicID, noteId) VALUES (:topicId, :noteId)');
//                $relationInsert->execute(array(':topicId' => $id, ':noteId' => $noteId['id']));
//            } else {
                $noteInsert = $db->prepare('INSERT INTO notes (topicID, name, description, date) VALUES (:topicId, :name, :description, :date)');
                $noteInsert->execute(array(':topicId' => $id, ':name' => $note->name, ':description' => $note->description, ':date' => $note->date));
                $noteId = $db->lastInsertId();
                $relationInsert = $db->prepare('INSERT INTO notesInTopic (topicID, noteId) VALUES (:topicId, :noteId)');
                $relationInsert->execute(array(':topicId' => $id, ':noteId' => $noteId));
//            }
        }

        $app->render(200, array(
            'msg' => $id,
        ));
    }
});

$app->put('/topic/:id', function ($id) use ($app, $db) {
    $token = $app->request->headers->get('TOKEN');
    validateToken($token);

    $body = $app->request()->getBody();
    $post = json_decode($body);

    $name = $post->name;
    $startdate = $post->startdate;
    $enddate = $post->enddate;
    $category = $post->category;
    $creatorimage = $post->creatorimage;

    $stmt = $db->prepare("UPDATE topic SET name=?, startdate=?, enddate=?, category=?, creatorimage=? WHERE id = ?");
    $stmt->execute(array($name, $startdate, $enddate, $category, $creatorimage, $id));

//    $affected_rows = $stmt->rowCount();

    $db->query('DELETE FROM notesInTopic WHERE topicID = ' . $id);
    $db->query('DELETE FROM friendsInTopic WHERE topicID = ' . $id);

    $friends = $post->friends;
    foreach ($friends as $friend) {
        $query = $db->prepare('SELECT id FROM friends WHERE name = :name');
        $query->execute(array(':name' => $friend->name));
        if ($query->rowCount()) {
            $friendId = $query->fetch(PDO::FETCH_ASSOC);
            $relationInsert = $db->prepare('INSERT INTO friendsInTopic (topicID, friendID) VALUES(:topicId,:friendId)');
            $relationInsert->execute(array(':topicId' => $id, ':friendId' => $friendId['id']));
        } else {
            $friendInsert = $db->prepare('INSERT INTO friends (name, avatarURL) VALUES(:name,:avatarURL)');
            $friendInsert->execute(array(':name' => $friend->name, ':avatarURL' => $friend->avatarURL));
            $friendId = $db->lastInsertId();
            $relationInsert = $db->prepare('INSERT INTO friendsInTopic (topicID, friendID) VALUES(:topicId,:friendId)');
            $relationInsert->execute(array(':topicId' => $id, ':friendId' => $friendId));
        }
    }

    $notes = $post->notes;
    foreach ($notes as $note) {
//        $query = $db->prepare('SELECT id FROM notes WHERE name = :name');
//        $query->execute(array(':name' => $note->name));
//        if ($query->rowCount()) {
//            $noteId = $query->fetch(PDO::FETCH_ASSOC);
//            $relationInsert = $db->prepare('INSERT INTO notesInTopic (topicID, noteId) VALUES (:topicId, :noteId)');
//            $relationInsert->execute(array(':topicId' => $id, ':noteId' => $noteId['id']));
//        } else {
            $noteInsert = $db->prepare('INSERT INTO notes (topicID, name, description, date) VALUES (:topicId, :name, :description, :date)');
            $noteInsert->execute(array(':topicId' => $id, ':name' => $note->name, ':description' => $note->description, ':date' => $note->date));
            $noteId = $db->lastInsertId();
            $relationInsert = $db->prepare('INSERT INTO notesInTopic (topicID, noteId) VALUES (:topicId, :noteId)');
            $relationInsert->execute(array(':topicId' => $id, ':noteId' => $noteId));
//        }
    }

    $app->render(200, array(
        'msg' => 'success',
    ));


});

$app->delete('/topic/:id', function ($id) use ($app, $db) {
    $token = $app->request->headers->get('TOKEN');
    validateToken($token);

    $stmt = $db->prepare('DELETE FROM topic WHERE id = ?');
    $stmt->execute(array($id));

    $affectedRows = $stmt->rowCount();

    if ($affectedRows > 0) {
        $app->render(200, array(
            'msg' => 'success'
        ));
    } else {
        $app->render(404, array(
            'msg' => 'Topic not found'
        ));
    }
});

$app->get('/category', function () use ($app, $db) {
    $token = $app->request->headers->get('TOKEN');
    validateToken($token);

    $stmt = $db->query('SELECT * FROM category');
    if (!$stmt) {
        $app->render(500, array(
            'error' => true,
        ));
    }
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $app->render(200, array(
        'msg' => $results,
    ));

});
                       

$app->post('/fbuser', function () use ($app, $db) {
    $token = $app->request->headers->get('TOKEN');
    validateToken($token);

    $body = $app->request()->getBody();
    $post = json_decode($body);

    $fbuserId = $post->id;
    $facebookId = $post->facebookId;
           
    $firstName = '';
    if (isset($post->firstName)) {
       $firstName = $post->firstName;
    }

    $lastName = '';
    if (isset($post->lastName)) {
       $lastName = $post->lastName;
    }

    $fbUsersCheck = $db->prepare('SELECT id FROM fbUsers WHERE id = ?');
    $fbUsersCheck->execute(array($fbuserId));
           
    if ($fbUsersCheck->rowCount()) {
           
           $stmt = $db->prepare("UPDATE fbUsers SET firstName=?, lastName=? WHERE id = ?");
           $stmt->execute(array($firstName, $lastName, $fbuserId));
           
//        $app->render(400, array(
//            'msg' => 'fbUsers already exists'
//        ));
    } else {
           $stmt = $db->prepare("INSERT INTO fbUsers(id,facebookId,firstName,lastName) VALUES(:id,:facebookId,:firstName,:lastName)");
           $stmt->execute(array(':id' => $fbuserId, ':facebookId' => $facebookId, ':firstName' => $firstName, ':lastName' => $lastName));
    }
    //$id = $db->lastInsertId();
    //$id = $fbuserId;
    //$affected_rows = $stmt->rowCount();
    $app->render(200, array(
        'msg' => $fbuserId,
    ));
});


$app->run();
?>