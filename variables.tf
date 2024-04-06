# general 
variable "proj" {
  default = "mtc-taj"
  type    = string
}

# networking

variable "vpc_cidr" {
  type      = string
  sensitive = true
}

variable "my_ip" {
  type      = string
  sensitive = true
}

variable "cloud9_ip" {
  type      = string
  sensitive = true
}

# computing

variable "main_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "main_vol_size" {
  type    = number
  default = 8 #GB
}

variable "main_instance_count" {
  type    = number
  default = 1
}

variable "key_name" {
  type = string
}

variable "public_key_path" {
  type = string
}
