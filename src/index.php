<?php
$host = getenv('DB_HOST');
$user = getenv('DB_USER');
$pass = getenv('DB_PASS');
$dbname = getenv('DB_NAME');

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $pdo->query("SELECT * FROM annonces ORDER BY date_creation DESC");
    $annonces = $stmt->fetchAll(PDO::FETCH_ASSOC);

} catch (PDOException $e) {
    $error = "Erreur de connexion à la base de données : " . $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vide-Grenier en ligne</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link href="./style.css" rel="stylesheet">
</head>
<body>

<header>
    <h1>Vide-Grenier</h1>
    <p>Trouvez les meilleures affaires du coin</p>
</header>

<main>
    <?php if (isset($error)) echo "<div class='error'>".htmlspecialchars($error)."</div>"; ?>

    <div class="grid">
        <?php foreach ($annonces ?? [] as $a): ?>
            <div class="card">
                <h2><?= htmlspecialchars($a['titre']) ?></h2>
                <div class="date"><?= date('d/m/Y', strtotime($a['date_creation'])) ?></div>
                <p><?= nl2br(htmlspecialchars($a['description'])) ?></p>
                <div class="price"><?= number_format($a['prix'], 2, ',', ' ') ?> €</div>
            </div>
        <?php endforeach; ?>

        <?php if (empty($annonces) && !isset($error)): ?>
            <div class="empty-state">Aucune annonce pour le moment.</div>
        <?php endif; ?>
    </div>
</main>

</body>
</html>