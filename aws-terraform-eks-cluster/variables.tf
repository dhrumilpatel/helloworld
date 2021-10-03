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
    "852883190279"
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
      userarn  = "arn:aws:iam::852883190279:user/dhrumil"
      username = "dhrumil"
      groups   = ["system:masters"]
    }
  ]
}
