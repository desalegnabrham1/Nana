const { createClient } = require('@supabase/supabase-js');

// Initialize Supabase client
const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error('❌ Error: Supabase configuration missing!');
    console.error('Please make sure VITE_SUPABASE_URL and VITE_SUPABASE_SERVICE_ROLE_KEY are set in your .env file');
    console.error('Make sure you are using the SERVICE ROLE key, not the anon key!');
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: {
        autoRefreshToken: false,
        persistSession: false
    }
});

module.exports = supabase;