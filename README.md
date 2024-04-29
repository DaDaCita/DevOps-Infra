# Infrastructure Documentation

## Description

I wanted to create the pipeline only via AWS services like Codebuild & ECR, but since this challenge should function dynamically, I've decided to take another route

## Resources used:

- DockerHub - To host and deploy the docker image.
- GitHub Actions - To handle Terraform formatting, deployments, and app tests.
- Terraform -  To build and destroy infrastructure.
- AWS EKS - To Host K8s cluster
- Kubectl - To access EKS Cluster

## Prerequisites

* AWS Account
* AWS CLI configured
* Terraform
* Kubectl

# Terraform File Structure
Creating Terraform infrastructure through modules comes in handy especially when the infrastructure becomes huge and repetitive. Instead of creating multiple files for VPC, we can create one module and keep calling it. This also works well when working with multiple environments such as `dev`, `stage`, and `prod`.
### For Instance:
```tf
data "aws_region" "current" {}

module "structure" {
  source                  = "./modules/structure"
  name_prefix             = "eks"
  cidr                    = "10.0.0.0/16"
  azs                     = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b", "${data.aws_region.current.name}c"]
  private_subnets         = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets          = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  cluster_name            = "eks_cluster_1"
  autoscaling_average_cpu = 50
}

module "eks_components" {
  source       = "./modules/eks_components"
  cluster_name = module.structure.cluster_object.cluster_id
}
```

## Modules folder
I wanted to have the skeleton of the infrastructure in the `structure` folder and the EKS guts inside the `eks_components` folder to keep this dynamic. Each folder contains a `variable.tf` file. This allows the user to write certain configs on `main.tf` file which will be passed to `modules/*`.

### For Instance, main.tf
```tf
module "structure" {
  source                  = "./modules/structure"
  name_prefix             = "eks"
  cidr                    = "10.0.0.0/16"
  azs                     = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b", "${data.aws_region.current.name}c"]
  private_subnets         = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets          = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  cluster_name            = "eks_cluster_1"
  autoscaling_average_cpu = 50
}
```

### Passed to modules/structure/variables.tf
```tf
variable "name_prefix" {
  type = string
}

variable "cidr" {
  type = string
}

variable "azs" {
  type = list(any)
}
...
```

### Finally, Both modules/structure/vpc.tf and eks.tf calls on the variables.tf file
```tf
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name_prefix}-vpc"
  cidr = var.cidr
  azs             = var.azs
  ...
```


# Building Terraform Infrastructure

1. Navigate to terraform-dev directory `cd terraform-dev`

2. On `provider.tf`, enter credentials on the locals block.
    ```tf
    locals {
        AWS_ACCESS_KEY_ID     = ""
        AWS_SECRET_ACCESS_KEY = ""
        AWS_DEFAULT_REGION    = ""
    }
    
    ```
3. Ensure current directory is `terraform-dev` & run `terraform init`
4. Run `terraform plan`:
    - BONUS: If you would like to see an interactive graph of the plan 
    checkout this site [`terraform-visual`](https://hieven.github.io/terraform-visual/).
5. To build the infrastructure run `terraform apply`
    - NOTE: Allow around 10 minutes to create EKS cluster

## Access Flask App
Once Infrastructure is built, to get the URL to the flask app you will need to access the cluster and get the External_IP from the k8s service resource.
1. Run these commands
    ```bash
    aws eks update-kubeconfig --region <region-code> --name eks_cluster_1

    kubectl get all -n flask-app
    ```
2. You should see output similiar to this:
    ```bash
    NAME                TYPE           CLUSTER-IP       EXTERNAL-IP                                              PORT(S)        AGE
    service/flask-app   LoadBalancer   172.20.197.253   xxxxxxxxxxxxxxxxxxxxxxxxxx.us-east-1.elb.amazonaws.com   80:31197/TCP   31s
    ```
3. Copy the `EXTERNAL-IP` and paste it into the browser. You should see this:
    ```json
    {"result": "WELCOME!"}
    ```
4. For Challenge purposes, check out `/status`

# GitHub Actions CI/CD
In `flask_github_actions.github/workflows` folder you will see these files:
- build-deploy.yml - Build the image and push it to DockerHub
- terraform_fmt.yml - Will run `terraform fmt` per PR and comment the difference
- test.yml - Will test the Flask Application with unittest package


# Requirements List:
- :white_check_mark: Create a Dockerfile for running this repository's Python server in Docker
  - :white_check_mark: When you navigate to the `/status` endpoint, it should respond with `{"result": "success"}`
- :white_check_mark: Create Terraform file(s) for spinning up the needed infrastructure via a cloud provider
  - :white_check_mark: There should be a publicly accessible `/status` endpoint that responds with `{"result": "success"}`~~

# Stretch Goals List:
- :white_check_mark: Build and push container image via CI
  - :white_check_mark: You can use either GitHub actions or Travis
  - :white_check_mark: Use any container repository that you like, public or private
- :white_check_mark: Write tests for your code and run them via CI
  - :white_check_mark: You can use GitHub actions or Travis
  - :white_check_mark: Tests should run automatically when a pull request is created against the main branch
  - :white_check_mark: Grant `zopz` write access to the repository to test
- :point_right::point_left: Write Kubernetes manifests or Helm charts to deploy the container into a Kubernetes cluster (I was able to do this with the Kubernetes provider if that counts.)
  - You do not need to provide Terraform code for provisioning the cluster, you can assume an existing cluster
  - :white_check_mark: The application should be exposed as a service such that it can be accessed from a browser (local IP is fine)
- :x: Create a `/ip` endpoint that returns the city and state of the IP requesting the page (I would like to know how this can be done. I was only able to retrieve the eks internal ip. Not implemented.)
  - You are free to use any third-party software/services to convert the IP to location data
  - The response should be returned as a JSON result matching the following model:
    ```
    {
    "ip": "string",
    "city": "string",
    "state": "string"
    }
    ```

## Authors

Miguel Angel Santana (Angelo)  @dadacita](https://github.com/DaDaCita)
