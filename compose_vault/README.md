# Vault Secret Rotation

Example using vault for dynamic secret rotation of Kong postgres credentials.

## How

Everything should be resilient enough to do a 

```
docker-compose up -d
```

The postgres root password is only known to vault, Kong uses
dynamically generated credentials that have a expiry but the
behaviour is they get renewed prior to expiring.

## Explanation

The order of operations is generally:
- start a cluster of three consul servers
- start hashicorp vault using consul as it's backend
- start postgres with some seed credentials
- start a vault setup script
  - unseals the vault
  - enables the database secret engine
  - rotates the root credential
  - configures dynamic secrets
  - generates a vault token with permissions to read the secret
  - places the token on a shared volume
  - loops forever to monitor if the vault gets re-sealed
- start a kong instance
  - gets the vault token from the shared volume
  - uses consul-template to update the postgres username / password
  - if the credentials change it will update the config and bounce Kong

## Notes

- consul-template could be substituted for envconsul
- both consul-template and envconsul renew the lease on the credentials
- can recover from vault / postgres / kong reboots
- can recover from a single consul reboot
- had some challenges removing postgres roles that created tables. Instead they're modified to NOLOGIN
