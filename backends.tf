terraform {
  cloud {
    organization = "msl-terransible"

    workspaces {
      name = "msl-terransible"
    }
  }
}