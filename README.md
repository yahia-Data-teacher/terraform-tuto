# terraform-tuto

## Principales commandes Terraform

- `terraform init` : Initialise le projet (providers, backend).
- `terraform validate` : Vérifie la syntaxe des fichiers.
- `terraform plan` : Montre les changements à appliquer (sécurisé).
- `terraform apply` : Applique les changements (création réelle).
- `terraform destroy` : Détruire les resources présentes dans le file state.
- `terraform import` : Permet d'intégrer une ressource existante dans Terraform sans la recréer.
- `terraform fmt` : Formate les fichiers de configuration Terraform.
- `terraform workspace new` : Créé un nouveau workspace.
- `terraform workspace list` : Liste les workspaces.
- `terraform workspace select` : Sélectionne un workspace.

## Guide détaillé d'utilisation

### 1. Initialisation du projet (`terraform init`)
- Cette commande est la première à exécuter dans un nouveau projet Terraform
- Elle initialise le répertoire de travail contenant les fichiers de configuration
- Télécharge les plugins des providers nécessaires (AWS, Azure, etc.)
- Configure le backend pour stocker l'état Terraform
- Options utiles :
  - `-backend=false` : Désactive la configuration du backend
  - `-upgrade` : Force le téléchargement des dernières versions des providers

### 2. Validation de la configuration (`terraform validate`)
- Vérifie la syntaxe et la cohérence interne des fichiers Terraform
- Détecte les erreurs de configuration avant l'exécution
- Ne nécessite pas d'accès aux providers (peut être exécuté hors ligne)

### 3. Planification des changements (`terraform plan`)
- Crée un plan d'exécution détaillant les modifications à apporter
- Compare l'état actuel avec l'état désiré
- Affiche :
  - Ressources à créer (+)
  - Ressources à modifier (~)
  - Ressources à détruire (-)
- Options utiles :
  - `-out=plan.tfplan` : Sauvegarde le plan dans un fichier
  - `-target=resource` : Limite la planification à une ressource spécifique
  - `-var-file=custom.tfvars` : Utilise un fichier de variables personnalisé

### 4. Application des changements (`terraform apply`)
- Exécute les changements planifiés sur l'infrastructure
- Demande une confirmation interactive par défaut
- Met à jour le fichier d'état (terraform.tfstate)
- Options utiles :
  - `-auto-approve` : Skip la confirmation interactive
  - `terraform apply plan.tfplan` : Applique un plan sauvegardé
  - `-target=resource` : Applique les changements uniquement sur une ressource spécifique

### 5. Destruction de l'infrastructure (`terraform destroy`)
- Supprime toutes les ressources gérées par Terraform
- Très dangereux en production, à utiliser avec précaution
- Demande une confirmation interactive
- Options utiles :
  - `-auto-approve` : Skip la confirmation interactive
  - `-target=resource` : Détruit uniquement une ressource spécifique

### 6. Gestion des workspaces
Les workspaces permettent de gérer plusieurs états pour une même configuration (dev, staging, prod)
```bash
# Créer un nouveau workspace
terraform workspace new dev

# Lister les workspaces disponibles
terraform workspace list

# Changer de workspace
terraform workspace select prod
```

### 7. Formatage du code (`terraform fmt`)
- Formate automatiquement les fichiers de configuration Terraform
- Assure une cohérence dans le style de code
- Options utiles :
  - `--recursive` : Formate récursivement tous les fichiers `.tf` dans les sous-répertoires
  - `--check` : Vérifie si les fichiers sont bien formatés sans les modifier
  - `--diff` : Montre les différences qui seraient appliquées
- Exemple d'utilisation :
```bash
# Formate tous les fichiers .tf dans le répertoire courant et ses sous-répertoires
terraform fmt --recursive

# Vérifie le formatage sans modifier les fichiers
terraform fmt --recursive --check

# Montre les différences qui seraient appliquées
terraform fmt --recursive --diff
```

## Gestion avancée des Workspaces

### Introduction aux Workspaces
Les workspaces permettent de gérer plusieurs états d'infrastructure avec le même code Terraform. Ils sont particulièrement utiles pour :
- Gérer différents environnements (dev, staging, prod)
- Tester des changements sans affecter l'infrastructure principale
- Créer des environnements éphémères pour des tests

### Commandes principales

1. **Créer un nouveau workspace**
```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

2. **Lister les workspaces**
```bash
terraform workspace list
# Résultat :
#   default
# * dev
#   staging
#   prod
# (l'astérisque * indique le workspace actif)
```

3. **Changer de workspace**
```bash
terraform workspace select prod
terraform workspace select dev
```

4. **Afficher le workspace actuel**
```bash
terraform workspace show
```

5. **Supprimer un workspace**
```bash
terraform workspace delete dev  # Le workspace doit être vide
```

### Utilisation dans le code Terraform
Vous pouvez utiliser le nom du workspace dans votre configuration pour créer des ressources spécifiques à chaque environnement :

```hcl
resource "aws_instance" "example" {
  instance_type = var.instance_type

  tags = {
    Name        = "server-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Variables conditionnelles selon le workspace
locals {
  instance_type = {
    default = "t2.micro"
    dev     = "t2.micro"
    staging = "t2.medium"
    prod    = "t2.large"
  }
}

# Utilisation des variables conditionnelles
resource "aws_instance" "example" {
  instance_type = local.instance_type[terraform.workspace]
}
```

### Bonnes pratiques pour les Workspaces

1. **Nommage cohérent**
   - Utiliser des noms descriptifs (dev, staging, prod)
   - Éviter les noms temporaires ou personnels

2. **État des Workspaces**
   - Utiliser un backend distant pour chaque workspace
   - Configurer des permissions différentes selon les environnements

3. **Variables par Workspace**
   - Créer des fichiers `.tfvars` spécifiques (dev.tfvars, prod.tfvars)
   - Exemple : `terraform plan -var-file="env/${terraform.workspace}.tfvars"`

4. **Documentation**
   - Documenter les différences entre workspaces
   - Maintenir une liste des workspaces actifs et leur utilisation

5. **Sécurité**
   - Limiter l'accès aux workspaces de production
   - Utiliser des credentials différents pour chaque workspace

### Structure recommandée des fichiers
```
project/
├── main.tf
├── variables.tf
├── outputs.tf
├── env/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
└── modules/
    └── ...
```

### Bonnes pratiques
1. **Toujours faire un plan avant apply**
   - Vérifier les changements prévus
   - Sauvegarder le plan si nécessaire

2. **Utiliser les variables**
   - Créer des fichiers `.tfvars` pour chaque environnement
   - Ne pas commiter les secrets dans Git

3. **Backend distant**
   - Utiliser un backend distant (S3, Azure Storage, etc.)
   - Permet le travail en équipe
   - Sécurise l'état Terraform

4. **Modules**
   - Organiser le code en modules réutilisables
   - Versionner les modules
   - Documenter les inputs/outputs

## Exemples Pratiques

### Configuration d'une Lambda Python

1. **Structure des fichiers**
```
project/
├── lambda/
│   ├── lambda_function.py
│   └── function.zip
└── lambda.tf
```

2. **Code Lambda Python (lambda_function.py)**
```python
import json
import os

def handler(event, context):
    print('Event:', json.dumps(event, indent=2))
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from Python Lambda!',
            'environment': os.environ.get('ENVIRONMENT')
        })
    }
```

3. **Configuration Terraform (lambda.tf)**
```hcl
# IAM role pour Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attachment de la policy de base pour Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Fonction Lambda
resource "aws_lambda_function" "example_lambda" {
  filename         = var.lambda_zip_path
  function_name    = "example-lambda-python-${terraform.workspace}"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.handler"
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 128

  environment {
    variables = {
      ENVIRONMENT = terraform.workspace
    }
  }

  tags = {
    Name        = "ExampleLambdaPython-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

variable "lambda_zip_path" {
  description = "Path to the Lambda function's deployment package"
  type        = string
  default     = "lambda/function.zip"
}
```

4. **Déploiement de la Lambda**
```bash
# Création du package ZIP
cd lambda
zip function.zip lambda_function.py
cd ..

# Déploiement avec Terraform
terraform init
terraform plan
terraform apply -var="bucket_name=data-bucket-lab01-${terraform.workspace}"
```

### Bonnes Pratiques pour les Déploiements

1. **Gestion des variables par environnement**
- Créer un fichier vars/{environment}.tfvars pour chaque environnement
- Exemple pour staging.tfvars :
```hcl
# Configuration du bucket S3
bucket_name = "data-bucket-lab01-staging"

# Configuration de l'instance EC2
instance_type = "t2.medium"  # Plus puissant pour staging
ami_id       = "ami-09e6f87a47903347c"
```

2. **Commandes de déploiement par environnement**
```bash
# Déploiement en staging
terraform workspace select staging
terraform plan -var-file="vars/staging.tfvars"
terraform apply -var-file="vars/staging.tfvars"

# Déploiement en production
terraform workspace select prod
terraform plan -var-file="vars/prod.tfvars"
terraform apply -var-file="vars/prod.tfvars"
```

3. **Validation des changements**
```bash
# Vérification du formatage
terraform fmt --recursive

# Validation de la configuration
terraform validate

# Planification avec export du plan
terraform plan -var-file="vars/${terraform.workspace}.tfvars" -out=tfplan
terraform apply tfplan
```

## Configurations Détaillées

### 1. Configuration S3 avec vérification d'existence

```hcl
# Bucket S3 avec création conditionnelle
resource "aws_s3_bucket" "data_bucket" {
  count  = var.create_bucket ? 1 : 0
  bucket = var.bucket_name

  tags = {
    Name        = "DataBucket-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Configuration du chiffrement avec KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.data_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Variables
variable "create_bucket" {
  description = "Whether to create the S3 bucket. Set to false if bucket already exists"
  type        = bool
  default     = true
}
```

### 2. Configuration Lambda Python

```hcl
# IAM Role pour Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Fonction Lambda
resource "aws_lambda_function" "example_lambda" {
  filename         = var.lambda_zip_path
  function_name    = "example-lambda-python-${terraform.workspace}"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.handler"
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 128

  environment {
    variables = {
      ENVIRONMENT = terraform.workspace
    }
  }
}
```

### 3. Configuration KMS (Key Management Service)

```hcl
# Clé KMS
resource "aws_kms_key" "encryption_key" {
  description             = "KMS key for ${terraform.workspace} environment"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "encryption-key-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Alias KMS
resource "aws_kms_alias" "encryption_key_alias" {
  name          = "alias/${terraform.workspace}-encryption-key"
  target_key_id = aws_kms_key.encryption_key.key_id
}
```

### Structure des fichiers de variables par environnement

#### dev.tfvars
```hcl
# Configuration pour l'environnement de développement
bucket_name    = "data-bucket-lab01-dev"
create_bucket  = false  # Si le bucket existe déjà
instance_type  = "t2.micro"  # Instance moins puissante pour le dev
lambda_zip_path = "lambda/function.zip"
```

#### staging.tfvars
```hcl
# Configuration pour l'environnement de staging
bucket_name    = "data-bucket-lab01-staging"
instance_type  = "t2.medium"  # Plus de puissance pour les tests
lambda_zip_path = "lambda/function.zip"
```

### Déploiement avec gestion des environnements

1. **Préparation du package Lambda**
```bash
cd lambda
zip function.zip lambda_function.py
cd ..
```

2. **Déploiement par environnement**
```bash
# Déploiement en dev
terraform workspace select dev
terraform plan -var-file="vars/dev.tfvars"
terraform apply -var-file="vars/dev.tfvars"

# Déploiement en staging
terraform workspace select staging
terraform plan -var-file="vars/staging.tfvars"
terraform apply -var-file="vars/staging.tfvars"
```

### Points importants à noter

1. **Sécurité**
   - Utilisation de KMS pour le chiffrement des données
   - Gestion des permissions via IAM roles
   - Variables sensibles dans des fichiers tfvars non commités

2. **Flexibilité**
   - Création conditionnelle des ressources
   - Configuration spécifique par environnement
   - Utilisation des workspaces pour la séparation des environnements

3. **Maintenabilité**
   - Structure modulaire du code
   - Variables clairement définies
   - Documentation des configurations

