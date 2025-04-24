locals {
  baseline_packages = ["build-base", "busybox", "git", "openssh-client"]
}

module "accts" {
  run-as = 0
  source = "../../../tflib/accts"
}

terraform {
  required_providers {
    apko = { source = "chainguard-dev/apko" }
  }
}

variable "extra_packages" {
  default     = ["go"]
  description = "The additional packages to install (e.g. go, go-1.18, go-1.19)."
}

variable "environment" {
  default     = {}
  description = "The additional or different environment variables to set"
}

output "config" {
  value = jsonencode({
    "contents" : {
      // TODO: remove the need for using hardcoded local.baseline_packages by plumbing
      // these packages through var.extra_packages in all callers of this config module
      "packages" : distinct(concat(local.baseline_packages, var.extra_packages))
    },
    "entrypoint" : {
      "command" : "/usr/bin/go"
    },
    "cmd" : "help",
    "accounts" : module.accts.block,
    "environment" : merge({
      "GODEBUG" : "tarinsecurepath=0,zipinsecurepath=0",
      "GOTOOLCHAIN" : "local+auto"
    }, var.environment)
  })
}

