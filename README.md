# Thiago de Joaldo — site institucional

Site estático (HTML + JS puro) com painel de conteúdo integrado ao Supabase.
As chaves do Supabase não ficam no código: são lidas em runtime por uma
function serverless (`api/config.js`) a partir de variáveis de ambiente.

## Estrutura

```
index.html               página única (site + painel da equipe)
api/config.js             serverless function da Vercel — expõe SUPABASE_URL, SUPABASE_ANON_KEY e RECAPTCHA_SITE_KEY
api/recaptcha-verify.js   serverless function — valida o token do reCAPTCHA com o Google (usa RECAPTCHA_SECRET_KEY)
schema.sql                tabelas + RLS para rodar no SQL Editor do Supabase
.env.example              modelo das variáveis de ambiente necessárias
```

## 1. Criar o projeto no Supabase

1. Crie um projeto novo em [supabase.com](https://supabase.com), região **South America (São Paulo)**.
2. Abra o **SQL Editor** e rode o conteúdo de `schema.sql`.
3. Em **Authentication > Users**, crie o usuário (e-mail + senha) que a equipe vai usar para logar no painel do site.
4. Em **Project Settings > API**, copie a **Project URL** e a chave **anon public**.

## 2. Subir para o GitHub

```bash
# dentro desta pasta
git remote add origin git@github.com:SEU-USUARIO/SEU-REPO.git
git push -u origin main
```

O `.env` nunca é versionado (já está no `.gitignore`) — só o `.env.example` vai para o repositório.

## 3. Deploy na Vercel

1. Importe o repositório em [vercel.com/new](https://vercel.com/new).
2. Em **Environment Variables**, adicione:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   (os mesmos valores copiados no passo 1.4)
3. Deploy. A Vercel detecta `index.html` na raiz e `api/config.js` automaticamente — não é preciso configurar build command.

## Desenvolvimento local

Para testar a função `/api/config` localmente (necessário para o painel funcionar fora da Vercel):

```bash
npm i -g vercel
cp .env.example .env   # preencha com suas chaves reais
vercel dev
```

Sem isso, abrir o `index.html` direto no navegador funciona apenas como demonstração visual (dados de exemplo, sem login real).

## Área da equipe

Acesse `/#admin` no site publicado (ou clique em "Área da equipe" no rodapé) para abrir o painel de conteúdo e logar com o usuário criado no passo 1.3.

## 4. reCAPTCHA no login (opcional)

O login já está pronto para usar o reCAPTCHA v2 ("Não sou um robô"). Enquanto as chaves abaixo não forem configuradas, ele simplesmente não aparece — nenhuma mudança de código é necessária para ligar depois.

1. Crie um site em [google.com/recaptcha/admin](https://www.google.com/recaptcha/admin), tipo **reCAPTCHA v2 — "Não sou um robô"**, com o domínio do site publicado (e `localhost` se for testar local).
2. Copie a **Site key** e a **Secret key**.
3. Na Vercel, em **Environment Variables**, adicione:
   - `RECAPTCHA_SITE_KEY`
   - `RECAPTCHA_SECRET_KEY`
4. Faça um novo deploy (ou redeploy) — o widget passa a aparecer na tela de login automaticamente.
