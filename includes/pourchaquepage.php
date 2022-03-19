<?php
        include_once("../includes/navbar.php");

        class MyDB extends SQLite3
        {
            function __construct()
            {
                $this->open('../zoo.db');
            }
        }

        $db = new MyDB();
?>