export type CreationDeclaration =
  | "human_created"
  | "ai_generated"
  | "ai_assisted"
  | "unknown";

export type C2paEvidence =
  | Readonly<{ status: "absent" }>
  | Readonly<{ status: "invalid"; reasonCode: string }>
  | Readonly<{ status: "valid"; signerTrusted: boolean; signerLabel?: string }>;

export type ProvenanceAssessment = Readonly<{
  evidenceStatus: "missing" | "invalid" | "signed_untrusted" | "signed_trusted";
  verifiedCryptographicBinding: boolean;
  trustedSigner: boolean;
  disclaimer: string;
}>;

/**
 * Consumes the result of a future, audited C2PA validator. It does NOT parse
 * or validate C2PA files itself and cannot verify copyright or real-world truth.
 */
export function assessC2paEvidence(evidence: C2paEvidence): ProvenanceAssessment {
  if (evidence.status === "absent") {
    return {
      evidenceStatus: "missing",
      verifiedCryptographicBinding: false,
      trustedSigner: false,
      disclaimer: "No C2PA evidence was supplied; absence is not evidence of AI use.",
    };
  }
  if (evidence.status === "invalid") {
    return {
      evidenceStatus: "invalid",
      verifiedCryptographicBinding: false,
      trustedSigner: false,
      disclaimer: "C2PA validation failed; do not present provenance claims as verified.",
    };
  }
  return {
    evidenceStatus: evidence.signerTrusted ? "signed_trusted" : "signed_untrusted",
    verifiedCryptographicBinding: true,
    trustedSigner: evidence.signerTrusted,
    disclaimer: evidence.signerTrusted
      ? "A trusted signer bound the manifest to the media; this does not independently prove the claims, copyright, or authenticity."
      : "A valid signature binds this manifest to media, but the signer is not in the trusted list.",
  };
}
