/*
  # Create user credentials table

  1. New Tables
    - `user_credentials`
      - `id` (uuid, primary key)
      - `phone` (text, unique, not null)
      - `password` (text, not null)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `user_credentials` table
    - Add policy for anonymous users to insert (registration)
    - Add policy for service role full access
    - Add policy for authenticated users to read their own data

  3. Indexes
    - Index on phone for fast lookups
*/

CREATE TABLE IF NOT EXISTS user_credentials (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone text UNIQUE NOT NULL,
  password text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create index for phone lookups
CREATE INDEX IF NOT EXISTS idx_user_credentials_phone ON user_credentials (phone);

-- Enable RLS
ALTER TABLE user_credentials ENABLE ROW LEVEL SECURITY;

-- Policy for anonymous users to insert (registration)
CREATE POLICY "Allow anonymous registration"
  ON user_credentials
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Policy for service role full access
CREATE POLICY "Service role full access"
  ON user_credentials
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Policy for authenticated users to read their own data
CREATE POLICY "Users can read own credentials"
  ON user_credentials
  FOR SELECT
  TO authenticated
  USING (phone = current_setting('request.jwt.claims', true)::json->>'phone');

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_credentials_updated_at
    BEFORE UPDATE ON user_credentials
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();