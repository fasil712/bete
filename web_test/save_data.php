<?php
// Establish connection to MySQL database
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "compdb";

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Retrieve form data
$name = $_POST['name'];
$email = $_POST['email'];
$phone = $_POST['phone'];
$address = $_POST['address'];

// Insert data into the database
$sql = "INSERT INTO company (name, email, phone, address) VALUES ('$name', '$email', '$phone', '$address')";

if ($conn->query($sql) === TRUE) {
    echo "New record created successfully";
    echo "<a href='index.html'>BACK</a>";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
