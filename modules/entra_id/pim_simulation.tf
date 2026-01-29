/*# modules/entra_id/pim_simulation.tf
resource "azurerm_role_assignment" "emergency_sql_admin" {
  scope                = azurerm_mssql_server.healthcare.id
  role_definition_name = "SQL Security Manager"
  principal_id         = azuread_group.hc_break_glass.object_id
  
  # Simulate PIM: Role expires in 8 hours
  lifecycle {
    create_before_destroy = true
  }
  
  # This would be a Lambda/Function in reality to remove after 8h
}*/