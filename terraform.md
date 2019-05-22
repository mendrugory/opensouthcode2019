# Gestiona tu infrastructura como código con Terraform


---
```
$ whoami

* Gonzalo Gabriel Jiménez Fuentes
* SW Consultant and Trainer
* Resilience systems, Near-Real Time Systems, Devops, Cloud, ...
* @mendrugory

```
---

## Devops

---

> Devops is a way of thinking and a way of working.

<div style="display:block;margin-left:30%;margin-right:0;width:80%;"><i>Effective DevOps.</i></div><div style="display:block;margin-left:33%;margin-right:0;width:80%;"><i>2016 O'Reilly.</i></div>

---

> Devops is about finding ways to adapt and innovate social structure, culture, and technology together in order to work more effectively.

<div style="display:block;margin-left:30%;margin-right:0;width:80%;"><i>Effective DevOps.</i></div><div style="display:block;margin-left:33%;margin-right:0;width:80%;"><i>2016 O'Reilly.</i></div>

---

Devops = Development + Operations

---

*Devops* = *Development* + **Operations**

---

## Operations

<div style="display:block;margin-left:auto;margin-right:auto;width:50%;"><img src ="/images/operations.gif"  /></div>

---

### ¿Cómo lo podemos mejorar?

---


## ¡¡ Automatizando !!

<div style="display:block;margin-left:auto;margin-right:auto;width:100%;"><img src ="/images/automation.gif"  /></div>


---


*Devops* = **Development** + *Operations*


---

# Infrastructure as Code

---


<div style="display:block;margin-left:auto;margin-right:auto;width:80%;"><img src ="/images/terraform.jpg"  /></div>


---



<div style="display:block;margin-left:auto;margin-right:auto;width:50%;"><img src ="/images/terraform-cloud-providers.png"  /></div>


---



<div style="display:block;margin-left:auto;margin-right:auto;width:80%;"><img src ="/images/terraform-full-aws.png"  /></div>



---

## Terraform HCL


```
provider "aws" {
    region = "eu-west-1"
}

resource "aws_instance" "example" {
    ami             = "ami-973653739308"
    instance_type   = "t2.micro"
}
```


---

# Aprovisionamiento de una máquina virtual


---


<div style="display:block;margin-left:auto;margin-right:auto;width:100%;"><img src ="/images/demo-time.gif"  /></div>

*¡¡ Show Time !!*


---

## ¿Y ahora tengo que usar otra herramienta para desplegar mi aplicación?

---

### Desplegar tras el aprovisionamiento

script.sh

```
#!/bin/bash
 
sudo yum install docker -y
sudo usermod -aG docker ec2-user
sudo service docker start
sudo docker run --rm -d -p 80:80 --name app nginx
```

---

### Desplegar tras el aprovisionamiento

main.tf

```
provider "aws" {
  region = "eu-west-3"
}
data "template_file" "start_script" {
  template = "${file("./script.sh")}"
}
...
resource "aws_instance" "server" {
  ami                    = "ami-0dd7e7ed60da8fb83"
  instance_type          = "t2.micro"
  user_data              = "${data.template_file.start_script.rendered}"
  vpc_security_group_ids = ["${aws_security_group.server_sg.id}"]
}
...

```



---


<div style="display:block;margin-left:auto;margin-right:auto;width:100%;"><img src ="/images/another-demo.gif"  /></div>

*Otra "Demo"*


---

## ¿Sólo tengo un fichero y los valores como constantes?

---

## Ficheros de Terraform

```
.
├── main.tf
├── outputs.tf
└── variables.tf
```


---

## Ficheros de Terraform

*variables.tf*
```
variable "ami" {}
variable "instance" {
  default = "t2.micro"
}
```

---

## Ficheros de Terraform

*main.tf*
```
provider "aws" {
  region = "eu-west-3"
}

...

resource "aws_instance" "server" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance}"
  user_data              = "${data.template_file.start_script.rendered}"
  vpc_security_group_ids = ["${aws_security_group.server_sg.id}"]
}
```

---

## Ficheros de Terraform

*outputs.tf*
```
output "public_ip"{
  value = "${aws_instance.server.public_ip}"
}
```

---

## Variables en Terraform

```
$ terraform apply
var.ami
  Enter a value:
```


---

## Variables en Terraform

```
$ terraform apply -var 'ami=ami-0dd7e7ed60da8fb83'
```


---

## Variables en Terraform

```
$ export TF_VAR_ami=ami-0dd7e7ed60da8fb83
$ terraform apply
```


---


## Variables en Terraform

```
$ export AWS_ACCESS_KEY_ID="*************"
$ export AWS_SECRET_ACCESS_KEY="***************"
$ export AWS_DEFAULT_REGION="eu-west-3"
```

*main.tf*
```
provider "aws" {}
...
```

---


# Módulos de Terraform

---

## Aplicación Web Completa

<div style="display:block;margin-left:auto;margin-right:auto;width:100%;"><img src ="/images/webarechitecture.png"  /></div>


---

## Módulos de Terraform

```
.
├── modules
│   ├── app_server
│   │   ├── appserver.sh
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── datastore
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── load_balancer
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── prod
│   ├── env.sh
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   └── variables.tf
└── staging
    ├── env.sh
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    └── variables.tf
```

---

## Módulos de Terraform

*prod/main.tf*
```
module "appserver" {
  source = "../modules/app_server"

  ami                 = "${var.ami}"
  number_of_appserver = "${var.number_of_appserver}"
  database_password   = "${var.database_password}"
  database_username   = "${var.database_username}"
  database_name       = "${var.database_name}"
  database_address    = "${module.database.address}"
  ec2_instance_class  = "${var.ec2_instance_class}"
}

module "database" {
  source = "../modules/datastore"

  database_name     = "${var.database_name}"
  database_username = "${var.database_username}"
  database_password = "${var.database_password}"
  db_instance_class = "${var.db_instance_class}"
  allocated_storage = "${var.allocated_storage}"
}

data "aws_availability_zones" "all" {}

module "load_balancer" {
  source = "../modules/load_balancer"

  lb_availability_zones = ["${data.aws_availability_zones.all.names}"]
  appservers            = ["${module.appserver.instances}"]
}

```

---

## Variables para Terraform

```
# AWS
export TF_VAR_db_instance_class="db.t2.micro"
export TF_VAR_ec2_instance_class="t2.micro"

# DATABASE
export TF_VAR_database_name="notejam"
export TF_VAR_database_username="username"
export TF_VAR_database_password="password"
export TF_VAR_allocated_storage="5"
```

---

## Lanzamos la aplicación

```
$ terraform init
$ terraform apply --auto-approve

...

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

lb_dns_name = appserver-lb-*******.eu-west-2.elb.amazonaws.com
```


---

## ¡¡ Visitemos nuestro NoteJam !!

---

### ¿Y algo un poco más complicado?


<div style="display:block;margin-left:auto;margin-right:auto;width:100%;"><img src ="/images/dangerous.gif"  /></div>

---

# Kubernetes

---

## EKS

---

## K8S Application


<div style="display:block;margin-left:auto;margin-right:auto;width:70%;"><img src ="/images/k8sarchitecture.png"  /></div>

---

# K8S Modules

```
modules
├── eks-master
│   ├── main.tf
│   ├── output.tf
│   └── variables.tf
├── eks-node
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── iam-node
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
└── network
    ├── main.tf
    ├── outputs.tf
    └── variables.tf
```

---

# K8S Production

```
prod/
├── env.sh
├── k8s
│   ├── database.yaml
│   ├── ingress.yaml
│   ├── rbac.yaml
│   └── web.yaml
├── main.tf
├── outputs.tf
├── scripts
│   ├── down.sh
│   └── up.sh
└── variables.tf
```

---

## ¡¡ Visitemos nuestro NoteJam en Kubernetes !!

---

# Conclusión

---

## Gracias



* @mendrugory
* www.mendrugory.com


https://github.com/mendrugory/opensouthcode2019 



