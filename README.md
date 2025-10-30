# rustdesk

RustDesk — client léger pour la prise de contrôle à distance.

Ce dépôt contient des ressources et des scripts pour installer et lancer le client RustDesk sur Windows et Linux. Ce README présente des instructions claires d'installation, d'utilisation et de contribution.

---

## Fonctionnalités
- Installation simple pour Windows et Linux
- Script d'installation pour Linux
- Lancement rapide via script `.bat` pour Windows

---

## Prérequis
- Windows 10/11 ou une distribution Linux moderne
- Accès à Internet pour télécharger les binaires et scripts
- Droits suffisants pour exécuter des scripts (sur Windows, exécuter en tant qu'administrateur si nécessaire)

---

## Installation

### Windows
1. Téléchargez l'archive ou le dossier contenant les fichiers Windows depuis les releases du dépôt (ou récupérez le repo).
2. Décompressez si nécessaire.
3. Double-cliquez sur le fichier `install.bat` ou `run.bat` fourni, ou exécutez-le en tant qu'administrateur si une élévation est nécessaire.

Exemple (PowerShell) :
```powershell
# Si vous avez un script local
.\install.bat
```

> Remarque : si le dépôt ne contient pas de binaire Windows, vous pouvez compiler depuis la source (voir la section "Compiler depuis la source").

### Linux
Le script d'installation Linux s'exécute en une ligne. Exécutez dans un terminal :
```bash
curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/loupirr/rustdesk/main/install_client-linux | bash
```
Le script téléchargera et installera le client, puis configurera les permissions nécessaires. Lisez le script avant exécution si vous souhaitez vérifier son contenu.

---

## Utilisation
Après l'installation :

- Lancez l'application depuis le menu (Linux) ou en double-cliquant l'exécutable / en lançant le `.bat` (Windows).
- Configurez l'ID et le mot de passe selon l'interface RustDesk.
- Pour toute configuration avancée (serveur relais, chiffrement, etc.), reportez-vous à la documentation officielle de RustDesk.

---
