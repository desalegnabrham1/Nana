/*
  # Create users table

  1. New Tables
    - `users`
      - `id` (uuid, primary key)
      - `phone` (text, unique, not null)
      - `password` (text, not null)
      - `name` (text, optional)
      - `telegram_id` (bigint, optional)
      - `created_at` (timestamp with time zone)
      - `updated_at` (timestamp with time zone)

  2. Security
    - Enable RLS on `users` table
    - Add policy for anonymous users to insert (register)
    - Add policy for service role full access
    - Add policy for authenticated users to read their own data

  3. Performance
    - Add index on phone for fast lookups
    - Add trigger for auto-updating updated_at timestamp
*/

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone text UNIQUE NOT NULL,
  password text NOT NULL,
  name text,
  telegram_id bigint,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create index for phone lookups
CREATE INDEX IF NOT EXISTS idx_users_phone ON users (phone);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow anonymous registration"
  ON users
  FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Service role full access"
  ON users
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can read own data"
  ON users
  FOR SELECT
  TO authenticated
  USING (phone = ((current_setting('request.jwt.claims'::text, true))::json ->> 'phone'::text));

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();