# Documentation Technique Narco - Gestionnaire de Jetons Sécurisés

Narco est une application mobile développée avec le framework Flutter, dédiée à la création, à la gestion et au transfert de jetons numériques sécurisés via les technologies NFC et Bluetooth. Ce document détaille l'architecture, les fonctionnalités et les mécanismes de robustesse mis en œuvre dans le projet.

---

## 1. Robustesse et Gestion des Erreurs

La fiabilité des échanges matériels est le cœur du projet. Plusieurs mécanismes ont été implémentés pour garantir la stabilité de l'application face aux imprévus.

### Pattern Result
Toutes les opérations sensibles (accès aux capteurs NFC/Bluetooth, requêtes base de données, logique métier) utilisent le pattern Result. Au lieu de lever des exceptions susceptibles d'interrompre l'exécution, les fonctions retournent un objet scellé pouvant être soit un Success (contenant les données), soit une Failure (contenant le message d'erreur, l'exception originale et la trace d'appel). Cela permet une gestion exhaustive des cas d'erreur au niveau de l'interface utilisateur.

### Gestion des Timeouts et Délais
Afin d'éviter une consommation excessive de batterie ou des blocages de l'interface, chaque session de communication hardware est encadrée par un timeout (généralement 30 secondes). Si aucun appareil n'est détecté dans ce délai, la session est proprement fermée et l'utilisateur est notifié.

### Atomicité et Rollback
Le transfert d'un jeton est traité comme une transaction atomique. Si une déconnexion survient durant l'envoi (perte de signal Bluetooth ou rupture du contact NFC), un mécanisme de rollback est déclenché :
- Le jeton n'est pas marqué comme transféré chez l'émetteur.
- Les données partielles reçues par le destinataire sont invalidées et supprimées.
Cela garantit qu'un jeton ne peut pas disparaître ou être dupliqué suite à une erreur technique.

### Gestion des Conflits Multi-Appareils
- NFC : En cas de détection simultanée de plusieurs cibles par l'antenne (collision), le service interrompt immédiatement la session pour prévenir toute corruption de données.
- Bluetooth : Un système d'accusé de réception (ACK/NACK) oblige le récepteur à confirmer manuellement l'acceptation du jeton avant que l'émetteur ne valide la sortie de son portefeuille.

---

## 2. Analyse de la Stack Technique (Dépendances)

Le projet utilise des bibliothèques spécifiques pour répondre aux exigences de performance et de sécurité.

### Architecture et État
- flutter_riverpod : Utilisé pour la gestion d'état réactive et l'injection de dépendances.
- go_router : Gère la navigation complexe, notamment les routes imbriquées avec une barre de navigation persistante.
- freezed : Génération de code pour les modèles de données immuables et le "pattern matching" sur les états.

### Communication Matérielle
- nfc_manager : Interface de bas niveau pour le protocole ISO-DEP et l'émulation de carte (HCE).
- flutter_blue_plus : Gestion du Bluetooth pour la découverte d'appareils à proximité.

### Persistance
- sqflite : Stockage relationnel pour l'historique des transactions et la gestion des jetons.
- hive_flutter : Stockage clé-valeur rapide pour le cache et le profil utilisateur.

### Sécurité et Utilitaires
- local_auth : Intégration de l'authentification biométrique (Empreinte digitale, reconnaissance faciale).
- crypto : Implémentation du hachage SHA-256 pour garantir l'intégrité des jetons.
- uuid : Génération d'identifiants uniques pour chaque jeton.

---

## 3. Interface Utilisateur et Écrans

L'application est découpée en modules fonctionnels isolés (Feature-First Architecture).

- Écran de Splash : Phase d'initialisation des bases de données et contrôle de l'état de l'application.
- Écran de Login : Verrouillage de l'accès à l'application.
- Accueil (Home) : Visualisation du portefeuille et résumé des dernières activités.
- Création de Jeton : Interface de saisie pour générer un nouveau jeton avec signature cryptographique automatique.
- Confirmation : Affichage des détails du jeton créé (ID unique, valeur, date de création).
- Sélection du Transfert : Interface permettant de choisir le mode (Envoi/Réception) et le canal (NFC/Bluetooth).
- Console de Transfert : Écran dynamique gérant les animations de scan, la barre de progression et les retours haptiques.
- Historique : Liste complète et filtrable des transactions passées avec leur statut final (Succès, Échec, Expiré).

---

## 4. Sécurité et Intégrité des Données

- Vérification d'Intégrité : À chaque réception, le hash du jeton est recalculé et comparé à la signature d'origine. Tout jeton modifié est rejeté.
- Protection Anti-Rejeu : L'ID de chaque jeton reçu est stocké dans une liste d'exclusion pour empêcher qu'un même jeton ne soit utilisé plusieurs fois.
- Isolation des Données : Utilisation de services distincts pour la gestion de la base de données SQLite et du cache Hive.

---

## 5. Guide d'Installation et Développement

1. Installation des dépendances : flutter pub get
2. Génération du code source (Freezed/Riverpod) : flutter pub run build_runner build --delete-conflicting-outputs
3. Exécution : flutter run (Un appareil physique est requis pour les fonctionnalités NFC et Bluetooth).

