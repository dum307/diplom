variable "tags" {
    type = map
    default = {
        Project = "dum307-diplom"
        Terraform = true
    }
}

variable "private_subnet_cidr" {
 type        = list(string)
 description = "Private Subnet CIDR value"
 default     = ["10.0.0.0/24"]
}

variable "public_subnet_cidr" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24"]
}
 
variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["eu-central-1a"]
}

variable "vpc_cidr_block" {
  type       = string
  default    = "10.0.0.0/16"
}

variable "ssh_port" {
    type = string
    default = "22"
}

variable "http_port" {
    type = string
    default = "80"
}

variable "key_name" {
  type = string
}

variable "k8s_master_name" {
  type = string
  default = "k8s-master"
}

variable "master_count" {
  type = string
  default = "1"
}

variable "k8s_worker_name" {
  type = string
  default = "k8s-worker"
}

variable "worker_count" {
  type = string
  default = "1"
}

variable "k8s_ingress_name" {
  type = string
  default = "k8s-worker"
}

variable "ingress_count" {
  type = string
  default = "1"
}

variable "private_key_file_path" {
    type = string
}
