# site-ops-runner

A tiny, reproducible toolbox image for CI/CD and site ops.
Built on `alpine:3.20` with common CLI tools (bash, curl, jq, yq, openssl, git, docker-cli, compose, etc.).
Shipped as **multi-arch** (linux/amd64, linux/arm64), **scanned**, **optionally signed**, and **smoke-tested**.

### Why

* Lock the execution environment for ops scripts.
* Version like a product (SemVer) and publish on **Git tags**.
* Safe roll-forwards/rollbacks via **tag + digest** pinning.

### Versioning & Releases (new)

We use **Semantic Versioning**: `MAJOR.MINOR.PATCH`.

**Source of truth**

* The repo has a simple `VERSION` file (e.g., `1.2.3`) for humans and scripts.
* A separate workflow automatically creates a Git tag `v<VERSION>` when `VERSION` changes on `main`.
* **Builds** run when a tag like `v1.2.3` is pushed. Weekly rebuilds reuse the current `VERSION` without changing tags.

**Tags pushed to GHCR**

* `ghcr.io/<org>/site-ops-runner:v1.2.3`
* `ghcr.io/<org>/site-ops-runner:1.2`
* `ghcr.io/<org>/site-ops-runner:1`

**Bumping versions**

1. Edit `VERSION` (pick MAJOR/MINOR/PATCH).
2. Commit and push to `main`.
   The “tag-on-version-change” workflow creates `vX.Y.Z`.
3. The “Build & Publish” workflow builds and pushes the image with the three tags above.

### Reproducible pulls

Always pin to **digest**:

```bash
# Example: pin major + digest from the build output
IMG=ghcr.io/<org>/site-ops-runner:1@sha256:<digest>
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock "$IMG" /work/smoke-tests/verify-tools.sh
```

### CI/CD

* **Trigger:** Git tags `v*`, weekly rebuilds, or manual runs.
* **Build:** Multi-arch (amd64, arm64) via Buildx.
* **Assurance:** SBOM (Syft) + vulnerability scan (Trivy).
* **Optional:** Keyless signing (Cosign).
* **Smoke tests:** Runs `/work/smoke-tests/verify-tools.sh` inside the built image.

### Reuse in other projects

* Copy this repo structure and workflows.
* Keep a plain `VERSION` file.
* Adopt the same tag-driven build pattern so any repo can publish deterministic, signed toolbox images.
* Pin images by **major tag + digest** in your automation for safe updates.

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