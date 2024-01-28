/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# Documentation: https://cloud.google.com/run/docs/securing/managing-access#making_a_service_public

variable "admin_principals" {
  description = "Users, groups and/or service accounts that are assigned roles, in IAM format (`group:foo@example.com`)."
  type        = list(string)
  default     = []
}

variable "cloud_run_invoker" {
  description = "IAM member authorized to access the end-point (for example, 'user:YOUR_IAM_USER' for only you or 'allUsers' for everyone)."
  type        = string
  default     = "allUsers"
}

variable "cloudsql_password" {
  description = "CloudSQL password (will be randomly generated by default)."
  type        = string
  default     = null
}

variable "connector" {
  description = "Existing VPC serverless connector to use if not creating a new one."
  type        = string
  default     = null
}

variable "create_connector" {
  description = "Should a VPC serverless connector be created or not."
  type        = bool
  default     = true
}

variable "custom_domain" {
  description = "Cloud Run service custom domain for GLB."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Prevent Terraform from destroying data storage resources (storage buckets, GKE clusters, CloudSQL instances) in this blueprint. When this field is set in Terraform state, a terraform destroy or terraform apply that would delete data storage resources will fail."
  type        = bool
  default     = false
  nullable    = false
}

variable "iap" {
  description = "Identity-Aware Proxy for Cloud Run in the LB."
  type = object({
    enabled            = optional(bool, false)
    app_title          = optional(string, "Cloud Run Explore Application")
    oauth2_client_name = optional(string, "Test Client")
    email              = optional(string)
  })
  default = {}
}

# PSA: documentation: https://cloud.google.com/vpc/docs/configure-private-services-access#allocating-range
variable "ip_ranges" {
  description = "CIDR blocks: VPC serverless connector, Private Service Access(PSA) for CloudSQL, CloudSQL VPC."
  type = object({
    connector = string
    psa       = string
    ilb       = string
  })
  default = {
    connector = "10.8.0.0/28"
    psa       = "10.60.0.0/24"
    ilb       = "10.128.0.0/28"
  }
}

variable "phpipam_config" {
  description = "PHPIpam configuration."
  type = object({
    image = optional(string, "phpipam/phpipam-www:latest")
    port  = optional(number, 80)
  })
  default = {
    image = "phpipam/phpipam-www:latest"
    port  = 80
  }
}

variable "phpipam_exposure" {
  description = "Whether to expose the application publicly via GLB or internally via ILB, default GLB."
  type        = string
  default     = "EXTERNAL"
  validation {
    condition     = var.phpipam_exposure == "INTERNAL" || var.phpipam_exposure == "EXTERNAL"
    error_message = "phpipam_exposure supports only 'INTERNAL' or 'EXTERNAL'"
  }
}

variable "phpipam_password" {
  description = "Password for the phpipam user (will be randomly generated by default)."
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix used for resource names."
  type        = string
  nullable    = false
  validation {
    condition     = var.prefix != ""
    error_message = "Prefix cannot be empty."
  }
}

variable "project_create" {
  description = "Provide values if project creation is needed, uses existing project if null. Parent is in 'folders/nnn' or 'organizations/nnn' format."
  type = object({
    billing_account_id = string
    parent             = string
  })
  default = null
}

variable "project_id" {
  description = "Project id, references existing project if `project_create` is null."
  type        = string
}

variable "region" {
  description = "Region for the created resources."
  type        = string
  default     = "europe-west4"
}

variable "security_policy" {
  description = "Security policy (Cloud Armor) to enforce in the LB."
  type = object({
    enabled      = optional(bool, false)
    ip_blacklist = optional(list(string), ["*"])
    path_blocked = optional(string, "/login.html")
  })
  default = {}
}

variable "vpc_config" {
  description = "VPC Network and subnetwork self links for internal LB setup."
  type = object({
    network    = string
    subnetwork = string
  })
  default = null
}
