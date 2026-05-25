// resources/js/utils/supabase.js

export const SUPABASE_LOGO =
    "https://dwyfjwwgrtdspgdaifyv.supabase.co/storage/v1/object/public/logo/new_logo.png";

const SUPABASE_URL    = "https://dwyfjwwgrtdspgdaifyv.supabase.co";
const SUPABASE_BUCKET = "aegis";

/**
 * Converts a relative Supabase storage path to a full public URL.
 * Returns null when path is falsy.
 */
export function getFotoUrl(path) {
    if (!path) return null;
    return `${SUPABASE_URL}/storage/v1/object/public/${SUPABASE_BUCKET}/${path}`;
}