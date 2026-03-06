
-- Create admin_users table
CREATE TABLE public.admin_users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL UNIQUE,
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- Only admins can read admin_users
CREATE POLICY "Admins can view admin list"
ON public.admin_users
FOR SELECT
TO authenticated
USING (auth.uid() IN (SELECT user_id FROM public.admin_users));

-- Security definer function to check admin
CREATE OR REPLACE FUNCTION public.is_admin(_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_users WHERE user_id = _user_id
  )
$$;

-- Allow admins to read all inscriptions
DROP POLICY IF EXISTS "Authenticated can view farmer registrations" ON public.inscriptions_agriculteurs;
CREATE POLICY "Admins can view farmer registrations"
ON public.inscriptions_agriculteurs
FOR SELECT
TO authenticated
USING (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Authenticated can view investor registrations" ON public.inscriptions_investisseurs;
CREATE POLICY "Admins can view investor registrations"
ON public.inscriptions_investisseurs
FOR SELECT
TO authenticated
USING (public.is_admin(auth.uid()));
