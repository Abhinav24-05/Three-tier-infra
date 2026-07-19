variable "name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnets" { type = list(string) }
variable "db_username" { type = string
	default = "dbuser"
}

variable "db_password" { type = string
	default = "changeme123"
}
