-- GWAP Origin v1 relational foundation. Review and test on disposable PostgreSQL
-- before production; no migration runner or host is configured in this repo.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE origin_actors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  external_subject TEXT UNIQUE,
  display_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE origin_projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_actor_id UUID NOT NULL REFERENCES origin_actors(id),
  name TEXT NOT NULL CHECK (char_length(name) BETWEEN 1 AND 200),
  visibility TEXT NOT NULL DEFAULT 'private' CHECK (visibility IN ('private','public')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE origin_project_members (
  project_id UUID NOT NULL REFERENCES origin_projects(id) ON DELETE RESTRICT,
  actor_id UUID NOT NULL REFERENCES origin_actors(id) ON DELETE RESTRICT,
  role TEXT NOT NULL CHECK (role IN ('owner','editor','viewer')),
  PRIMARY KEY(project_id, actor_id)
);
CREATE TABLE origin_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES origin_projects(id) ON DELETE RESTRICT,
  created_by UUID NOT NULL REFERENCES origin_actors(id),
  title TEXT NOT NULL CHECK (char_length(title) BETWEEN 1 AND 255),
  visibility TEXT NOT NULL DEFAULT 'private' CHECK (visibility IN ('private','unlisted','public')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE origin_asset_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id UUID NOT NULL REFERENCES origin_assets(id) ON DELETE RESTRICT,
  sequence_number INTEGER NOT NULL CHECK (sequence_number > 0),
  content_sha256 CHAR(64) NOT NULL CHECK (content_sha256 ~ '^[0-9a-f]{64}$'),
  mime_type TEXT NOT NULL CHECK (mime_type IN ('image/jpeg','image/png','image/webp')),
  byte_length BIGINT NOT NULL CHECK (byte_length > 0),
  width_px INTEGER CHECK (width_px > 0),
  height_px INTEGER CHECK (height_px > 0),
  storage_object_key TEXT NOT NULL,
  mode TEXT NOT NULL CHECK (mode IN ('upload','gwapfx_signature','gwapfx_shadow','other_edit')),
  model_provider TEXT,
  model_identifier TEXT,
  model_version TEXT,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(asset_id, sequence_number),
  UNIQUE(id, asset_id)
);
CREATE TABLE origin_version_ingredients (
  derived_version_id UUID NOT NULL REFERENCES origin_asset_versions(id) ON DELETE RESTRICT,
  source_version_id UUID NOT NULL REFERENCES origin_asset_versions(id) ON DELETE RESTRICT,
  relationship TEXT NOT NULL CHECK (relationship IN ('input','reference','edit_source')),
  PRIMARY KEY(derived_version_id, source_version_id, relationship),
  CHECK (derived_version_id <> source_version_id)
);
CREATE TABLE origin_source_declarations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version_id UUID NOT NULL REFERENCES origin_asset_versions(id) ON DELETE RESTRICT,
  declared_by UUID NOT NULL REFERENCES origin_actors(id),
  creation_type TEXT NOT NULL CHECK (creation_type IN ('human_created','ai_assisted','ai_generated','unknown')),
  rights_assertion TEXT NOT NULL CHECK (rights_assertion IN ('own','licensed','authorized_other','unknown')),
  source_url TEXT,
  statement TEXT,
  declared_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE origin_c2pa_evaluations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version_id UUID NOT NULL REFERENCES origin_asset_versions(id) ON DELETE RESTRICT,
  manifest_sha256 CHAR(64) CHECK (manifest_sha256 ~ '^[0-9a-f]{64}$'),
  validator_name TEXT NOT NULL,
  validator_version TEXT NOT NULL,
  outcome TEXT NOT NULL CHECK (outcome IN ('absent','invalid','signed_untrusted','signed_trusted')),
  signer_identity TEXT,
  trust_list_version TEXT,
  raw_report_object_key TEXT,
  assessed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE origin_provenance_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES origin_projects(id) ON DELETE RESTRICT,
  version_id UUID REFERENCES origin_asset_versions(id) ON DELETE RESTRICT,
  actor_id UUID REFERENCES origin_actors(id) ON DELETE RESTRICT,
  event_type TEXT NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE origin_proof_receipts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version_id UUID NOT NULL REFERENCES origin_asset_versions(id) ON DELETE RESTRICT,
  commitment_sha256 CHAR(64) NOT NULL CHECK (commitment_sha256 ~ '^[0-9a-f]{64}$'),
  receipt_sha256 CHAR(64) NOT NULL CHECK (receipt_sha256 ~ '^[0-9a-f]{64}$'),
  state TEXT NOT NULL CHECK (state IN ('offchain','queued_devnet','anchored_devnet','anchored_mainnet','failed')),
  chain TEXT CHECK (chain IS NULL OR chain = 'solana'),
  transaction_signature TEXT,
  ppv_reference TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(version_id, commitment_sha256)
);

-- Evidence tables are insert-only: corrections must be new declarations,
-- evaluations, or events. The application must use an unprivileged DB role.
CREATE OR REPLACE FUNCTION origin_reject_evidence_mutation()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'GWAP Origin evidence is append-only';
END;
$$;
CREATE TRIGGER prevent_origin_version_mutation
  BEFORE UPDATE OR DELETE ON origin_asset_versions
  FOR EACH ROW EXECUTE FUNCTION origin_reject_evidence_mutation();
CREATE TRIGGER prevent_origin_declaration_mutation
  BEFORE UPDATE OR DELETE ON origin_source_declarations
  FOR EACH ROW EXECUTE FUNCTION origin_reject_evidence_mutation();
CREATE TRIGGER prevent_origin_evaluation_mutation
  BEFORE UPDATE OR DELETE ON origin_c2pa_evaluations
  FOR EACH ROW EXECUTE FUNCTION origin_reject_evidence_mutation();
CREATE TRIGGER prevent_origin_event_mutation
  BEFORE UPDATE OR DELETE ON origin_provenance_events
  FOR EACH ROW EXECUTE FUNCTION origin_reject_evidence_mutation();
CREATE TRIGGER prevent_origin_receipt_mutation
  BEFORE UPDATE OR DELETE ON origin_proof_receipts
  FOR EACH ROW EXECUTE FUNCTION origin_reject_evidence_mutation();

CREATE INDEX origin_versions_by_sha ON origin_asset_versions(content_sha256);
CREATE INDEX origin_events_by_project_time ON origin_provenance_events(project_id, occurred_at DESC);
CREATE INDEX origin_c2pa_by_version_time ON origin_c2pa_evaluations(version_id, assessed_at DESC);
-- Authorization/RLS and least-privilege grants are release gates, not provided
-- by this schema alone. DO NOT deploy this schema as a public API directly.
