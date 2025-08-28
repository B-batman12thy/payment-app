# Payment App (Flutter + Dio + Provider)

Interface **Flutter (Web + Mobile)** pour consommer l’API de paiements (JWT), avec **tableau de bord**, **historique filtrable** et **création de paiements** (upload de justificatifs).

---

## ✨ Fonctionnalités

- Auth (via JWT de l’API) : **register / login / me / logout**
- Dashboard : **solde simulé**, **total du mois**, **5 derniers paiements**
- Paiements :
  - **Création** (JSON ou `multipart` avec fichier justificatif)
  - **Historique** + filtres `?day=YYYY-MM-DD` | `?month=YYYY-MM` | `?year=YYYY`
- UI Material 3 : **cards**, **chips de statut**, **responsive**

---

## 🧰 Stack & Prérequis

- **Flutter 3.x** (SDK installé, `flutter doctor -v` OK)
- **Dépendances** : `dio`, `provider`, `shared_preferences`, `file_picker`, `intl`
- **API Laravel** démarrée (ex : `http://127.0.0.1:8000/api`)  
  ➜ CORS actif côté back pour `localhost` / `127.0.0.1`

---

## 🚀 Installation

```bash
# 1) Récupérer les dépendances
flutter pub get
