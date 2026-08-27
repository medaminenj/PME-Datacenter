# PME-Datacenter — Infrastructure Automatisée pour une PME

Projet de stage ESPRIT : mise en place d'un mini-datacenter automatisé reproduisant l'infrastructure informatique d'une PME, via une approche **Infrastructure as Code**.

**Auteur :** Neji Mohamed Amine
**Encadrant :** Fitouri Omar
**Année universitaire :** 2025 – 2026

---

## Stack technique

| Technologie | Rôle |
|---|---|
| **Terraform** | Provisionnement automatique des machines virtuelles (via l'API `vmrest` de VMware Workstation) |
| **Puppet** | Configuration et maintien en conformité des serveurs |
| **FreeIPA** | Gestion centralisée des identités, authentification unique (SSO), DNS interne |
| **Zabbix** | Supervision des ressources systèmes et alerting |
| **ELK Stack** | Centralisation et visualisation des journaux systèmes (Elasticsearch, Logstash, Kibana, Filebeat). Kibana permet de consulter et filtrer les logs de l'ensemble des 6 machines depuis une seule interface, avec recherche par machine, service ou fenêtre temporelle (voir section 4.5 du rapport). |

## Architecture

6 machines virtuelles, 2 systèmes d'exploitation (Ubuntu 22.04 LTS et Rocky Linux 9) :

| VM | Rôle | OS | IP |
|---|---|---|---|
| `puppet-freeipa` | Puppet Master (initialement prévu pour héberger aussi FreeIPA) | Ubuntu 22.04 | 192.168.190.10 |
| `freeipa-server` | FreeIPA Server (auth, DNS, LDAP) | Rocky Linux 9 | 192.168.190.15 |
| `elk-server` | Elasticsearch + Logstash + Kibana | Ubuntu 22.04 | 192.168.190.11 |
| `zabbix-server` | Zabbix Server + Frontend | Ubuntu 22.04 | 192.168.190.12 |
| `web-server` | Apache (client PME) | Ubuntu 22.04 | 192.168.190.13 |
| `db-server` | MySQL (client PME) | Ubuntu 22.04 | 192.168.190.14 |

> **Pourquoi 2 OS ?** Le paquet `freeipa-server` a été retiré des dépôts officiels Ubuntu depuis la version 20.04. La machine `freeipa-server` utilise donc Rocky Linux 9, plateforme native de FreeIPA. Voir la section 3.4 du rapport de stage pour la justification complète.

## Structure du dépôt

```
.
├── main.tf                 # Déclaration du provider Terraform (vmworkstation)
├── variables.tf            # Variables (identifiants VMware, IDs des templates)
├── vms.tf                  # Déclaration des 6 ressources vmworkstation_vm
├── outputs.tf               # Outputs Terraform (IDs des VMs créées)
├── terraform.tfvars         # ⚠️ NON versionné (contient les identifiants réels) — voir .gitignore
├── .gitignore
├── puppet/
│   ├── manifests/
│   │   └── site.pp          # Assignation des rôles par nœud (node blocks)
│   └── modules/
│       ├── apache/           # Installe et maintient Apache (web-server)
│       ├── mysql/             # Installe et maintient MySQL (db-server)
│       ├── zabbix_agent/      # Agent Zabbix, multi-OS (Debian/RedHat)
│       ├── freeipa_client/    # Intégration au domaine FreeIPA, mot de passe via Hiera
│       └── filebeat/          # Agent Filebeat, multi-OS, expédie les logs vers Logstash
└── docs/
    └── architecture_diagram.png
```

**Remarque :** le dossier `puppet/data/` (contenant `common.yaml` avec le mot de passe admin FreeIPA en clair pour Hiera) existe uniquement sur le Puppet Master en production et n'est **jamais versionné** — voir `.gitignore`.

## Prérequis

- VMware Workstation Pro (avec le service `vmrest` activé)
- Terraform ≥ 1.0
- Deux images de référence (templates) déjà créées et arrêtées dans VMware :
  - Un template Ubuntu 22.04 LTS
  - Un template Rocky Linux 9
- Puppet 8 installé manuellement sur `puppet-freeipa` (Master) avant le premier provisionnement complet

## Utilisation

### 1. Provisionner les machines virtuelles

```bash
terraform init
terraform plan
terraform apply
```

⚠️ Créez un fichier `terraform.tfvars` (non versionné) avec vos identifiants VMware réels :
```hcl
vmware_user     = "votre_utilisateur"
vmware_password = "votre_mot_de_passe"
```

### 2. Appliquer la configuration Puppet

Sur chaque VM, une fois l'agent Puppet installé et le certificat signé sur le Master :
```bash
sudo /opt/puppetlabs/bin/puppet agent -t
```

Les rôles de chaque nœud sont définis dans `puppet/manifests/site.pp`.

> **Note :** l'installation de l'agent Puppet sur chaque VM est réalisée manuellement lors du premier provisionnement (le provider Terraform utilisé pilote VMware Workstation via `vmrest` et ne supporte pas de mécanisme cloud-init/user-data). L'automatisation porte sur la configuration une fois l'agent en place : chaque agent applique et maintient automatiquement sa configuration à intervalle régulier (cycle Puppet de 30 minutes par défaut), sans intervention manuelle supplémentaire.

### 3. Accès aux interfaces web

| Service | URL |
|---|---|
| FreeIPA | `https://freeipa-server.pme.local/ipa/ui` |
| Zabbix | `http://zabbix-server.pme.local/zabbix` |
| Kibana | `https://elk-server.pme.local:5601` |

## Documentation complémentaire

- **Rapport de stage complet** : voir `Rapport_de_Stage_Datacenter_PME.docx`
- **Documentation technique / guide d'exploitation** : voir `Documentation_Technique.docx`

## Difficultés notables rencontrées

Voir le Chapitre 5 du rapport de stage pour le détail complet. En résumé :
- Le paquet `freeipa-server` n'existe pas sous Ubuntu → machine dédiée sous Rocky Linux 9
- Modules Puppet rendus multi-OS via `$facts['os']['family']`
- Incident de suppression accidentelle de VMs, résolu par reconstruction via Terraform + restauration Git

## Licence / Cadre

Projet académique réalisé dans le cadre d'un stage ESPRIT. Non destiné à un usage en production.
