import assert from "node:assert/strict";
import { test } from "node:test";
import { assessC2paEvidence } from "../src/provenance.ts";

test("absent evidence does not imply synthetic content", () => {
  const result = assessC2paEvidence({ status: "absent" });
  assert.equal(result.evidenceStatus, "missing");
  assert.equal(result.trustedSigner, false);
});

test("invalid evidence cannot be verified", () => {
  const result = assessC2paEvidence({ status: "invalid", reasonCode: "hash_mismatch" });
  assert.equal(result.verifiedCryptographicBinding, false);
});

test("valid untrusted signature remains separate from trusted identity", () => {
  const result = assessC2paEvidence({ status: "valid", signerTrusted: false });
  assert.equal(result.evidenceStatus, "signed_untrusted");
  assert.equal(result.trustedSigner, false);
  assert.equal(result.verifiedCryptographicBinding, true);
});

test("trusted signature still does not certify truth", () => {
  const result = assessC2paEvidence({ status: "valid", signerTrusted: true });
  assert.equal(result.evidenceStatus, "signed_trusted");
  assert.match(result.disclaimer, /does not independently prove/);
});
