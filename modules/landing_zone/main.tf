# Azure Landing Zone - Phase 1 (AWS Control Tower/SCP Pattern)

# 1. Management Groups Hierarchy (Organization Units in AWS)
resource "azurerm_management_group" "root" {
  display_name = "Healthcare Organization"
  name         = var.root_management_group_id
}

resource "azurerm_management_group" "platform" {
  display_name               = "Platform"
  parent_management_group_id = azurerm_management_group.root.id
  name                       = "platform"
}

resource "azurerm_management_group" "landing_zones" {
  display_name               = "Landing Zones"
  parent_management_group_id = azurerm_management_group.root.id
  name                       = "landing-zones"
}

resource "azurerm_management_group" "healthcare_prod" {
  display_name               = "Healthcare Production"
  parent_management_group_id = azurerm_management_group.landing_zones.id
  name                       = "healthcare-prod"
}

# 2. Subscription Placement (Account enrollment in AWS Control Tower)
resource "azurerm_management_group_subscription_association" "current_to_healthcare" {
  management_group_id = azurerm_management_group.healthcare_prod.id
  subscription_id     = "/subscriptions/${var.subscription_id}"
}

# 3. Core Policy Definitions at ROOT level (AWS SCPs at Organization)
# These require global admin/equivalent permissions (Control Tower management account)
resource "azurerm_policy_definition" "require_sql_tde" {
  name                = "require-sql-tde"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "[HIPAA] Require SQL TDE Encryption"
  description         = "Ensures SQL databases have Transparent Data Encryption enabled"
  management_group_id = azurerm_management_group.root.id

  metadata = jsonencode({
    category = "SQL"
    version  = "1.0.0"
    controls = ["H09.06"]
  })

  policy_rule = jsonencode({
    "if" = {
      "allOf" = [
        {
          "field" = "type",
          "equals" = "Microsoft.Sql/servers/databases"
        },
        {
          "field" = "name",
          "notEquals" = "master"
        }
      ]
    },
    "then" = {
      "effect" = "AuditIfNotExists",
      "details" = {
        "type" = "Microsoft.Sql/servers/databases/transparentDataEncryption"
      }
    }
  })
}

resource "azurerm_policy_definition" "deny_public_sql" {
  name                = "deny-public-sql"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "[CIS] Deny Public SQL Access"
  description         = "Prevents SQL databases from allowing public network access"
  management_group_id = azurerm_management_group.root.id

  metadata = jsonencode({
    category = "Networking"
    version  = "1.0.0"
    controls = ["CIS 4.3.1"]
  })

  policy_rule = jsonencode({
    "if": {
      "field": "type",
      "equals": "Microsoft.Sql/servers"
    },
    "then": {
      "effect": "[parameters('effect')]"
    }
  })

  parameters = <<PARAMETERS
{
  "effect": {
    "type": "String",
    "metadata": {
      "displayName": "Effect",
      "description": "Enable or disable the execution of the policy"
    },
    "allowedValues": [
      "Audit",
      "Deny",
      "Disabled"
    ],
    "defaultValue": "Deny"
  }
}
PARAMETERS
}

# 4. Policy Initiative at ROOT level (AWS SCPs package)
resource "azurerm_policy_set_definition" "hipaa_foundational" {
  name                = "hipaa-foundational-controls"
  policy_type         = "Custom"
  display_name        = "HIPAA Foundational Security Controls"
  description         = "Core HIPAA security controls for healthcare environments"
  management_group_id = azurerm_management_group.root.id

  metadata = jsonencode({
    category = "Regulatory Compliance"
    version  = "1.0.0"
  })

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_sql_tde.id
    reference_id         = "sqlTde"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_public_sql.id
    reference_id         = "sqlPublic"
  }
}

# 5. Policy Assignments at LANDING ZONES level (SCPs applied to OU)
# This mimics AWS Control Tower applying SCPs to enrolled accounts via OUs
resource "azurerm_management_group_policy_assignment" "hipaa_to_landing_zones" {
  name                 = "hipaa-found-assignment"
  location            = "eastus2"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = azurerm_policy_set_definition.hipaa_foundational.id
  display_name         = "HIPAA Foundational Controls"
  description          = "Assign HIPAA foundational controls to all landing zones (AWS SCP pattern)"

  identity {
    type = "SystemAssigned"
  }
}

# 6. Role Definitions (AWS IAM Roles equivalent)
resource "azurerm_role_definition" "landing_zone_contributor" {
  name        = "Landing Zone Contributor"
  scope       = "/subscriptions/${var.subscription_id}"
  description = "Custom role for landing zone deployment with healthcare constraints (AWS IAM Role pattern)"

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/subscriptions/resourceGroups/write",
      "Microsoft.Resources/deployments/*",
      "Microsoft.Authorization/policyAssignments/read",
      "Microsoft.Authorization/policyDefinitions/read",
      "Microsoft.Authorization/policySetDefinitions/read"
    ]
    not_actions = [
      "Microsoft.Authorization/policyAssignments/write",
      "Microsoft.Authorization/policyDefinitions/write",
      "Microsoft.Authorization/policySetDefinitions/write"
    ]
  }

  assignable_scopes = [
    "/subscriptions/${var.subscription_id}"
  ]
}

# 7. Outputs
output "management_group_hierarchy" {
  value = {
    root            = azurerm_management_group.root.id
    platform        = azurerm_management_group.platform.id
    landing_zones   = azurerm_management_group.landing_zones.id
    healthcare_prod = azurerm_management_group.healthcare_prod.id
  }
  description = "Management group hierarchy IDs (AWS OU structure)"
}

output "policy_definitions" {
  value = {
    sql_tde    = azurerm_policy_definition.require_sql_tde.id
    public_sql = azurerm_policy_definition.deny_public_sql.id
  }
  description = "Custom policy definition IDs (AWS SCPs)"
}

output "policy_initiative" {
  value = azurerm_policy_set_definition.hipaa_foundational.id
  description = "HIPAA foundational controls initiative ID (AWS SCP package)"
}
