# GWAP Origin security and launch gates

Threats include stolen images and impersonated authorship, forged metadata, altered asset bytes, removed C2PA manifests, watermark false positives/negatives, leaking uploaded private media, API cost abuse, poisoned images, duplicate credit spends, compromised signing keys, and unverifiable PPV receipts.

## Mandatory before limited internal pilot
- Choose identity and tenant roles. Enforce server-side object ownership and database RLS with cross-tenant denial tests.
- Implement scoped object-storage URLs, upload size/pixel limits, MIME magic checks, decompression-bomb defense, media scanning, expiration and deletion policy.
- Review C2PA implementation against current official spec and validate malformed/stripped/re-encoded manifests. Signer keys managed by KMS/HSM; not committed or in client JS; documented rotation/revocation.
- Use tamper-evident append-only records, service-side hashing of exact media and canonical signed receipt format, clock-source handling, backups/recovery, audit logging and deletion/retention policy.
- Test watermark embedding and extraction on clean, JPEG recompression, resize, crop, screenshot, and noisy inputs. Define false-positive thresholds; do not describe a watermark ID as encryption or copyright ownership.
- Define ingestion moderation, rights attestation, DMCA/complaints route, prohibited content controls, and output disclosure policy.

## Before public beta
- Server-side generation quota; 3 free completed jobs per eligible subject; reliable identity plus anti-abuse controls, rate limits, bounded job queues and hard spend caps.
- Paid packs must be provisioned only after confirmed webhook events with replay protection, idempotency keys, ledger balance checks and refund handling.
- Publish a neutral, always-free verification method, with evidence outcomes and explicit caveats. Do not sell a higher trust badge.
- Validate image-worker vendor terms, security and logs; remove EXIF location from derivatives and avoid broadcasting source metadata.
- Independent penetration test/abuse exercises, real-device iOS Safari check, private object access checks, disaster recovery rehearsal.
- PPV adapter devnet dry run must verify exact program IDs, IDL, chain, receipt mapping, transaction finality and failure semantics. Do not switch on mainnet signing or custody without owner approval.

## Key principle
Cryptographic provenance can verify that a trusted signer asserted something about a given asset. It cannot independently prove human authorship, legal ownership, absence of AI involvement, or factual truth.
