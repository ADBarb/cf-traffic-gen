# cf-traffic-gen

Static JSON endpoints served by GitHub Pages behind a proxied Cloudflare DNS record.
This will generate test traffic for Cloudflare API Gateway endpoint discovery.

## Endpoints

| Method | Path |
|---|---|
| GET | `/api/v1/status.json` |
| GET | `/api/v1/users.json` |
| GET | `/api/v1/users/{1,2,3}.json` |
| GET | `/api/v1/products.json` |
| GET | `/api/v1/products/{101,102,103}.json` |

## Running the traffic generator

Run it from a machine outside Cloudflare, such as your laptop. Requests sent from Cloudflare Workers don't count toward discovery.

```bash
chmod +x generate-traffic.sh            # first time only
./generate-traffic.sh https://api.<your-domain> [rounds]
```

| Argument | Required | Default | Description |
|---|---|---|---|
| `host` | Yes | — | Base URL, with no trailing slash |
| `rounds` | No | `700` | Number of rounds. Each round sends 5 requests, with a 1s pause between rounds. |

Examples:

```bash
./generate-traffic.sh https://api.<your-domain>        # full run, ~15–20 min
./generate-traffic.sh https://api.<your-domain> 5      # quick smoke test
```

Each round requests the three collection endpoints plus one random user and one random product.
It sends an `Authorization: Bearer test-session-N` header, where N is one of 20 values, to simulate different sessions.

Discovery needs roughly **500+ requests per endpoint**. The default 700 rounds is above that for the collection endpoints.
Running it again on a second day improves the chances of detection.

## Reading the output

Each line shows `<status> <cf-cache-status> <path>`:

| Output | Meaning | Action |
|---|---|---|
| `200 DYNAMIC` / `200 BYPASS` | Request reached the origin | None |
| `200 HIT` | Served from Cloudflare cache | Fix the cache-bypass rule |
| `403` / `503` | Blocked or challenged by WAF, bot, or rate-limit rules | Check Security Events or GraphQL |
| `404` | Wrong path, or the Pages custom domain isn't set | Check the GitHub Pages settings |
| `000` | DNS or TLS failure | Check the DNS record and SSL mode |

## After running

Wait **24–48 hours**, then check the API Discovery response.

Item paths may be grouped into a pattern such as `/api/v1/users/{var1}.json`.

If nothing appears, check that `discovery_state` in the `/discovery/operations` API response shows discovery is enabled for the zone.

## Notes

- GitHub manages the `CNAME` file in this repo through **Settings → Pages → Custom domain**. Don't delete it.
- If GitHub can't renew the Pages TLS certificate later, set the DNS record to DNS-only (unproxied) for a short time, then turn the proxy back on.
