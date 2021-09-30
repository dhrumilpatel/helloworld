# Goal

To launch Hello-World Javabased Containeraized MicroServices in AWS Cloud.

# Architecture

# Pre-requistes

1. AWS Account
2. EC2
   | Instance Type | Master |  Slave |
   | ------------- | -------|-----  |
   |            |       AWS CLI         |
   |            |       EKSCTL          |
   |      EC2   |        KUBECTL         |
   |            |       GIT             |
   |            |       DOCKER          |
   |            |       MAVEN           |
   |            |       JENKINS           |

3. EKS
   Provisioned and AWS EKS Cluster
4. IAM User
5. SCM - Github or any alternative
6. Image Repo - Docker or any alternative
7. Jenkins - Defining and Trigerring Pipelines

## Installation

### AWS EC2 Instance

From your AMS Console navigate to Services - EC2. Launch Instance with AMI : Amazon Linux 2, instance type t2.micro, further along name the instance ( Master & Slave respectively ) update the Security Groups types as necessary, create and securly store the key pair and finally launch the instance. EC2 Instance shall be up and running in few mins. From tty try accessing the instance with store secure keys.


### Install AWS CLI, EKSCTL

AWS CLI - Command line tools for working with AWS services

Reference : Install [AWS CLI Version-2 ](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)

EKSCTL - 

Reference : Install [Weaveworks EKSCTL](https://github.com/weaveworks/eksctl)

### Configure IAM with Group and Users

Configuring IAM
From your AMS Console navigate to Services - IAM
1. Create Groups (Name: goal-dr-group)
2. Attach Policy
     1. AmazonEC2FullAccess
     2. IAMFullAccess
     3. AWSCloudFormationFullAccess
     4. EKS Specific Custom Policy
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
                        "arn:aws:ssm:*:852883190279:parameter/aws/*",
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
   
### Install Kubectl
Install Kubectl

Reference :Install [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)

### Create Kuberbetes EKS Cluster
EKS Cluster can be created via EKS Console. In our case, we will create via cli.

EKS Cluster Config:
1. Node: 3 Node cluster ( Master:1 (AWS auto managed) Worker: 2)
2. Region: eu-north-1
3. Instance Type: m5.large
4. Zone: AWS auto managed
   ``` bash
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

Cluster creation will take rought 20-25 miins, once its been created and ready as shown above, Verify the EKS Cluster via AWS Console or `kubectl get all`

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

1. Using Agents
   - Defining Agents/Slaves to run through pipeline execution
     Reference : https://www.jenkins.io/doc/book/using/using-agents/
2. Using Credentials
   - Defining Credentials for Git, Docker, EKS Cluster config
     Reference : https://www.jenkins.io/doc/book/using/using-credentials/
3. Using Plug-in
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

Aim is to faciliate automated way of Continious Deployment and Integration of Hello-World  java application packaging, creating Docker image and deploying containered microservies into AWS EKS - Kubernetes Cluster using Jenkins pipelines.

Hello-World is an Springboot Microservices based Java application. I have already created a repo with source code, including Dockerfile, Jenkinsfile and other supported project files. 


## Source Code

Git Clone
```bash
git clone https://github.com/dhrumilpatel/gs-spring-boot.git
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
```

## Testing Locally

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
[ec2-user@ip-172-31-4-42 helloworld]$ docker build -t helloworld:v1 .
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
[ec2-user@ip-172-31-4-42 helloworld]$ kubectl create -f k8s-hello-world.yaml
deployment.apps/hello-world-deploy created
service/hello-world-service created
horizontalpodautoscaler.autoscaling/hello-world-deploy created
poddisruptionbudget.policy/hello-world-pdb created


[ec2-user@ip-172-31-4-42 helloworld]$ kubectl get all
NAME                                      READY   STATUS    RESTARTS   AGE
pod/hello-world-deploy-7d666575bc-f2q82   1/1     Running   0          85s
pod/hello-world-deploy-7d666575bc-nk8t8   1/1     Running   0          85s

NAME                          TYPE           CLUSTER-IP     EXTERNAL-IP                                                                PORT(S)          AGE
service/hello-world-service   LoadBalancer   10.100.31.14   a7af352b518a24a1393921e3b4506153-1094458878.eu-north-1.elb.amazonaws.com   8080:30600/TCP   85s
service/kubernetes            ClusterIP      10.100.0.1     <none>                                                                     443/TCP          2d18h

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-world-deploy   2/2     2            2           86s

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/hello-world-deploy-7d666575bc   2         2         2       86s

NAME                                                     REFERENCE                       TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/hello-world-deploy   Deployment/hello-world-deploy   <unknown>/50%   2         5         2          85s
```

### CI/CD Pipelines

Jenkins Jobs
- hello-world-packaging: This Job will git pull last commit and perform packaging using maven of hello-world microservices.
- hello-world-imaging: This job will git pull last commit package and perform docker image creation.
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

    !(/images/Job-docker-image.png)

- hello-world-k8s-deployment: This job will git pull commit docker image and deploy to AWS EKS Cluster
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
        !(/images/Job-k8s-deploy.png)

## Log Monitor Script

```bash
sh find_errors.sh --help
#############################
USAGE :  sh find_errors.sh
This script does not accept any arguments, log directory are hardcoded, change it before running the script
#############################
############# Description ################
This script looks into useractivity_logfile.log and monitors ERROR enteries; save them in an output file for further analysis.
#############################
Extra Scope  --> 1. For a dynamically growing/lotating logfile, add this script to crontab jobs for every minute, and uncomment the tail command provided in the script.
                 2. Create a suitable crontab Job
##########################################
```
```bash
[ec2-user@ip-172-31-4-42 helloworld]$ cat useractivity_logfile.log_status_2021-09-30.log
32019-4-1 13:33:45 [123] User0 goes to search page
42019-4-1 13:33:46 [123] User0 types in search text
45fty-4-1 13:33:54 [123] ERROR: fetal Some exception occured-------
72019-4-1 13:33:50 [123] User9 clicks search button
82019-4-1 13:33:53 [256] User10 does something
92019-4-1 13:33:54 [123] ERROR: Some exception occured-------
102019-4-1 13:33:56 [256] User1 logs off
112019-4-1 13:33:57 [190] ERROR: Invalid input-------
22019-4-1 13:33:45 [123] User2 logs in
32019-4-1 13:33:45 [123] User3 goes to search page
45fty-4-1 13:33:54 [123] ERROR: Some exception occured-------
11234-4-1 13:33:49 [190] User3 runs some job
23456-4-1 13:33:50 [123] User4 clicks search button
45fty-4-1 13:33:54 [123] ERROR: Some exception occured-------
23421-4-1 13:33:57 [190] ERROR: Invalid input-------
3derfr-4-1 20:33:53 [256] User2 does something
dededed-4-1 20:33:54 [123] ERROR: Some exception occured-------
11234-4-1 13:33:49 [90] User3 runs some job
23456-4-1 13:33:50 [23] User4 clicks search button
45fty-4-1 13:33:54 [13] ERROR: Some exception occured-------
23421-4-1 13:33:57 [19] ERROR: Invalid input-------
3derfr-4-1 13:33:53 [25] User2 does something
dededed-4-1 13:33:54 [222] ERROR: Some exception occured-------

```

