module "file_share_directory" {
  source   = "../file_share_directory"
  for_each = try(var.settings.directories, {})

  storage_account_name = var.storage_account_name
  storage_share_id     = azurerm_storage_share.fs.id
  settings             = each.value
}