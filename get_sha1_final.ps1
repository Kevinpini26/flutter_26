# Script PowerShell pour obtenir le SHA-1 - SOLUTION RAPIDE
# Double-cliquez sur ce fichier ou exécutez-le dans PowerShell

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OBTENIR LE SHA-1 POUR FIREBASE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$keystorePath = "$env:USERPROFILE\.android\debug.keystore"

if (Test-Path $keystorePath) {
    Write-Host "✓ Keystore trouvé" -ForegroundColor Green
    Write-Host ""
    Write-Host "Exécution de la commande..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor Gray
    Write-Host ""
    
    $result = keytool -list -v -keystore $keystorePath -alias androiddebugkey -storepass android -keypass android 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host $result
        Write-Host ""
        Write-Host "----------------------------------------" -ForegroundColor Gray
        Write-Host ""
        Write-Host "✓ COMMANDE RÉUSSIE" -ForegroundColor Green
        Write-Host ""
        Write-Host "INSTRUCTIONS:" -ForegroundColor Yellow
        Write-Host "1. Cherchez la ligne 'SHA1:' ci-dessus" -ForegroundColor White
        Write-Host "2. Copiez la valeur (format: XX:XX:XX:XX:...)" -ForegroundColor White
        Write-Host "3. Allez dans Firebase Console:" -ForegroundColor White
        Write-Host "   https://console.firebase.google.com/" -ForegroundColor Cyan
        Write-Host "4. Project Settings > Your apps > Android app" -ForegroundColor White
        Write-Host "5. Cliquez sur 'Add fingerprint'" -ForegroundColor White
        Write-Host "6. Collez le SHA-1 et enregistrez" -ForegroundColor White
        Write-Host "7. Attendez 5-10 minutes" -ForegroundColor White
        Write-Host "8. Relancez l'application" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "✗ ERREUR lors de l'exécution" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
    }
} else {
    Write-Host "✗ Keystore introuvable à: $keystorePath" -ForegroundColor Red
    Write-Host ""
    Write-Host "SOLUTION:" -ForegroundColor Yellow
    Write-Host "1. Compilez d'abord votre application:" -ForegroundColor White
    Write-Host "   flutter build apk --debug" -ForegroundColor Cyan
    Write-Host "2. Relancez ce script" -ForegroundColor White
    Write-Host ""
}

Write-Host "Appuyez sur une touche pour fermer..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

