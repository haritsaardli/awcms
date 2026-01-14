
-- Migration: Allow Public Read for Pongo Tables
-- Date: 2026-01-14
-- Description: Adds RLS policies to allow public read access to published content.

-- Services
CREATE POLICY "Public Read Published Services" ON public.services FOR SELECT USING (status = 'published');

-- Teams
CREATE POLICY "Public Read Published Teams" ON public.teams FOR SELECT USING (status = 'published');

-- Partners
CREATE POLICY "Public Read Published Partners" ON public.partners FOR SELECT USING (status = 'published');

-- Funfacts
CREATE POLICY "Public Read Published Funfacts" ON public.funfacts FOR SELECT USING (status = 'published');
