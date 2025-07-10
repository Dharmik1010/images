variable "extra_packages" {
  description = "Additional packages to install."
  type        = list(string)
  default     = ["apko"]
}

output "config" {
  value = jsonencode({
    contents = {
      packages = concat(var.extra_packages, [
        "wolfi-keys",
      ])
    }
    // TODO: Does this need accounts?
    paths = [{
      path : "/work",
      type : "directory",
      permissions = 511 // 0o777 (HCL explicitly does not support octal literals)
    }]
    entrypoint = {
      command = "/usr/bin/apko"
    }
    work-dir = "/work"
    cmd      = "--help"
  })
}
