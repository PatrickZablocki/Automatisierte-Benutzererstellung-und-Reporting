# Definiere den Pfad zur CSV-Datei, in der später die Benutzerdaten gespeichert werden.
$csvPath = "C:\Users\Public\benutzerliste.csv"

# Erstelle eine Liste von Benutzern mit Benutzernamen und Passwörtern.
# In der Praxis könnte man diese Daten auch aus einer Datei einlesen.
$users = @(
    @{ Benutzername = "User1"; Passwort = "Passwort123!" },
    @{ Benutzername = "User2"; Passwort = "Passwort456!" },
    @{ Benutzername = "User3"; Passwort = "Passwort789!" }
)

# Initialisiere eine leere Liste, die für das Reporting verwendet wird.
$userReport = @()

# Durchlaufe jeden Benutzer aus der Liste und erstelle das Benutzerkonto.
foreach ($user in $users) {
    # Hole den Benutzernamen und das Passwort aus der aktuellen Benutzereingabe.
    $username = $user.Benutzername
    $password = $user.Passwort

    # Setze den vollständigen Namen auf den Benutzernamen (in diesem Fall).
    $fullName = $username

    # Prüfe, ob der Benutzer bereits existiert.
    if (-Not (Get-LocalUser -Name $username -ErrorAction SilentlyContinue)) {
        # Wenn der Benutzer noch nicht existiert, erstelle ihn.
        New-LocalUser -Name $username -Password (ConvertTo-SecureString $password -AsPlainText -Force) -FullName $fullName -Description "Automatisch erstellter Benutzer" -PasswordNeverExpires $true
        
        # Ausgabe: Erfolgreiche Erstellung des Benutzers.
        Write-Host "Benutzer '$username' wurde erfolgreich erstellt."

        # Speichere die Information zur Erstellung für das Reporting.
        $userReport += [PSCustomObject]@{
            Benutzername = $username
            Status = "Erstellt"
            Erstellungsdatum = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
    } else {
        # Falls der Benutzer bereits existiert, gebe dies aus.
        Write-Host "Benutzer '$username' existiert bereits."

        # Speichere diese Information im Reporting.
        $userReport += [PSCustomObject]@{
            Benutzername = $username
            Status = "Existiert bereits"
            Erstellungsdatum = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
    }
}

# Speichere die Report-Daten in der CSV-Datei ab.
$userReport | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

# Ausgabe einer Info, dass der Prozess abgeschlossen ist.
Write-Host "Benutzererstellung abgeschlossen. Die Details sind in '$csvPath' gespeichert."

# Lade die CSV-Datei und zeige sie in der Konsole als Tabelle an.
Import-Csv -Path $csvPath | Format-Table -AutoSize
