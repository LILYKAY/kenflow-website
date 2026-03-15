-- ══════════════════════════════════════════════════════════════
-- KENFLOW AI & EXECUTIVE SUPPORT — SUPABASE DATABASE SETUP
-- 1. Go to https://supabase.com → your project
-- 2. Click "SQL Editor" in the left sidebar
-- 3. Click "New Query"
-- 4. Paste this entire file → click "Run"
-- ══════════════════════════════════════════════════════════════

-- CLIENTS
CREATE TABLE IF NOT EXISTS clients (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name       TEXT,
  last_name        TEXT,
  email            TEXT UNIQUE,
  phone            TEXT,
  company          TEXT,
  role             TEXT,
  primary_interest TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- BOOKINGS
CREATE TABLE IF NOT EXISTS bookings (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id          UUID REFERENCES clients(id) ON DELETE SET NULL,
  service_type       TEXT,
  contact_preference TEXT DEFAULT 'Email',
  status             TEXT DEFAULT 'pending',
  notes              TEXT,
  created_at         TIMESTAMPTZ DEFAULT NOW()
);

-- SERVICES OFFERED
CREATE TABLE IF NOT EXISTS services_offered (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id    UUID REFERENCES clients(id) ON DELETE CASCADE,
  service_name TEXT,
  value_ksh    NUMERIC,
  status       TEXT DEFAULT 'proposed',
  notes        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- CLIENT NOTES
CREATE TABLE IF NOT EXISTS client_notes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id  UUID REFERENCES clients(id) ON DELETE CASCADE,
  content    TEXT NOT NULL,
  note_type  TEXT DEFAULT '📝 Note',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ROW LEVEL SECURITY
ALTER TABLE clients        ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings       ENABLE ROW LEVEL SECURITY;
ALTER TABLE services_offered ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_notes   ENABLE ROW LEVEL SECURITY;

-- POLICIES (clients can see their own data; inserts open for guest bookings)
CREATE POLICY "clients_own"    ON clients        FOR SELECT USING (auth.uid() = id);
CREATE POLICY "clients_update" ON clients        FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "clients_insert" ON clients        FOR INSERT WITH CHECK (true);

CREATE POLICY "bookings_own"    ON bookings       FOR SELECT USING (auth.uid() = client_id);
CREATE POLICY "bookings_insert" ON bookings       FOR INSERT WITH CHECK (true);
CREATE POLICY "bookings_update" ON bookings       FOR UPDATE USING (auth.uid() = client_id);

CREATE POLICY "services_own"    ON services_offered FOR SELECT USING (auth.uid() = client_id);
CREATE POLICY "services_insert" ON services_offered FOR INSERT WITH CHECK (true);

CREATE POLICY "notes_own"    ON client_notes FOR SELECT USING (auth.uid() = client_id);
CREATE POLICY "notes_insert" ON client_notes FOR INSERT WITH CHECK (true);

-- ══════════════════════════════════════════════════════════════
-- DONE. Your database is ready.
-- ══════════════════════════════════════════════════════════════
