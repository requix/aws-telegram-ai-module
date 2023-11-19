variable "app_name" {
  description = "Application name. Will be used as prefix for resource naming"
  type        = string
  default     = "bot"
}

variable "allowed_users_ids" {
  description = "List of allowed Telegram users"
  type        = list(any)
  default     = []
}

variable "assistant_name" {
  description = "The name of the assistant. The maximum length is 256 characters."
  type        = string
  default     = "Personal Assistant"
}

variable "assistant_instructions" {
  description = "The system instructions that the assistant uses. The maximum length is 32768 characters."
  type        = string
  default     = "You are personal assistant. Use friendly and short responses."
}

variable "assistant_model" {
  description = "ID of the model to use."
  type        = string
  default     = "gpt-4-1106-preview"
}

variable "enable_code_interpreter" {
  description = "Is code interpreter tool should be enabled for Assistant"
  type        = bool
  default     = true
}
