import { createHash, timingSafeEqual } from "node:crypto";

const PROOF_DOMAIN = Buffer.from("GWAP-ORIGIN-PROOF-V1", "ascii");
const HEX_64 = /^[0-9a-f]{64}$/;
const HEX_NONCE = /^[0-9a-f]{32,}$/;

export function sha256Hex(data: Uint8Array): string {
  return createHash("sha256").update(data).digest("hex");
}

export function isSha256Hex(value: unknown): value is string {
  return typeof value === "string" && HEX_64.test(value);
}

export type ProofInput = Readonly<{
  assetSha256: string;
  receiptSha256: string;
  nonceHex: string;
}>;

/**
 * Commitment binds the exact media bytes hash, a canonical receipt hash, and
 * a random nonce. A commitment proves neither who created media nor when.
 * It may be anchored later through a separately reviewed PPV adapter.
 */
export function proofCommitment(input: ProofInput): string {
  if (!isSha256Hex(input.assetSha256) || !isSha256Hex(input.receiptSha256)) {
    throw new TypeError("Expected lowercase SHA-256 hex digests");
  }
  if (!HEX_NONCE.test(input.nonceHex) || input.nonceHex.length % 2 !== 0) {
    throw new TypeError("Expected at least 16 random nonce bytes in lowercase hex");
  }
  const hash = createHash("sha256");
  hash.update(PROOF_DOMAIN);
  hash.update(Buffer.from([0]));
  hash.update(Buffer.from(input.assetSha256, "hex"));
  hash.update(Buffer.from(input.receiptSha256, "hex"));
  hash.update(Buffer.from(input.nonceHex, "hex"));
  return hash.digest("hex");
}

export function verifyProofCommitment(input: ProofInput, expected: string): boolean {
  if (!isSha256Hex(expected)) return false;
  const actual = Buffer.from(proofCommitment(input), "hex");
  return timingSafeEqual(actual, Buffer.from(expected, "hex"));
}
