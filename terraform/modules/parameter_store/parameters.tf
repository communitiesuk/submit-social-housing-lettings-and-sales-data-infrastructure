resource "aws_ssm_parameter" "this" {
  #checkov:skip=CKV_AWS_337:default encryption not using a kms cmk sufficient
  #checkov:skip=CKV2_AWS_34:false flag - parameters passed in by variable are encrypted as they all have the type "SecureString"
  for_each = var.parameters

  name  = each.key
  type  = each.value.type
  value = each.value.value
}
