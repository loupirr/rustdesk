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
- Accès à Internet pour télécharger les binaires (.bin) et scripts

---

## Installation temporaire

### Windows
1. Téléchargez le fichier .bat depuis répertoire Github.
3. Double-cliquez sur le fichier .bat fournis

### Linux
Le script d'installation Linux s'exécute en une ligne. Exécutez dans un terminal :
```bash
curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/loupirr/rustdesk/refs/heads/main/install_temporaire/linux/install_client-linux | bash
```
Le script téléchargera et installera le client, puis configurera les permissions nécessaires. Lisez le script avant exécution si vous souhaitez vérifier son contenu.

---
---

## Installation complete ( autorisation requise )

### Windows
1. Téléchargez le fichier .bat depuis répertoire Github.
2. Double-cliquez sur le fichier .bat fournis

### Linux
Le script d'installation Linux s'exécute en une ligne. Exécutez dans un terminal en root:
```bash
sudo curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/loupirr/rustdesk/refs/heads/main/install_complete/linux/client_rustdesk_linux | bash
```
Le script téléchargera et installera le client, puis configurera les permissions nécessaires. Lisez le script avant exécution si vous souhaitez vérifier son contenu.

---


## Utilisation
Après l'installation :

- Rustdesk je lance tout seul de manière temporaire avec les configuration pour se connecter au serveur.
- Communiquer votre ID à la personne voulue.
- Le MDP est le même pour tout les clients (pour le changer, aller voir dans le fichier d'installation)

---
