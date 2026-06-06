# Plan d'implémentation - Améliorations Dev 1 & Dev 2

Ce plan décrit les modifications à apporter à l'application **Narco** pour intégrer les améliorations techniques, d'expérience utilisateur (UX) et d'architecture sur les modules de création (Dev 1) et de transfert (Dev 2).

## User Review Required

> [!IMPORTANT]
> Les modifications impliquent du code natif Android (Kotlin) pour la gestion du cycle de vie du Bluetooth et du NFC.
> Avant de commencer à appliquer ces modifications, nous devrons exécuter un nettoyage de la branche de travail locale (`git checkout -- <fichier>`) et un `git pull` pour récupérer les 11 commits de retard contenant le code de Faouz.

## Proposed Changes

---

### [Git Setup]

#### [PRE-REQUISITE] [Git pull]
- Nettoyage des modifications locales sur [transfer_screen.dart](file:///home/ruxel/NFC/narco/lib/features/token_transfer/presentation/screens/transfer_screen.dart).
- Exécution de `git pull` pour rapatrier le travail de Faouz.

---

### [Android Platform Layer]

#### [MODIFY] [BluetoothChannelHandler.kt](file:///home/ruxel/NFC/narco/android/app/src/main/kotlin/com/example/narco/BluetoothChannelHandler.kt)
- Ajouter un mécanisme de timeout (ex: 6 secondes) via un `Handler` pour forcer la fermeture du socket RFCOMM si la connexion bloque indéfiniment.
- Exposer une méthode `cleanup()` pour arrêter le serveur Bluetooth et la découverte proprement, afin d'éviter les fuites de mémoire.

#### [MODIFY] [MainActivity.kt](file:///home/ruxel/NFC/narco/android/app/src/main/kotlin/com/example/narco/MainActivity.kt)
- Gérer l'appel MethodChannel `"openNfcSettings"` pour ouvrir l'écran de configuration NFC système d'Android.
- Appeler `bluetoothHandler?.cleanup()` dans la méthode `onDestroy()` de l'activité principale.

#### [MODIFY] [AndroidManifest.xml](file:///home/ruxel/NFC/narco/android/app/src/main/AndroidManifest.xml)
- Ajouter l'attribut `android:enableOnBackInvokedCallback="true"` sur la balise `<application>` pour éliminer l'avertissement Android 13+ concernant la navigation arrière.

---

### [Flutter Services Layer]

#### [MODIFY] [nfc_service.dart](file:///home/ruxel/NFC/narco/lib/features/token_transfer/data/services/nfc_service.dart)
- Ajouter la méthode `openNfcSettings()` pour invoquer l'ouverture des paramètres natifs.
- Modifier la signature de la fonction `receiveToken` (et le callback `onStage`) pour remonter le niveau de progression réel `double? progress` (calculé à partir de `served / total` reçus via les événements APDU).

---

### [Flutter Presentation & VM Layer]

#### [MODIFY] [transfer_vm.dart](file:///home/ruxel/NFC/narco/lib/features/token_transfer/presentation/providers/transfer_vm.dart)
- Ajouter un champ `progress` dans la classe `TransferState` pour suivre l'état de la transmission.
- Mettre à jour `progress` dans le ViewModel au fur et à mesure des rappels de `onStage` (NFC et Bluetooth).

#### [MODIFY] [transfer_screen.dart](file:///home/ruxel/NFC/narco/lib/features/token_transfer/presentation/screens/transfer_screen.dart)
- Utiliser `ref.listen` pour déclencher des retours haptiques (`HapticFeedback.mediumImpact()` lors de la connexion, `HapticFeedback.vibrate()` à la réussite).
- Ajouter une barre de progression linéaire/circulaire indiquant le pourcentage d'envoi réel en exploitant le champ `progress` de l'état.
- Lorsque le NFC est désactivé (erreur de statut), afficher un bouton d'action *"Activer le NFC dans les paramètres"* relié à `openNfcSettings()`.

---

### [Flutter Repository Layer]

#### [MODIFY] [token_repository_impl.dart](file:///home/ruxel/NFC/narco/lib/features/token_creation/data/repositories/token_repository_impl.dart)
- Sécuriser l'écriture SQLite + cache Hive dans `saveToken` et `updateTokenStatus` avec un système de rollback manuel en cas d'erreur sur l'une des sources de données afin de garantir l'atomicité.

---

## Verification Plan

### Automated Tests
- Lancer les tests unitaires existants : `flutter test`
- Vérifier le bon fonctionnement de l'encodeur NDEF après les modifications.

### Manual Verification
- Déployer l'application sur l'émulateur/téléphone Android (`flutter run`).
- Désactiver le NFC et vérifier que l'interface affiche le bouton de redirection vers les paramètres, puis l'activer.
- Lancer un transfert NFC simulé et observer la progression de la barre ainsi que les retours haptiques.
