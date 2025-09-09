## Versioning & Releases

We use **Semantic Versioning** (`MAJOR.MINOR.PATCH`).
Source of truth is the **`VERSION`** file (e.g. `1.2.3`). When it changes on `main`, an automation creates (or reuses) the git tag **`v1.2.3`**. Builds run on tags, weekly rebuilds, and manual runs.

**Tags published to GHCR**

* `ghcr.io/<org>/site-ops-runner:v1.2.3`
* `ghcr.io/<org>/site-ops-runner:1.2`
* `ghcr.io/<org>/site-ops-runner:1`

**Pin for reproducibility**

```bash
IMG=ghcr.io/<org>/site-ops-runner:1@sha256:<digest>
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock "$IMG" /work/smoke-tests/verify-tools.sh
```

## Release checklist

1. **Decide the bump**: `MAJOR` (breaking), `MINOR` (feature), or `PATCH` (fix).
2. **Update `VERSION`**:

   ```bash
   echo "1.2.3" > VERSION
   git add VERSION
   git commit -m "chore(release): 1.2.3"
   git push
   ```

   * This triggers **Tag when VERSION changes** → creates `v1.2.3`.
3. **Build & publish**: The **Build & Publish runner** workflow runs on the tag:

   * Multi-arch image built and pushed
   * SBOM generated (Syft)
   * Vulnerabilities scanned (Trivy)
   * (Optional) Signed (Cosign)
   * Digest exposed in logs
4. **Pin in consumers**: Update deployments to use `:1@sha256:<digest>` if needed.

### Pre-releases (optional)

* If you want RCs like `v1.3.0-rc.1`, set `VERSION` to `1.3.0-rc.1` and push to a **release branch**, or manually create a tag `v1.3.0-rc.1`.
* The build workflow (triggered by any `v*` tag) will publish RC images.
* Finalise by setting `VERSION` to `1.3.0`, pushing to `main`, letting the automation create `v1.3.0`.

## Reuse in other projects

* Copy this repo structure (Dockerfile, `smoke-tests/`, `VERSION`, and the GitHub workflows).
* Keep the **tag-driven** build strategy to enforce SemVer discipline.
* Always **pin by digest** in consumers to allow safe, auditable upgrades.

## CI/CD summary

* **Triggers**: Git tags `v*`, weekly rebuild (`cron`), manual dispatch.
* **Build**: Multi-arch (amd64, arm64) via Buildx.
* **Quality**: SBOM + Trivy scan; optional Cosign signing.
* **Smoke**: Runs `/work/smoke-tests/verify-tools.sh` inside the built image.

---

### One repo setting to enable

* **Settings → Actions → General → Workflow permissions →** enable **Read and write permissions** (needed for tag creation).


