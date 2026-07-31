-- ============================================================
-- Schema do site — rode este arquivo no SQL Editor do Supabase
-- (projeto criado na região South America / São Paulo).
--
-- Leitura é pública (o site é público). Escrita só é permitida
-- para usuários autenticados — é essa política de RLS que protege
-- os dados, não o sigilo da chave anon usada no front-end.
-- ============================================================

create table if not exists config (
  chave text primary key,
  valor text
);

create table if not exists atalhos (
  id bigint generated always as identity primary key,
  ordem int default 0,
  cor text default 'laranja',
  icone text default 'link',
  titulo text not null,
  subtitulo text,
  url text
);

create table if not exists cidades (
  id bigint generated always as identity primary key,
  ordem int default 0,
  nome text not null
);

create table if not exists noticias (
  id bigint generated always as identity primary key,
  titulo text not null,
  descricao text,
  imagem_url text,
  cidade text,
  destaque boolean default false,
  link_url text,
  criado_em timestamptz not null default now()
);

create table if not exists checagens (
  id bigint generated always as identity primary key,
  boato text not null,
  realidade text not null,
  fonte_url text,
  data date not null default current_date
);

create table if not exists bastidores (
  id bigint generated always as identity primary key,
  titulo text not null,
  descricao text,
  image_url text,
  iframe_url text,
  instagram_embed text,
  link_externo text
);

create table if not exists galeria (
  id bigint generated always as identity primary key,
  ordem int default 0,
  imagem_url text not null,
  legenda text
);

create table if not exists promessas (
  id bigint generated always as identity primary key,
  ordem int default 0,
  titulo text not null,
  descricao text,
  fonte_url text
);

-- ============================================================
-- RLS: leitura pública, escrita apenas para usuários autenticados
-- ============================================================
alter table config      enable row level security;
alter table atalhos     enable row level security;
alter table cidades     enable row level security;
alter table noticias    enable row level security;
alter table checagens   enable row level security;
alter table bastidores  enable row level security;
alter table galeria     enable row level security;
alter table promessas   enable row level security;

do $$
declare
  t text;
begin
  foreach t in array array['config','atalhos','cidades','noticias','checagens','bastidores','galeria','promessas']
  loop
    execute format('create policy "leitura publica" on %I for select using (true);', t);
    execute format('create policy "escrita autenticada" on %I for insert with check (auth.role() = ''authenticated'');', t);
    execute format('create policy "atualizacao autenticada" on %I for update using (auth.role() = ''authenticated'') with check (auth.role() = ''authenticated'');', t);
    execute format('create policy "exclusao autenticada" on %I for delete using (auth.role() = ''authenticated'');', t);
  end loop;
end $$;

-- ============================================================
-- STORAGE: bucket público "midia" para as fotos enviadas pelo painel
-- (matérias, bastidores, galeria, foto do topo e logo). O painel já
-- converte tudo para WebP no navegador antes de enviar.
-- Mesma regra das tabelas: leitura pública, escrita autenticada.
-- ============================================================
insert into storage.buckets (id, name, public)
values ('midia', 'midia', true)
on conflict (id) do nothing;

create policy "midia leitura publica" on storage.objects
  for select using (bucket_id = 'midia');
create policy "midia escrita autenticada" on storage.objects
  for insert with check (bucket_id = 'midia' and auth.role() = 'authenticated');
create policy "midia atualizacao autenticada" on storage.objects
  for update using (bucket_id = 'midia' and auth.role() = 'authenticated')
  with check (bucket_id = 'midia' and auth.role() = 'authenticated');
create policy "midia exclusao autenticada" on storage.objects
  for delete using (bucket_id = 'midia' and auth.role() = 'authenticated');

-- Se o bloco acima der erro de permissão ao rodar pelo SQL Editor,
-- crie o bucket manualmente: Storage > New bucket > nome "midia",
-- marque "Public bucket" e rode só os quatro CREATE POLICY acima.

-- ============================================================
-- Depois de rodar este schema, crie o usuário da equipe em
-- Authentication > Users no painel do Supabase (e-mail + senha).
-- Esse será o login usado na "Área da equipe" do site.
-- ============================================================
