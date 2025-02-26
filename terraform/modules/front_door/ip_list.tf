locals {
  # This is used when restrict_by_ip is set to true, to restrict access to testing environments
  ip_allowlist = [
    # Softwire
    "31.221.86.178/32",
    "167.98.33.82/32",
    "82.163.115.98/32",
    "87.224.105.250/32",
    "87.224.116.242/32",
    "45.150.142.210/32",
    # MHCLG
    "35.176.187.166/32",
    "52.56.253.115/32",
    "4.158.35.41/32",
    "20.108.197.65/32",
  ]
}
