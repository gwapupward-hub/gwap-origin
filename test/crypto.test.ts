import assert from "node:assert/strict";
import { test } from "node:test";
import { proofCommitment, sha256Hex, verifyProofCommitment } from "../src/crypto.ts";

test("SHA-256 vectors are stable", () => {
  assert.equal(sha256Hex(Buffer.from("abc")), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
  assert.equal(sha256Hex(Buffer.alloc(0)), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
});

test("proof commitment is deterministic and nonce-bound", () => {
  const input = {
    assetSha256: "a".repeat(64),
    receiptSha256: "b".repeat(64),
    nonceHex: "c".repeat(32),
  };
  const commitment = proofCommitment(input);
  assert.match(commitment, /^[0-9a-f]{64}$/);
  assert.equal(proofCommitment(input), commitment);
  assert.equal(verifyProofCommitment(input, commitment), true);
  assert.equal(verifyProofCommitment(input, "d".repeat(64)), false);
  assert.notEqual(proofCommitment({ ...input, nonceHex: "d".repeat(32) }), commitment);
});

test("rejects malformed hashes and low-entropy nonce lengths", () => {
  const input = {
    assetSha256: "a".repeat(64),
    receiptSha256: "b".repeat(64),
    nonceHex: "c".repeat(32),
  };
  assert.throws(() => proofCommitment({ ...input, assetSha256: "0x" + "a".repeat(64) }));
  assert.throws(() => proofCommitment({ ...input, nonceHex: "ab" }));
});
