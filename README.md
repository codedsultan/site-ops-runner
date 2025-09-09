# site-ops-runner

A tiny, reproducible toolbox image for CI/CD and site ops.
Built on `alpine:3.20` with common CLI tools (bash, curl, jq, yq, openssl, git, docker-cli, compose, etc.).
Shipped as **multi-arch** (linux/amd64, linux/arm64), **scanned**, **optionally signed**, and **smoke-tested**.

## Why

* Lock the execution environment for ops scripts.
* Version like a product (SemVer).
* Safe roll-forwards/rollbacks via **tag + digest** pinning.

## Versioning

* Semantic Versioning (**MAJOR.MINOR.PATCH**), e.g. `1.2.0`.
* CI tags:

  * `ghcr.io/<org>/site-ops-runner:v1.2.0`
  * `ghcr.io/<org>/site-ops-runner:1` (major)
  * `ghcr.io/<org>/site-ops-runner:1.2` (minor)
* Bump **VERSION** and commit to trigger a release.

## Using the image

Pull by **digest** for reproducible runs:

```bash
# Example: pin major + digest
IMG=ghcr.io/<org>/site-ops-runner:1@sha256:<digest>
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock "$IMG" /work/smoke-tests/verify-tools.sh
```

Or run an interactive shell:

```bash
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/<org>/site-ops-runner:1 bash
```

## CI/CD (GitHub Actions)

* File: `.github/workflows/runner-build.yml`
* On `push` to `main` (and weekly):

  1. Build multi-arch
  2. Push with `vX.Y.Z`, `X`, `X.Y` tags
  3. Generate SBOM (Syft)
  4. Scan (Trivy)
  5. (Optional) Sign with Cosign
  6. **Smoke tests** run the container and execute `/work/smoke-tests/verify-tools.sh`

## Smoke tests

`smoke-tests/verify-tools.sh` checks that key binaries exist and prints versions.
Keep it fast and deterministic; add checks as your scripts grow.

## Local build

```bash
docker build -f Dockerfile.runner -t site-ops-runner:dev .
docker run --rm site-ops-runner:dev /work/smoke-tests/verify-tools.sh
```

## Updating tools

Prefer adding tools via `apk add --no-cache` in `Dockerfile.runner`.
If you add a tool that needs a daemon (e.g., `docker`), surface it via `/var/run/docker.sock` as shown above.

## Security notes

* Image runs as `root` with passwordless sudo for determinism in CI. If you need stricter hardening, switch to a non-root user and whitelist commands.
* Weekly rebuild keeps base packages fresh. Trivy scan fails on **HIGH/CRITICAL** by default (adjust in workflow if needed).
* Cosign step supports keyless signing (OIDC).

## Known gotchas

* Ensure `ENTRYPOINT` is valid JSON. It should be:

  ```dockerfile
  ENTRYPOINT ["/bin/bash","-lc"]
  ```

  (remove any trailing full stop).

## Directory layout

```
site-ops-runner/
├─ Dockerfile.runner
├─ smoke-tests/
│  └─ verify-tools.sh
├─ .github/
│  └─ workflows/
│     └─ runner-build.yml
├─ README.md
└─ VERSION
```

## Licence

MIT 