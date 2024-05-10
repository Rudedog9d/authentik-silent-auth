terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = ">=2024.2.0"
    }
  }
}

provider "authentik" {}

# GET default implicit auth flow - no prompt for user consent on authz
data "authentik_flow" "default-implicit-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_scope_mapping" "profile" {
  scope_name = "profile"
}
data "authentik_scope_mapping" "email" {
  scope_name = "email"
}
data "authentik_scope_mapping" "offline_access" {
  # this scope is required for refresh tokens to be issued
  scope_name = "offline_access"
}

# https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/provider_oauth2
resource "authentik_provider_oauth2" "scoreboard-ui" {
  name      = "Scoreboard UI"
  client_id = "scoreboard-ui"
  authorization_flow = data.authentik_flow.default-implicit-authorization-flow.id
  client_type = "public"
  issuer_mode = "global"
  redirect_uris = [
    "http://localhost:5173"
  ]
  property_mappings = [
    # authentik managed scopes
    data.authentik_scope_mapping.email.id,
    data.authentik_scope_mapping.profile.id,
    data.authentik_scope_mapping.offline_access.id,
  ]
}

resource "authentik_application" "scoreboard-ui" {
  name              = "Scoreboard UI"
  slug              = "scoreboard-ui"
  protocol_provider = authentik_provider_oauth2.scoreboard-ui.id
}
