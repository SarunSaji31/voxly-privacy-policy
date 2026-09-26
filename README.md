# Voxly privacy-policy source

Reviewed 2026-09-26. This repository publishes the privacy and account-deletion
pages through GitHub Pages. Keep these URLs available for installed app versions
and the Play listing.

`index.html` is the privacy policy; `delete-account.html` gives deletion steps and
retained-data disclosures. The September 26 wording clarifies translation feature
availability, first-use credits, language metadata, retained purchase identifiers,
the hashed free-credit guard, and possible sign-in deletion failures. Runtime
behavior was not re-audited; the deletion details use the local September 23
backend 7.31.0 snapshot.

The website repository `voxlykeys-site` generates its copies from these files.
After editing this source, run from that sibling checkout:

```sh
python3 tools/build_policy.py --source-dir ../voxly-privacy-policy
python3 tools/build_policy.py --source-dir ../voxly-privacy-policy --check
python3 tools/check_site.py --responsive
python3 -B -m unittest discover -s tools -p 'test_*.py'
```

Publish this repository first and wait for Pages to complete, then publish the
matching website changes. `python3 tools/build_policy.py --check` in the site
checkout compares against the published source without writing files. The site
release record is `docs/REVIEW-2026-09-26.md` in that repository. Preserve policy
wording through generation rather than making independent edits to the copies.
