# used for accesing Account ID and ARN
data "aws_caller_identity" "current" {}

# get EKS cluster info to configure Kubernetes 
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# get EKS authentication for being able to manage k8s objects from terraform
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_namespace" "flask_namespace" {
  metadata {
    name = "flask-app"
  }
}

resource "kubernetes_deployment" "flask_deployment" {
  metadata {
    name      = "flask-app"
    namespace = kubernetes_namespace.flask_namespace.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "FlaskApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "FlaskApp"
        }
      }
      spec {
        container {
          image = "dadacita/flask_app:latest"
          name  = "flask-app"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask_service" {
  metadata {
    name      = "flask-app"
    namespace = kubernetes_namespace.flask_namespace.metadata.0.name
  }
  spec {
    external_traffic_policy = "Local"
    selector = {
      app = kubernetes_deployment.flask_deployment.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
  }
}

