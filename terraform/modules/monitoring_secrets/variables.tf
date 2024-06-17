variable "initial_create" {
  type        = bool
  description = "Set to true for initial creation to avoid reading the values of secrets which will need to be set in the console"
}

variable "prefix" {
  type        = string
  description = "The prefix to be prepended to resource names."
}
