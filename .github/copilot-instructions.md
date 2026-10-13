# Family Details Collection App — Copilot Instructions

- Treat `docs/family-details-collection-lld.md` as the primary source of truth for product requirements and technical design.
- Build an offline-first mobile application using Flutter and Dart, with SQLite as the on-device database.
- Normal application functionality must work without internet. Do not add a backend, cloud database, analytics upload, or automatic data sync unless explicitly requested.
- Model each household/family separately from its members. Every member belongs to one household; a household has one designated head of family. Represent the head/member relationship consistently and enforce the rule in application/database logic.
- Support household data, member data, relationship to head of family, date of birth, gender, ration-card type, phone number, house name/number, address, well ownership, and house type as defined in the LLD.
- Implement filters for gender, age/range, and ration-card type using the LLD's rules. Calculate age from date of birth at query time or use correct DOB boundaries; do not store a fixed age value.
- Use a maintainable feature-based structure with separation between UI, application/state logic, data repositories, and database access. Keep widgets small and business logic testable.
- Add database migrations, input validation, error handling, and automated tests for family/member CRUD, household-head integrity, filters, and backup/restore.
- Protect personal data: collect only required fields, avoid logging names/phone numbers/addresses, and do not send records to external services. Follow the LLD's security and backup decisions.
- Use clear labels and accessible forms. Keep the UI ready for English and Malayalam localization; do not hard-code user-facing strings throughout widgets.
- Before making large changes, inspect the repository and propose a short plan. Implement in small, reviewable stages, run formatting and tests, and summarize changed files and any decisions needing confirmation.
- Do not silently alter requirements or invent business rules. If a requirement is ambiguous, document the assumption and ask for confirmation before making an irreversible design choice.
