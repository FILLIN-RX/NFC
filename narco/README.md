# 🚀 Narco - Gestionnaire de Jetons Sécurisés (NFC/Bluetooth)

**Narco** est une application mobile moderne développée avec Flutter, conçue pour la création, la gestion et le transfert sécurisé de jetons numériques (tokens) via NFC et Bluetooth. 

Ce projet a été réalisé dans le cadre d'un TP portant sur le développement mobile, la sécurité des données et l'interaction avec le matériel (hardware).

---

## 📱 Aperçu du Projet

L'application permet de générer des jetons uniques, de les stocker localement de manière sécurisée et de les transférer à d'autres appareils. Elle met l'accent sur une expérience utilisateur premium avec une interface élégante et des retours haptiques.

### Fonctionnalités Clés
- **Génération de Jetons** : Création de jetons avec identifiants uniques (UUID) et signatures de sécurité (SHA-256).
- **Transfert NFC (Contact)** : Échange de données par contact direct via le protocole ISO-DEP et HCE (Host Card Emulation).
- **Transfert Bluetooth (Proximité)** : Canal de secours utilisant un socket RFCOMM (Bluetooth Classique) pour les transferts à plus longue portée.
- **Gestion du Portefeuille** : Consultation des jetons actifs, consommés ou reçus.
- **Sécurité Avancée** : Authentification biométrique, hachage des données et protection contre le rejeu.
- **Mode Hors-ligne** : Stockage local robuste (SQLite + Hive).

---

## 🛠️ Robustesse et Gestion des Erreurs

La fiabilité est l'un des piliers de Narco. L'application intègre des mécanismes avancés pour garantir un fonctionnement sans faille.

### 1. Gestion des Erreurs (Pattern Result)
Toutes les opérations sensibles (réseau, matériel, base de données) utilisent le pattern **Result<T>**. Au lieu de lancer des exceptions qui pourraient faire planter l'application, les méthodes retournent soit un objet `Success`, soit un objet `Failure` contenant :
- Un message d'erreur explicite pour l'utilisateur.
- L'erreur technique originale et la trace d'appel pour le débogage.

### 2. Robustesse des Transferts
- **Timeouts** : Chaque session de scan (NFC ou Bluetooth) est limitée dans le temps (ex: 30s) pour éviter de vider la batterie en cas d'absence de cible.
- **Tentatives de Reconnexion** : Le module Bluetooth tente automatiquement jusqu'à 3 reconnexions en cas de micro-coupure durant l'envoi.
- **Atomicité des Données** : Si un transfert échoue à mi-chemin, l'application effectue un "rollback" : le jeton n'est pas marqué comme "transféré" dans la base de données source, et les données partielles sont effacées chez le destinataire.

### 3. Gestion Multi-Appareils
- **Conflits NFC** : Si plusieurs appareils ou tags sont détectés simultanément par l'antenne NFC, le transfert est immédiatement interrompu avec une alerte pour éviter toute corruption de données.
- **Sélection Bluetooth** : Contrairement au NFC (contact unique), le Bluetooth affiche une liste filtrée des appareils à proximité. L'utilisateur choisit explicitement sa cible.
- **Protocole de Confirmation (ACK/NACK)** : Pour le Bluetooth, un système d'accusé de réception est en place. Le destinataire doit accepter manuellement le jeton avant que celui-ci ne soit définitivement débité du portefeuille de l'émetteur.

---

## 🛡️ Sécurité & Intégrité

- **Vérification d'Empreinte** : À chaque réception, l'application recalcule le hash du jeton. Si la signature ne correspond pas (tentative de falsification), le jeton est rejeté.
- **Anti-Duplication** : Un jeton possède un ID unique. L'application refuse d'enregistrer deux fois le même ID pour empêcher les attaques par rejeu.
- **Protection Biométrique** : L'accès aux fonctionnalités de transfert est verrouillé par l'empreinte digitale ou la reconnaissance faciale de l'utilisateur.

---

## 🏗️ Architecture Technique

Le projet suit une architecture **Feature-First** (Riverpod), garantissant une modularité maximale.

### Stack Technique
- **Framework** : Flutter (Dart)
- **Gestion d'État** : Riverpod (Générateurs)
- **Bases de Données** : SQLite (persistance) & Hive (cache rapide).
- **Communication** : `nfc_manager` (NFC), `flutter_blue_plus` (Bluetooth).
- **Journalisation** : `AppLogger` catégorisé (NFC, BT, SEC, HST).

---

## 🚀 Installation

1. `flutter pub get`
2. `flutter pub run build_runner build --delete-conflicting-outputs`
3. `flutter run` (Nécessite un appareil physique pour les fonctionnalités NFC/BT)

---

*Projet réalisé dans le cadre du module [Nom du Module] - 2026.*
