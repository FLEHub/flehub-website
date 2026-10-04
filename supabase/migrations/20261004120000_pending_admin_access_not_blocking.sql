-- TEMPORAIRE : validation admin non bloquante le temps de stabiliser le flux email.
-- Revenir à un blocage strict (status = 'active' uniquement) une fois la
-- confirmation d'email validée en production (le lien arrive, et le compte
-- passe de pending_email_confirmation à pending_admin_validation).
--
-- Ne change pas le trigger on_auth_user_email_confirmed : après confirmation
-- de l'email, le profil reste en pending_admin_validation. Seul le contrôle
-- d'accès (cours, examens, fichiers) traite ce statut comme actif.
-- rejected, suspended et pending_email_confirmation restent exclus.

CREATE OR REPLACE FUNCTION public.is_active_account()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
      AND status IN ('active', 'pending_admin_validation')
  );
$$;

REVOKE ALL ON FUNCTION public.is_active_account() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_active_account() TO authenticated;
