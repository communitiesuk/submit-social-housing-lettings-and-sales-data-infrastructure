locals {
  # This is used when restrict_by_ip is set to true, to restrict access to testing environments
  ip_allowlist = [
    # Softwire
    "31.221.86.178",
    "167.98.33.82",
    "82.163.115.98",
    "87.224.105.250",
    "87.224.116.242/32",
    "45.150.142.210/32"
    # DLUHC - TODO
  ]
}