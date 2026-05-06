# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Development server** (runs Rails + Tailwind CSS watcher in parallel):
```bash
bin/dev
```

**Tests:**
```bash
bin/rails test                          # unit + integration tests
bin/rails test:system                   # system tests (headless Chrome)
bin/rails db:test:prepare test test:system  # full CI test run
bin/rails test test/models/car_test.rb  # single test file
bin/rails test test/models/car_test.rb:12  # single test by line
```

**Linting and security:**
```bash
bin/rubocop                 # style linting (rubocop-rails-omakase)
bin/brakeman --no-pager     # Rails security vulnerability scan
bin/importmap audit         # JS dependency security audit
```

**Database:**
```bash
bin/rails db:migrate
bin/rails db:seed
```

## Architecture

Rails 8.0.2 app with Ruby 3.3.0 and PostgreSQL.

**Domain model:**
- `User` (Devise auth) → `has_many :cars`
- `Car` → `belongs_to :user`, `has_many :maintenance_jobs, dependent: :destroy`
- `MaintenanceJob` → `belongs_to :car`, `has_many :parts, dependent: :destroy`, `has_many_attached :receipts` (Active Storage)
- `Part` → `belongs_to :maintenance_job`

**Route structure:**
```
/cars                                          # user's cars (scoped to current_user)
/cars/:car_id/maintenance_jobs                 # nested under car
/cars/:car_id/maintenance_jobs/:id/attach_receipts   # POST
/cars/:car_id/maintenance_jobs/:id/delete_receipt    # DELETE
/maintenance_jobs/:maintenance_job_id/parts    # parts CRUD (standalone nesting)
```

**Authorization pattern:** All car/maintenance job lookups go through `current_user.cars` — scoped queries prevent cross-user access. `PartsController` does not call `authenticate_user!` and instead relies on `MaintenanceJob.find` without user scoping.

**Frontend stack:** Propshaft (no Webpack/Sprockets), importmap for JS, Tailwind CSS with a custom `primary` color palette (indigo-based, defined in `config/tailwind.config.js`). Hotwire (Turbo + Stimulus).

**Nested parts form:** The `nested_form` Stimulus controller (`app/javascript/controllers/nested_form_controller.js`) drives dynamic add/remove of Part fields in the MaintenanceJob form. It uses a `<template>` tag with `NEW_RECORD` as the placeholder index, replaced with `Date.getTime()` on add. Removing a new (unsaved) record deletes the DOM node; removing an existing record sets `_destroy=1` and hides the row.

**MaintenanceJob cost:** `total_cost` = `price` (base labor) + sum of all `parts.price`. Calculated in the model, displayed on the show page.

**Receipt uploads:** `has_many_attached :receipts` on `MaintenanceJob`. A separate `attach_receipts` action handles file uploads post-creation. The `delete_receipt` action verifies `attachment.record == @maintenance_job` before purging.

**Background services:** SolidQueue (jobs), SolidCache (cache), SolidCable (Action Cable) — all DB-backed, no Redis required in development.

**Deployment:** Kamal + Docker. Production uses AWS S3 for Active Storage.

## Testing conventions

- Framework: Minitest (not RSpec)
- System tests use Capybara + Selenium headless Chrome at 1400×1400
- `Devise::Test::IntegrationHelpers` is included globally in `ActiveSupport::TestCase` and can be used with `sign_in @user, scope: :user`
- Fixtures exist but `fixtures :all` is commented out in `test_helper.rb` — tests create records directly in `setup` blocks
- System tests run a real browser and test the Stimulus nested form interactions end-to-end

## CI pipeline (GitHub Actions)

Four jobs run on every PR and push to `main`:
1. `scan_ruby` — Brakeman
2. `scan_js` — importmap audit
3. `lint` — RuboCop
4. `test` — full test suite against a Postgres service container
