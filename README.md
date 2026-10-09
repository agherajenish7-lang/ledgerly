# Ledgerly

A free-first personal finance tracker built as a static web app. GitHub Pages hosts the interface; Supabase Auth and Postgres provide sign-in and durable, account-scoped storage. The starter state contains no financial records.

## One-time setup

1. Create a free Supabase project at [supabase.com](https://supabase.com/). Choose a strong database password and keep it somewhere safe.
2. In the Supabase project, open **SQL Editor**, create a query, paste in [`supabase/schema.sql`](supabase/schema.sql), and run it. This creates the tables and owner-only Row Level Security policies. It does not insert transactions or sample financial data.
3. In **Project Settings → API**, copy the Project URL and anon/public key. Put them into `config.js` in place of the two `PASTE_...` values. The anon key is intended to be public; never put a `service_role` key in this app.
4. Create a GitHub repository named `ledgerly` and push this folder to its `main` branch. From the repository, open **Settings → Pages**, choose **GitHub Actions** as the build and deployment source. The included workflow deploys on each push. The first deployment may take a minute or two.
5. In Supabase **Authentication → URL Configuration**, set the Site URL to your GitHub Pages URL (for a user/repo repository: `https://YOUR-USERNAME.github.io/ledgerly/`). Add that URL to Redirect URLs as well. Set the same URL as the Site URL in the Supabase Auth settings before registering.
6. Open the Pages URL, create your account, and confirm your email if Supabase asks. Sign in and start adding your own entries.

## Features

- Overview: period totals, all-time net cash flow, six-month income/spending chart, category spending, and recent transactions.
- Transactions: add/edit/delete income or expense, date, description, amount, category, account/method, notes/tags, search and type filter.
- Budgets and goals: manually tracked amounts with progress.
- Recurring payments and subscriptions: manual lists; no automatic detection or bank connection.
- Reports: six-month cash flow and expense category totals.
- Settings: categories, accounts, INR currency display, transaction CSV export/import, and account data wipe.

## Data and security

All financial records live in Supabase Postgres, not browser local storage. Each table has RLS enabled with an authenticated-user policy using the caller's `auth.uid()`. Each inserted row gets its owner from `auth.uid()` on the database side. The browser only contains the Supabase URL and public anon key; RLS is the access boundary. Enable Supabase email confirmation and keep your account credentials private.

CSV import expects a header row with `date,type,description,amount,category,account,notes`. Type must be `income` or `expense`, dates should be ISO format (`YYYY-MM-DD`), and amounts must be positive. Importing the same CSV again creates duplicates; this V1 does not attempt duplicate detection.

## Local preview

Because the app uses ES modules, serve the folder from a local static server (for example VS Code Live Server) rather than opening `index.html` as a `file://` URL. First fill in `config.js` and run the SQL schema in Supabase.

## Cost and limits

The project is designed to use GitHub Pages and Supabase free tiers. Free-tier limits and availability are controlled by those providers and can change. Supabase pauses inactive free projects; check its dashboard periodically and keep CSV exports as backups.
