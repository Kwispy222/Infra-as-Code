variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

variable "pub_key" {
  description = "pub key"
  type        = string
  default     = "OOPS!"
}