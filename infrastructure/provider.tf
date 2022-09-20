terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.18.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    application_insights {
      disable_generated_rule = true
    }
  }
  subscription_id = "33d7eadb-fb41-4ef5-9c37-0d67c95a1e70"
}