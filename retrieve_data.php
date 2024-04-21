<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Company Data</title>
</head>
<body>
    <h1>Company Data</h1>
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

    // Retrieve data from the database
    $sql = "SELECT * FROM company";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        // Output data in HTML table
        while($row = $result->fetch_assoc()) {
            echo "<label>Name : </label>";
            echo "<p>".$row["name"]."</p>";
            echo "<label>Email : </label>";
            echo "<p>".$row["email"]."</p>";
            echo "<label>Phone : </label>";
            echo "<p>".$row["phone"]."</p>";
            echo "<label>Address : </label>";
            echo "<p>".$row["address"]."</p>";
        }
        echo "</table>";
    } else {
        echo "0 results";
    }

    $conn->close();
    ?>
</body>
</html>
