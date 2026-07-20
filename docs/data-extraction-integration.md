# Excel-to-AASX Integration

This branch adds the `excel-to-aasx` generator beside the secured AAS Level 3
runtime.

## Boundary

```text
excel-to-aasx/
  owns Excel extraction, template mapping, validation, and AASX packaging

root AAS-Level3 stack
  owns secured BaSyx runtime, Keycloak, Nginx, MongoDB, and hosted AASX files
```

The generator produces AASX files. The runtime consumes AASX files mounted from:

```text
aas/
```

## Generate AASX

Install the generator once:

```sh
cd excel-to-aasx
python3 -m venv .venv
. .venv/bin/activate
pip install -e .[dev]
```

The required third-party AAS template/reference files are included under:

```text
excel-to-aasx/third_party/
```

Input workbooks are not committed on this branch. Place them under:

```text
excel-to-aasx/data/input/<company>/
```

Run the generator:

```sh
make generate COMPANY=schunk
```

Expected output:

```text
excel-to-aasx/data/generated/schunk/xlsx-json-step4/
```

## Sync Generated AASX Into Runtime

From the repository root:

```sh
./scripts/sync-generated-aasx.sh schunk
```

This copies generated `.aasx` files into:

```text
aas/
```

The BaSyx AAS Environment container mounts that folder at:

```text
/application/aas
```

## Start Secured Runtime

Prepare environment and certificates as described in `README.md`, then run:

```sh
docker compose up -d
```

The runtime still requires the local ignored BaSyx properties file:

```text
basyx/aas-env.properties
```

That file is intentionally not added on this branch because the current root
repository ignores `*.properties` and treats runtime properties as local
configuration.

## Validation

Generator checks:

```sh
cd excel-to-aasx
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python3 -m pytest tests
```

Compose config check:

```sh
docker compose config
```

Runtime smoke check after startup:

```sh
curl -k https://${HOST_IP}:8081/shells
```
