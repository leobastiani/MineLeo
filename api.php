<?php
function ret($r) {
    echo $r;
    exit();
}

if (isset($_GET['owner'])) {
    $ret = file_get_contents('owner');
    ret($ret ?: 'None');
}

if (isset($_GET['request'])) {
    $owner = substr($_GET['request'], 0, 20);
    file_put_contents('owner', $owner);
    ret($owner);
}

if (isset($_GET['free'])) {
    file_put_contents('owner', '');
    ret('OK');
}

echo "API de MineLeo";