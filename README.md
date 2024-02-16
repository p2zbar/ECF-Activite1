 **Deployer une infrastructure depuis Terraform , un cluster EMR Spark et un Cluster DocumentDB.**

Liens utiles:  
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code  
https://aws.amazon.com/emr/features/spark/  
https://aws.amazon.com/nosql/document/

Prerequis:
- Creer un compte AWS (ne pas utiliser le compte racine)  
https://docs.aws.amazon.com/IAM/latest/UserGuide/root-user-best-practices.html

- Creer un utilisateur IAM avec les droits admins, enregistrer les creds qui seront utilises dans l'etape suivante  
https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html

- Installer et configurer AWS cli avec votre Access Key et Secret sur la region de votre choix (dans mon cas eu-central-1)  
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

- Installer Terraform cli  
  https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

Un IDE de votre choix dans ma situation VSCode avec les extensions Terraform.

Cloner le repo
```
git clone git@github.com:p2zbar/ECF-Activite1.git
```
 
Le code est divise en 3 fichiers:  
  
**main.tf** contient tout le code de la creation d'un VPC , une IGW , une Route table , 2 Security-groups, 2 subnets , 1 cluster EMR (1 core , 1 master) et 1 cluster Document DB (3 instances en db.t3.medium).  
**variables.tf** permet de ne pas ecrire tout le code en dur et de facilite la reutilisation du projet pour une autre infra.  
**terraform.tvars** contient les valeurs qui seront utilisees dans le variables.tf si pas de variable default de configurer.

Pour lancer le projet:
- Ouvrir un terminal dans votre IDE  

initier le projet  
```
terraform init 
```
creer un plan d'execution, permet de visualiser les differentes actions que Terraform prevoit d'apporter
```
terraform plan
```
applique le terraform plan
```
terraform apply
```

Confirmer le deploiement en tapant Yes  
Une fois que l'apply est termine un message "Apply compete! Resources: x Added,0 changed, 0 destroyed"  

Si vous vous rendez sur AWS Console > EMR 
Le cluster EMR aura ete cree

Si vous vous rendez sur AWS Console > DocumentDB
Le cluster DocumentDB aura ete cree

Pour supprimer tout ce qui a ete cree
```
terraform destroy
```
Confirmer en tapant yes

Un message vous sera afficher "Destroy Completed"





