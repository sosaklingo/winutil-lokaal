# WinUtil Lokaal

**Nederlands** · [English](README.en.md)

## Projectoverzicht / Project overview

**Nederlands (NL)** — Lokale WinUtil-kopie voor Windows 11 met Nederlandstalige en Engelstalige handleidingen, SHA-256- en PowerShell-syntaxiscontrole en een offline starter.

**English (EN)** — Local WinUtil copy for Windows 11 with Dutch and English guides, SHA-256 and PowerShell syntax verification, and an offline launcher.

| Nederlands | English |
| --- | --- |
| Originele PowerShell-release **26.10.28** van Chris Titus Tech | Original PowerShell release **26.10.28** by Chris Titus Tech |
| Start lokaal zonder het WinUtil-script opnieuw te downloaden | Launch locally without downloading the WinUtil script again |
| Windows 11, Windows PowerShell 5.1 en administratoraccount vereist | Windows 11, Windows PowerShell 5.1 and an administrator account required |
| Offline starter; downloads en appinstallaties vereisen internet | Offline launcher; downloads and app installations require internet access |
| De WinUtil-interface zelf is hoofdzakelijk Engelstalig | The WinUtil interface itself is primarily in English |

**Handleiding / User guide:** [Nederlands](#downloaden-en-starten) · [English](README.en.md)

## Downloaden en starten

1. Open deze openbare GitHub-repository en kies **Code → Download ZIP**. [Download de ZIP rechtstreeks](https://github.com/sosaklingo/winutil-lokaal/archive/refs/heads/main.zip).
2. Klik in Verkenner met de rechtermuisknop op de ZIP en kies **Alles uitpakken**. Houd de bestanden bij elkaar.
3. Dubbelklik in de uitgepakte map op **Start-WinUtil.cmd**. Kies **Start-WinUtil-Offline.cmd** als je WinUtil in offline-modus wilt openen.
4. Bevestig de Windows-melding voor administratorrechten. Daarna hoort een apart venster met de titel **WinUtil** te verschijnen. Gebruik zo nodig **Alt+Tab** om van het consolevenster naar WinUtil te wisselen.

| Bestand | Wat het doet |
| --- | --- |
| `Start-WinUtil.cmd` | Start de lokale kopie met alle beschikbare functies. Appinstallaties en andere downloads hebben internet nodig. |
| `Start-WinUtil-Offline.cmd` | Start met de ingebouwde optie `-Offline`. Het tabblad **Install** is dan uitgeschakeld. Externe links en functies die downloads vereisen blijven afhankelijk van internet. |
| `Controleer-WinUtil.cmd` | Controleert SHA-256 en de PowerShell-syntaxis. Kan zonder administratorrechten worden uitgevoerd en opent WinUtil niet. |

WinUtil kan Windows-instellingen wijzigen nadat je in de interface een actie kiest. Lees de beschrijving vóór je een tweak toepast.

## Problemen oplossen

| Wat je ziet | Wat je kunt doen |
| --- | --- |
| Alleen een PowerShell-venster | Wacht enkele seconden. Kijk op de taakbalk of gebruik **Alt+Tab** voor het aparte venster **WinUtil**. |
| De Windows-melding voor administratorrechten is geweigerd | Start opnieuw en bevestig de melding. Op een beheerde pc kan de beheerder uitvoering beperken. |
| De starter mist een bestand | Pak de volledige ZIP opnieuw uit en open de starter vanuit de uitgepakte map. |
| SHA-256 komt niet overeen | Download het pakket opnieuw en voer `Controleer-WinUtil.cmd` uit. De starter blokkeert een afwijkende kopie. |
| **Please select the program(s) to install or upgrade** | Vink op **Install** eerst ten minste één programma aan. |
| Het venster sluit of verschijnt niet | Noteer de foutmelding. In Verkenner kun je in de adresbalk `%LOCALAPPDATA%\winutil\logs` plakken om het nieuwste log te vinden, als WinUtil al aan het loggen was. Deel alleen het relevante fragment en verwijder persoonlijke gegevens. |

## Bron en controle

De meegeleverde `winutil-26.10.28.ps1` behoudt exact de bytes van de [officiële WinUtil-release 26.10.28](https://github.com/ChrisTitusTech/winutil/releases/tag/26.10.28). Het releasebestand heeft geen Authenticode-handtekening. SHA-256 controleert dat de lokale kopie overeenkomt met het gepubliceerde bestand.

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath .\winutil-26.10.28.ps1
```

```text
d0444cb266953d927e5cee71455f4f1a6da2d5b3cfd7e440dceb4e6b1cbf4f7f
```

De startbestanden gebruiken Windows PowerShell met `-ExecutionPolicy Bypass` voor hun eigen processen. Dat verandert het ingestelde beleid van Windows niet en omzeilt geen centraal afgedwongen beleid. Deze uitgave is vastgezet op 26.10.28. Voor een nieuwere versie kun je terecht bij het [officiële WinUtil-project](https://github.com/ChrisTitusTech/winutil/releases).

## Licentie en ondersteuning

Dit is een onafhankelijk startpakket rond WinUtil. WinUtil is gemaakt door Chris Titus Tech en bijdragers. De oorspronkelijke [MIT-licentie](LICENSE) is meegeleverd. Meld problemen met de starters of handleiding bij deze repository. Voor fouten in WinUtil zelf kun je terecht bij het [officiële project](https://github.com/ChrisTitusTech/winutil/issues).
