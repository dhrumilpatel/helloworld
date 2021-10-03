# Goal

The Goal of this Project is to launch an `Hello-World` Javabased Containeraized MicroServices in AWS EKS.

This project is `production-ready`. Which means, following below steps in order given, you should be able to successfully launch this micro-services.

# Architecture

## A description about Manual and Semi-Auto

   ![](/images/HelloWorld_Architecture.png)

# Pre-requistes

1. AWS Account
2. EC2 - Provision 2 ECS Instances. 
   
   Named as, 
   1. Master 
   2. Slave (to be use, exclusively for running jenkins job pipelines in slave/worker node)

   | Install         |
   | --------------  |
   |       AWS CLI   |
   |       EKSCTL    |
   |       KUBECTL   |
   |       GIT       |
   |       DOCKER    |
   |       MAVEN     |
   |      JENKINS    |

3. EKS
   Provisioned and AWS EKS Cluster
4. IAM User
5. SCM - Github or any alternative
6. Image Repo - Docker or any alternative
7. Jenkins - Defining and Trigerring Pipelines

## Installation

### AWS EC2 Instance

From your AWS Console navigate to Services - EC2. Launch Instance with AMI : Amazon Linux 2, instance type t2.micro, further along name the instance ( Master & Slave respectively ) update the Security Groups types as necessary, create and securly store the key pair and finally launch the instance. EC2 Instance shall be up and running in few mins. From tty try accessing the instance with store secure keys.


### Install AWS CLI, EKSCTL

AWS CLI - Command line tools for working with AWS services

Installation reference : [AWS CLI Version-2 ](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)

EKSCTL - The official CLI for Amazon EKS

Installation reference : [Weaveworks EKSCTL](https://github.com/weaveworks/eksctl)

### Configure IAM with Group, Policy and Users

Configuring IAM
From your AWS Console navigate to Services - IAM
1. Create Groups (Name: goal-dr-group)
2. Attach Policy
     1. AmazonEC2FullAccess
     2. IAMFullAccess
     3. AWSCloudFormationFullAccess
     4. EKS Specific Custom Policy ( Replace your ID for XXXXX )
        ``` json
            {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": "eks:*",
                    "Resource": "*"
                },
                {
                    "Action": [
                        "ssm:GetParameter",
                        "ssm:GetParameters"
                    ],
                    "Resource": [
                        "arn:aws:ssm:*:XXXXX:parameter/aws/*",
                        "arn:aws:ssm:*::parameter/aws/*"
                    ],
                    "Effect": "Allow"
                },
                {
                    "Action": [
                    "kms:CreateGrant",
                    "kms:DescribeKey"
                    ],
                    "Resource": "*",
                    "Effect": "Allow"
                }
            ]
        }
         ```
    3. Create User, and securely store the user's access & secret key, finally attach user to the Group
    4. AWS Configure User Profile
       1. Reference : https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
   
### Install Kubectl on EC2 Instances
Install Kubectl - Kubernetes uses a command line utility called `kubectl` for communicating with the cluster `API server`

Installation reference : [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)

## Source Code

Git Clone `HelloWorld` source code on EC2 - Master Instance

```bash
git clone https://github.com/dhrumilpatel/helloworld.git
```
Folder Structure

```text
helloworld                      # root directory
| - test                        # application build test
| - src                         # application build src
| - pom.xml                     # appliccation pom file
| - target                      # application target file generates hello-world-spring-boot-0.0.1-SNAPSHOT.jar file
| - README.md # Read Me file
| - k8s-hello-world.yaml        # k8s deployment file
| - Dockerfile                  # Docker build image contents
| - hello-world-imaging.txt     # Pipeline script
| - hello-world-k8s-deployment  # Pipeline script
| - Jenkinsfile                 # Not Used by any Job, it's an alternative file for image build & push
| - images                      # contains all images
| - find_errors.sh              # Log Monitor and Error filter script
| - useractivity_logfile.log    # sample log file
| - useractivity_logfile.log_status_2021-09-30.log      # filter's and mark's --- on ERROR and -3 lines
| - aws-terraform-eks-cluster
    | - main.tf                 # eks cluster configs
    | - variables.tf            # linked pre-defined variables
    | - output.tf               # terraform output's upon eks creation
    | - terraform.tfstate       # state file eks cluster
```

## Create Kubernetes EKS Cluster

### EKS Creation Manually via CLI

EKS Cluster can be created via EKS Console. In our case, we will create via cli.

EKS Cluster Config:
1. Nodes: 3 Nodes cluster ( Master:1 (AWS auto managed) Worker: 2)
2. Region: eu-north-1
3. Instance Type: m5.large 
   ```bash
   # Execute this command to find desired and available Instance types
   aws ec2 describe-instance-type-offerings --location-type "availability-zone" --filters Name=location,Values=eu-north-1b --region eu-north-1

   ```
4. Zone: AWS auto managed
   ``` bash
   # Execute this command to find the availability zones for the region
    [ec2-user@ip-172-31-3-80 ~]$ aws ec2 describe-availability-zones --region eu-north-1
    {
    "AvailabilityZones": [
        {
            "OptInStatus": "opt-in-not-required",
            "Messages": [],
            "ZoneId": "eun1-az1",
            "GroupName": "eu-north-1",
            "State": "available",
            "NetworkBorderGroup": "eu-north-1",
            "ZoneType": "availability-zone",
            "ZoneName": "eu-north-1a",
            "RegionName": "eu-north-1"
        },
        {
            "OptInStatus": "opt-in-not-required",
            "Messages": [],
            "ZoneId": "eun1-az2",
            "GroupName": "eu-north-1",
            "State": "available",
            "NetworkBorderGroup": "eu-north-1",
            "ZoneType": "availability-zone",
            "ZoneName": "eu-north-1b",
            "RegionName": "eu-north-1"
        },
        {
            "OptInStatus": "opt-in-not-required",
            "Messages": [],
            "ZoneId": "eun1-az3",
            "GroupName": "eu-north-1",
            "State": "available",
            "NetworkBorderGroup": "eu-north-1",
            "ZoneType": "availability-zone",
            "ZoneName": "eu-north-1c",
            "RegionName": "eu-north-1"
        }
    ]
    }
    ````

5. Create EKS Cluster

``` bash
[ec2-user@ip-172-31-4-42 ~]$ eksctl create cluster --name goaldrproject --nodes-min=2
2021-09-27 19:28:11 [ℹ]  eksctl version 0.67.0
2021-09-27 19:28:11 [ℹ]  using region eu-north-1
2021-09-27 19:28:11 [ℹ]  setting availability zones to [eu-north-1c eu-north-1a eu-north-1b]
2021-09-27 19:28:11 [ℹ]  subnets for eu-north-1c - public:192.168.0.0/19 private:192.168.96.0/19
2021-09-27 19:28:11 [ℹ]  subnets for eu-north-1a - public:192.168.32.0/19 private:192.168.128.0/19
2021-09-27 19:28:11 [ℹ]  subnets for eu-north-1b - public:192.168.64.0/19 private:192.168.160.0/19
2021-09-27 19:28:11 [ℹ]  nodegroup "ng-e38e14c7" will use "" [AmazonLinux2/1.20]
2021-09-27 19:28:11 [ℹ]  using Kubernetes version 1.20
2021-09-27 19:28:11 [ℹ]  creating EKS cluster "goaldrproject" in "eu-north-1" region with managed nodes
2021-09-27 19:28:11 [ℹ]  will create 2 separate CloudFormation stacks for cluster itself and the initial managed nodegroup
2021-09-27 19:28:11 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=eu-north-1 --cluster=goaldrproject'
2021-09-27 19:28:11 [ℹ]  CloudWatch logging will not be enabled for cluster "goaldrproject" in "eu-north-1"
2021-09-27 19:28:11 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=eu-north-1 --cluster=goaldrproject'
2021-09-27 19:28:11 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "goaldrproject" in "eu-north-1"
2021-09-27 19:28:11 [ℹ]  2 sequential tasks: { create cluster control plane "goaldrproject", 3 sequential sub-tasks: { wait for control plane to become ready, 1 task: { create addons }, create managed nodegroup "ng-e38e14c7" } }
2021-09-27 19:28:11 [ℹ]  building cluster stack "eksctl-goaldrproject-cluster"
2021-09-27 19:28:11 [ℹ]  deploying stack "eksctl-goaldrproject-cluster"
2021-09-27 19:28:41 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:29:11 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:30:11 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:31:11 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:32:11 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:33:12 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:34:12 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:35:12 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:36:12 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:37:12 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:38:12 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:39:12 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:40:12 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-cluster"
2021-09-27 19:44:24 [ℹ]  building managed nodegroup stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:44:24 [ℹ]  deploying stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:44:24 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:44:41 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:44:58 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:45:17 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:45:34 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:45:54 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:46:13 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:46:32 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:46:49 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:47:07 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:47:24 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:47:40 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:47:58 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:48:14 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:48:30 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:48:47 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:49:03 [ℹ]  waiting for CloudFormation stack "eksctl-goaldrproject-nodegroup-ng-e38e14c7"
2021-09-27 19:49:03 [ℹ]  waiting for the control plane availability...
2021-09-27 19:49:03 [✔]  saved kubeconfig as "/home/ec2-user/.kube/config"
2021-09-27 19:49:03 [ℹ]  no tasks
2021-09-27 19:49:03 [✔]  all EKS cluster resources for "goaldrproject" have been created
2021-09-27 19:49:03 [ℹ]  nodegroup "ng-e38e14c7" has 2 node(s)
2021-09-27 19:49:03 [ℹ]  node "ip-192-168-40-7.eu-north-1.compute.internal" is ready
2021-09-27 19:49:03 [ℹ]  node "ip-192-168-69-72.eu-north-1.compute.internal" is ready
2021-09-27 19:49:03 [ℹ]  waiting for at least 2 node(s) to become ready in "ng-e38e14c7"
2021-09-27 19:49:03 [ℹ]  nodegroup "ng-e38e14c7" has 2 node(s)
2021-09-27 19:49:03 [ℹ]  node "ip-192-168-40-7.eu-north-1.compute.internal" is ready
2021-09-27 19:49:03 [ℹ]  node "ip-192-168-69-72.eu-north-1.compute.internal" is ready
```

Cluster creation will take rought 20-25 mins, once its been created and ready as shown above, Verify the EKS Cluster via AWS Console or `kubectl get all`

## EKS Creation Automatically via Terraform

Install Terraform and verify the version

```bash

curl -o /tmp/terraform.zip -LO https://releases.hashicorp.com/terraform/1.0.8/terraform_1.0.8_linux_amd64.zip

unzip /tmp/terraform.zip

sudo chmod +x terraform && sudo mv terraform /usr/local/bin/

[ec2-user@ip-172-31-3-80 ~]$ terraform version
Terraform v1.0.8

```

In order to created EKS high-available cluster consider below `main.tf`

Scope for  `main.tf` includes
- Nodes: 3 Node cluster ( Master:1 (AWS auto managed) Worker: 2)
- Region: eu-north-1
- Instance Type: m5.large
- Zone: AWS auto managed
- Accessibility : Strickly Private ( No Public IPv4 DNS available )
- Mapping Existing IAM - User and Account directly - Inheritance of Policy ( created above in manual EC2 instance provisioning )
- Create sample Pod & LoadBalancer in default namespace.


```bash
terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.7.0"

  name                 = "test-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets
  cluster_create_timeout = "1h"
  cluster_endpoint_private_access = true
  version =      "17.20.0"

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "m5.large"
      additional_userdata           = "echo helloworld"
      asg_desired_capacity          = 2
      asg_min_size                  = 2
      asg_maz_size                  = 2
      root_volume_type              = "gp2"
      root_volume_size              = 100
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts
}



provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

resource "kubernetes_deployment" "example" {
  metadata {
    name = "terraform-example"
    labels = {
      test = "MyExampleApp"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        test = "MyExampleApp"
      }
    }

    template {
      metadata {
        labels = {
          test = "MyExampleApp"
        }
      }

      spec {
        container {
          image = "nginx:1.7.8"
          name  = "example"

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "example" {
  metadata {
    name = "terraform-example"
  }
  spec {
    selector = {
      test = "MyExampleApp"
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
```
Update `variables.tf`
```bash
variable "region" {
  default     = "eu-north-1"
  description = "AWS Stocholm region"
}

variable "cluster_name" {
  default = "eks-hello-world"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    "XXXXXXXX"
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::XXXXXX:user/YYYYYY"
      username = "YYYYYY"
      groups   = ["system:masters"]
    }
  ]
}

```

Once satified with the `.tf` files proceed ahead with provisioning.

```bash
terraform init
terraform plan
terraform apply # Only 'yes' will be accepted to approve. Enter a value: yes
```

Cluster creation will take rought 20-25 mins, once its been created and ready as shown above, Verify the EKS Cluster via AWS Console or `kubectl` 

Perform update and verify the EKS cluster

```bash
aws eks update-kubeconfig --name eks-hello-world --region eu-north-1

Updated context arn:aws:eks:eu-north-1:852883190279:cluster/eks-hello-world in /home/ec2-user/.kube/config

## Fetch the sample Pod & Loadbalancer required to create via EKS cluster creation

[ec2-user@ip-172-31-3-80 aws-terraform-eks-cluster]$  kubectl get pod,svc
NAME                                    READY   STATUS    RESTARTS   AGE
pod/terraform-example-8484bc9b8-lhccv   1/1     Running   0          13m
pod/terraform-example-8484bc9b8-vb76z   1/1     Running   0          13m

NAME                        TYPE           CLUSTER-IP     EXTERNAL-IP                                                                PORT(S)        AGE
service/kubernetes          ClusterIP      172.20.0.1     <none>                                                                     443/TCP        18m
service/terraform-example   LoadBalancer   172.20.58.29   abec2d5d7480a42e59cefaac5a699733-1749363570.eu-north-1.elb.amazonaws.com   80:30389/TCP   13m
[ec2-user@ip-172-31-3-80 aws-terraform-eks-cluster]$

```

One last step, before we deploy and run our containerized hello world microservices. Label the node as `node=worker` to achieve node affinity.

```bash
[ec2-user@ip-172-31-3-80 helloworld]$ kubectl get node
NAME                                        STATUS   ROLES    AGE   VERSION
ip-10-0-1-142.eu-north-1.compute.internal   Ready    <none>   28m   v1.20.7-eks-135321
ip-10-0-2-246.eu-north-1.compute.internal   Ready    <none>   28m   v1.20.7-eks-135321


[ec2-user@ip-172-31-3-80 helloworld]$ kubectl label node ip-10-0-1-142.eu-north-1.compute.internal node=worker
node/ip-10-0-1-142.eu-north-1.compute.internal labeled

[ec2-user@ip-172-31-3-80 helloworld]$ kubectl label node ip-10-0-2-246.eu-north-1.compute.internal node=worker
node/ip-10-0-2-246.eu-north-1.compute.internal labeled
[ec2-user@ip-172-31-3-80 helloworld]$

[ec2-user@ip-172-31-3-80 helloworld]$ kubectl get node -l node=worker
NAME                                        STATUS   ROLES    AGE   VERSION
ip-10-0-1-142.eu-north-1.compute.internal   Ready    <none>   31m   v1.20.7-eks-135321
ip-10-0-2-246.eu-north-1.compute.internal   Ready    <none>   31m   v1.20.7-eks-135321
```

Final step is to `Deploying HelloWorld Microservices`


- Trigger manually via `kubectl` ( this is optional, only if you wish to test it manually without creating pipelines. )
  
    ```bash
    [ec2-user@ip-172-31-3-80 helloworld]$ kubectl create -f k8s-hello-world.yaml
    namespace/helloworld created
    deployment.apps/hello-world-deploy created
    service/hello-world-service created
    horizontalpodautoscaler.autoscaling/hello-world-deploy created
    poddisruptionbudget.policy/hello-world-pdb created
    ```

    ```bash
    [ec2-user@ip-172-31-3-80 helloworld]$ kubectl get all -n helloworld
    NAME                                      READY   STATUS    RESTARTS   AGE
    pod/hello-world-deploy-5dfbb59dc7-8zl9b   0/1     Running   0          14s
    pod/hello-world-deploy-5dfbb59dc7-f9tc7   0/1     Running   0          14s

    NAME                          TYPE           CLUSTER-IP      EXTERNAL-IP                                                                PORT(S)          AGE
    service/hello-world-service   LoadBalancer   172.20.32.220   ae84a9c5122fd4f83a323dc404c691cb-1011098200.eu-north-1.elb.amazonaws.com   8080:30698/TCP   14s

    NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/hello-world-deploy   0/2     2            0           14s

    NAME                                            DESIRED   CURRENT   READY   AGE
    replicaset.apps/hello-world-deploy-5dfbb59dc7   2         2         0       14s

    NAME                                                     REFERENCE                       TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
    horizontalpodautoscaler.autoscaling/hello-world-deploy   Deployment/hello-world-deploy   <unknown>/50%   2         5         0          14s
    [ec2-user@ip-172-31-3-80 helloworld]$

    ```
    Verify HelloWorld microservices is up and running

    ```bash
    [ec2-user@ip-172-31-3-80 helloworld]$ curl http://ae84a9c5122fd4f83a323dc404c691cb-1011098200.eu-north-1.elb.amazonaws.com:8080
    Hello World!! Greetings from Spring Boot!

    [ec2-user@ip-172-31-3-80 helloworld]$ curl http://ae84a9c5122fd4f83a323dc404c691cb-1011098200.eu-north-1.elb.amazonaws.com:8080/actuator/health
    {"status":"UP","groups":["liveness","readiness"]}

    ```


### Installation of Jenkins in EC2 Instances

```bash
sudo yum update -y
sudo yum install -y jenkins
```
```bash
sudo useradd -m jenkins
sudo -u jenkins mkdir /home/jenkins/.ssh
sudo usermod -aG jenkins
sudo newgrp jenkins
sudo systemctl daemon-reload
sudo service jenkins restart
```
### Installation of Docker in EC2 Instances

```bash
sudo yum install -y docker
```
```bash
sudo usermod -aG docker
sudo newgrp docker
sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl restart docker
```

### Installation of Maven in EC2 Instances
```bash
sudo yum install -y maven
```


### Installation of GIT in EC2 Instances
```bash
sudo yum install git -y
```

### Configuring Jenkins

1. Agents
   - Defining Agents, name & label as `worker` node - to run through pipeline execution
     Reference : https://www.jenkins.io/doc/book/using/using-agents/
2. Credentials
   - Defining Credentials for Git, Docker, EKS Cluster config
     Reference : https://www.jenkins.io/doc/book/using/using-credentials/
3. Plug-in
   - From Plugin Manager install Maven, Docker, Kuberbetes
4. Global Tool Configuration
   - Update Home Paths for,
     - JAVE_HOME
       ```bash
       /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.302.b08-0.amzn2.0.1.x86_64
       ```
     - GIT
       ```bash
       /usr/bin/git
       ```
     - MAVEN
       ```bash
       /usr/share/apache-maven
       ```


## Deployment of Hello-World Microservices App in AWS EKS Cluster using Jenkins Pipeline

!(images/springboot-app-deployment.png)

Aim is to faciliate automated way of Continuous Deployment and Integration of Hello-World  java application packaging, creating Docker image and deploying containerized microservies into AWS EKS - Kubernetes Cluster using Jenkins pipelines.

Hello-World is an Springboot Microservices based Java application. I have already created a repo with source code, including Dockerfile, Jenkinsfile and other supported project files. 

## Manual Test Locally

Naviagte to sourcecode path inside `src`

### Packaging
```bash
mvn clean
mvn compile
mvn package
```
```bash
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 4.053 s - in com.example.springboot.HelloControllerTest
[INFO]
[INFO] Results:
[INFO]
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO]
[INFO]
[INFO] --- maven-jar-plugin:3.2.0:jar (default-jar) @ hello-world-spring-boot ---
[INFO] Building jar: /home/ec2-user/helloworld/target/hello-world-spring-boot-0.0.1-SNAPSHOT.jar
[INFO]
[INFO] --- spring-boot-maven-plugin:2.5.0:repackage (repackage) @ hello-world-spring-boot ---
[INFO] Replacing main artifact with repackaged archive
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 10.067 s
[INFO] Finished at: 2021-09-30T14:56:23Z
[INFO] Final Memory: 27M/104M
[INFO] ------------------------------------------------------------------------
```

### Imaging
```bash
[ec2-user@ip-172-31-4-42 helloworld]$ docker build -t helloworld:latest .
Sending build context to Docker daemon  37.08MB
Step 1/3 : FROM openjdk:8-jre-alpine
 ---> f7a292bbb70c
Step 2/3 : COPY ./target/hello-world-spring-boot-0.0.1-SNAPSHOT.jar /my-app-hello-world.jar
 ---> 479be7c65aa3
Step 3/3 : CMD java -jar /my-app-hello-world.jar
 ---> Running in c988dc4d81ca
Removing intermediate container c988dc4d81ca
 ---> c9251da573a6
Successfully built c9251da573a6
Successfully tagged helloworld:v1

[ec2-user@ip-172-31-4-42 helloworld]$ docker image ls
REPOSITORY                        TAG            IMAGE ID       CREATED         SIZE
helloworld                        v1             c9251da573a6   7 seconds ago   104MB

```

### Deployment
```bash
[ec2-user@ip-172-31-3-80 helloworld]$ kubectl create -f k8s-hello-world.yaml
    namespace/helloworld created
    deployment.apps/hello-world-deploy created
    service/hello-world-service created
    horizontalpodautoscaler.autoscaling/hello-world-deploy created
    poddisruptionbudget.policy/hello-world-pdb created

    [ec2-user@ip-172-31-3-80 helloworld]$ kubectl get all -n helloworld
    NAME                                      READY   STATUS    RESTARTS   AGE
    pod/hello-world-deploy-5dfbb59dc7-8zl9b   0/1     Running   0          14s
    pod/hello-world-deploy-5dfbb59dc7-f9tc7   0/1     Running   0          14s

    NAME                          TYPE           CLUSTER-IP      EXTERNAL-IP                                                                PORT(S)          AGE
    service/hello-world-service   LoadBalancer   172.20.32.220   ae84a9c5122fd4f83a323dc404c691cb-1011098200.eu-north-1.elb.amazonaws.com   8080:30698/TCP   14s

    NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/hello-world-deploy   0/2     2            0           14s

    NAME                                            DESIRED   CURRENT   READY   AGE
    replicaset.apps/hello-world-deploy-5dfbb59dc7   2         2         0       14s

    NAME                                                     REFERENCE                       TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
    horizontalpodautoscaler.autoscaling/hello-world-deploy   Deployment/hello-world-deploy   <unknown>/50%   2         5         0          14s
    
```

## Automation Test via CI/CD Pipelines

Automation of CI/CD Pipelines is achieved using Jenkins. A well define sequential / independent jobs is been facilitated. 

# Adde Node Agent Info

Create Jobs:
- **hello-world-packaging**: This Job will git pull last commit and perform packaging using maven of hello-world microservices.
- **hello-world-imaging**: This job will git pull last commit package and perform docker image creation.
  - Pipeline Script
    ```java
    node ("worker") {
    stage ('checkout') {
        checkout([$class: 'GitSCM', 
                    branches: [[name: '*/master']], 
                    doGenerateSubmoduleConfigurations: false, 
                    extensions: [], 
                    submoduleCfg: [], 
                    userRemoteConfigs: [[credentialsId: '', 
                    url: 'https://github.com/dhrumilpatel/helloworld.git']]])      
                        }
    stage ('Docker Build') {
         // Build and push image with Jenkins' docker-plugin
            withDockerRegistry([credentialsId: "dockerhub", url: "https://index.docker.io/v1/"])
            {
            image = docker.build("blueberrie/goal-hello-world:latest")
            image.push()    
            }
        }
        }
    ```

    ![](/images/Job-docker-image.png)

- **hello-world-k8s-deployment**: This job will git pull commit docker image and deploy to AWS EKS Cluster
  - Pipeline Script
  ```java
     node ("worker") {
    stage ('checkout') {
        checkout([$class: 'GitSCM', 
                    branches: [[name: '*/master']], 
                    doGenerateSubmoduleConfigurations: false, 
                    extensions: [], 
                    submoduleCfg: [], 
                    userRemoteConfigs: [[credentialsId: '', 
                    url: 'https://github.com/dhrumilpatel/helloworld.git']]])      
        }
    stage ('K8S Deploy') {
       
                kubernetesDeploy(
                    configs: 'k8s-hello-world.yaml',
                    kubeconfigId: 'K8S',
                    enableConfigSubstitution: true
                    )               
        }
    }
  ````
  ![](/images/Job-k8s-deploy.png)


## Hello-World MicroService Final Goal

![](/images/Hello-World-Service-EKS-Cluster.png)

