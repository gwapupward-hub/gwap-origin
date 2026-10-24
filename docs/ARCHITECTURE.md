# GWAP Origin v1 architecture

## Separation of concerns
- gwap-origin (this repo): durable asset versions, hashes, lineage, evidence, verification states, and future provenance service.
- gwapspot-web (existing repo, not modified here): GwapStyle Studio homepage entry point, upload and results UI, consumer authentication, paid credits, and publicly linked Origin verification screens.
- Private image-generation worker (future): content moderation, image-to-image transformation, verified output hashing, embedded watermark experiments, C2PA signing, and export.
- PPV (existing repo, not modified here): optional later timestamp/proof anchoring only. PPV is not an arbiter of copyright or C2PA trust.

## Proposed flow
1. Authenticated creator provides an image under a rights attestation. Browser uploads via scoped, short-lived object-storage URL; server revalidates bytes, MIME signature, file size, pixel count, and malware checks. EXIF/GPS removed from published derivatives by policy.
2. Backend creates a private project asset and content-addressed, append-only source version. Raw originals remain private and short-lived unless creator explicitly opts into retention.
3. Generation worker produces a new, separate version. Links point from generated version to the original version; logs model vendor, model version, normalized parameters, and creator-declared AI contribution.
4. Watermark engine embeds an independently evaluated, key-controlled robust ID in exported pixels. Store embedding scheme and version in a restricted registry; treat extraction as probabilistic, and never claim it survives all crops, screenshots, or filters.
5. C2PA signer creates a manifest for the **final encoded bytes** with accurately labeled AI/edit actions, ingredients, software identity, and signature. Validate again after signing and verify bytes/hash consistency. If the output pipeline changes the pixels or strips metadata, re-sign the actual distributed file.
6. Add a signed provenance receipt and optional later PPV commitment. Separate asset data from public display metadata.
7. Return result, secure download, and a public share/verify URL. The public verifier reports evidence status plus limitations; claims of ownership are always self-declared unless independently evidenced.

## Evidence states
- missing: no C2PA evidence was supplied; never equate to AI-generated.
- invalid: signature or media binding failed.
- signed_untrusted: cryptographic binding valid; issuer not trusted.
- signed_trusted: cryptographic binding valid under a configured trust list; signed statements may still be false.
- PPV anchor state displayed independently: offchain, devnet, or mainnet. Devnet is not advertised as production protection.

## Versioning/data rules
- Asset is a logical work; asset_version is one exact byte sequence. Distinct transformations always produce a distinct version.
- Content SHA-256 is calculated server-side; perceptual hashes are hints for similarity and never identity proofs.
- Originals, public derivatives, watermark IDs, C2PA manifests, and PPV references have distinct storage and visibility policies.
- Provenance events and evaluations are append-only. Corrections add a new event or statement.
- Tenant authorization must be enforced server-side and in PostgreSQL row-level policies before public rollout.
- A public verifier may lookup a creator-shared receipt without exposing raw source files, GPS, prompts, emails, addresses, or generation secrets.

## Future API contract (proposal only; not implemented)
POST /v1/assets (authenticated private registration)
POST /v1/assets/{id}/versions (authenticated)
POST /v1/generations (authenticated or claim-backed identity; debit only on completed success)
GET /v1/jobs/{id} (authenticated)
GET /v1/verify/{publicId} (free and neutral)
POST /v1/verify/file (rate limited, scan and verify, no permanent storage by default)

## GwapStyle Studio plan
Two curated GwapFX presets:
- Signature: glossy black subject, strong #13DD13 accent, tiny orange #FF8A24 and purple #9B6CFF details.
- Shadow: black primary-object silhouette on saturated #13DD13 green with restrained orange/purple hints.
The future homepage allows upload, preview, style selection, Generate/GwapStyle, before/after, download, and Origin receipt. Free tier: 3 **successful** generations per eligible creator, not three clicks; paid packs will be priced after measuring actual generation cost. Credits and refunds must be atomic, idempotent, bot-resistant, and backed by verified payment webhooks. Do not let anonymous cookie resets mint free credits repeatedly.

## Integration gates
No payment provider, generation model, watermark algorithm, C2PA signer certificate, authentication provider, storage host, hosting, or PPV production ABI has been selected in this PR. Decisions require a separate implementation review. No user uploads or public API endpoints enabled by the scaffold.
