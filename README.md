# wd-mycloud-initramfs
**Boot d’un WD My Cloud Home Duo avec un initramfs minimal**
> *Remplacement du système d’origine par une image Linux autonome, bootée en RAM via U-Boot et UART.*
***
# 🚀 Boot d’un WD My Cloud Home Duo avec un initramfs minimal (Linux 5.15 + Buildroot)

> **Projet d’embarqué low-level** : remplacement du système d’origine d’un NAS WD par une image Linux minimaliste bootée en RAM via initramfs.  
> Démonstration de maîtrise du noyau, du Device Tree, de Buildroot et du boot U-Boot.

---

## 🎯 Objectif

Booter un **WD My Cloud Home Duo** (SoC Realtek RTD1295) avec une **image Linux autonome**, sans dépendre du stockage interne, pour :
- Démontrer la compréhension du boot embarqué
- Valider la compatibilité matérielle (UART, USB, Ethernet)
- Créer une base pour du debug matériel ou du pentest léger

---

## 🖥️ Spécifications techniques

| Composant | Valeur |
|----------|-------|
| **SoC** | Realtek RTD1295 (ARM64) |
| **Noyau** | Linux 5.15.124 (stable) |
| **Rootfs** | BusyBox + musl, intégré en initramfs |
| **Device Tree** | `rtd1295-zidoo-x9s.dtb` |
| **Boot** | U-Boot → clé USB FAT32 → `Image` auto-boot |
| **RAM only** | Aucune persistance, tout en mémoire |

---

## 🔌 Processus de boot
[UART] → U-Boot manuel
       → Charge Image depuis USB
       → Décompresse initramfs
       → Lance /init (BusyBox)
       → Shell root prêt

---
## 📡 Serial Monitor Logs (Phase 1)

### ✅ Boot Réussi
<img width="822" height="110" alt="image" src="https://github.com/user-attachments/assets/4d33f5fe-ca3a-499d-928f-6112155bdde9" />

---
## 📡 Logs du Serial Monitor (Phase 1 - Boot Minimal)

| **Étape**               | **Message Clé**                                                                 | **Signification**                                                                 |
|-------------------------|---------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| **Initialisation UART** | `ttyS0 - failed to request DMA`                                                 | Port série opérationnel (sans DMA)                                               |
| **Détection CPU**       | `cpufreq: 0 .volidx = 0 .freq = 300000`                                        | CPU RTD1295 détecté (fréquence 300 MHz à 1.4 GHz)                                |
| **Détection Stockage**  | `EMMC : emmc of_node found`<br>`SATA link up 6.0 Gbps`                         | eMMC et ports SATA fonctionnels                                                  |
| **Mount RootFS**        | `EXT4-fs (mmcblk0p2): mounted filesystem`                                      | Initramfs chargé en RAM                                                          |
| **Shell Prêt**          | `root@pelican32_mini:/ #`                                                      | **Boot réussi** : Shell root accessible via UART                                 |

![Boot UART](screenshots/boot-uart.jpg)

## 🐛 Analyse des Erreurs (Pour Debug)

| **Type**                | **Exemple de Log**                                                             | **Solution**                                                                   |
|-------------------------|--------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| Corruption FAT32        | `FAT-fs (mmcblk0p1): not properly unmounted`                                  | `fsck.vfat -a /dev/mmcblk0p1` ou reformater                                  |
| Paquets réseau perdus   | `eth0: RX packets:880 dropped:88`                                             | Vérifier câble/switch ou recharger pilote (`ifconfig eth0 down && up`)       |
| Avertissements SELinux  | `init: avc: denied { set } for property=wd.log.mac_hashed`                    | Ignorer (dév) ou ajouter des règles SELinux                                  |

> 💡 **Astuce** : Consultez [les logs complets](logs/full_boot.log) pour plus de détails.





---

## 📂 Fichiers inclus

- `configs/linux.config` : configuration noyau (initramfs, DTB, support USB)
- `configs/buildroot.config` : Buildroot avec musl et BusyBox
- `dtb/rtd1295-zidoo-x9s.dtb` : Device Tree corrigé
- `scripts/create-usb.sh` : formatage clé bootable
- `rootfs/init` : script d’initialisation minimal

---

## 🛠️ Ce que j'ai appris

- **Le rôle critique du Device Tree** dans le boot embarqué
- **Comment intégrer un rootfs en initramfs** sans erreurs de chemin
- **Les pièges de la recompilation noyau** (`.stamp_built`, `make clean`)
- **L’importance du debug série (UART)** pour comprendre les plantages
- **La puissance de `fdtdump`, `strings`, `grep`** pour analyser les binaires

---

## 📎 Ressources utiles

- [Buildroot Documentation](https://buildroot.org/)
- [Kernel Config Guide](https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html)
- [Realtek RTD1295 Datasheet (partiel)](https://github.com/rd129x)

---

## 📄 Licence

Projet publié sous **MIT License** – libre d’étudier, modifier, partager.  
Les binaires (Image, DTB) sont fournis à titre éducatif.

---

## ⚠️ Avertissement

Ce projet est **expérimental**.  
Il n’a **aucune persistance**, ne monte **aucun stockage**, et ne doit **pas être utilisé en production**.  
Utilisez-le uniquement pour apprendre ou déboguer.
