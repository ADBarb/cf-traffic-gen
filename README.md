# API discovery test origin
Static JSON endpoints served by GitHub Pages, fronted by a proxied DNS record,
used to generate traffic for Cloudflare API Shield endpoint discovery.
Run `./generate-traffic.sh https://api.<your-cis-domain>` from outside Cloudflare.
