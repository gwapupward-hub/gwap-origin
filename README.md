# GWAP Origin

An independent provenance foundation for GWAP-created media and, eventually, third-party creators. **Status: early foundation, not a deployed service.**

GWAP Origin will record where a creative asset came from, how it changed, the evidence behind a claim, and whether the evidence verifies. It is deliberately distinct from an AI-content detector or copyright registry: a signature does **not** prove a claim is true, and an uploaded image does **not** prove ownership.

## v1 scope
- Internal-first asset/project registration, ordered versions, source declarations, content hashes, lineage, and immutable audit events.
- A neutral, free verification view with distinct states for absent, untrusted, invalid, and trusted C2PA evidence.
- Cryptographic, domain-separated proof commitments suitable for optional PPV anchoring after the PPV interface is reviewed.
- A separate, later GwapStyle Studio integration on gwapspot.com: 3 free successful generations per eligible user, paid packs with pricing TBD, and the GwapFX Signature/Shadow visual directions.

## Not yet implemented
No hosted API, image generation, C2PA validation/signing, robust invisible watermarking, Solana transactions, Stripe checkout, user authentication, production asset storage, or public uploads. All such switches default **off**.

## Local validation
Node.js 24+
```sh
npm install
npm run check
```

See [architecture](docs/ARCHITECTURE.md), [security gates](docs/SECURITY.md), and [database migration](sql/0001_origin_core.sql). Nothing in this repository changes PPV, GwapSpot, or RoyaltyRails.
