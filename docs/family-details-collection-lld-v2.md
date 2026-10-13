# Low-Level Design Document — Family Details Collection Mobile Application

**Version:** 2.0  
**Status:** Proposed design — pending confirmation of open decisions  
**Prepared:** 12 October 2026  
**Platform:** Flutter/Dart + Drift/SQLite  
**Connectivity:** Offline-first; no server required

> Version 2 extends the v1 LLD. It preserves the household/member structure, updates ration-card categories to BPL/APL/AAY, and adds general, medical, marriage, pregnancy, child, relationship, and family-planning data. This document is a design proposal, not medical guidance.

## 1. Purpose and scope

Version 2 extends the existing offline-first Family Details Collection app. It preserves the household-to-member hierarchy and existing family fields, changes ration-card categories to BPL/APL/AAY, and adds general, medical, marriage, pregnancy, child-birth, family-relationship, and pregnancy-prevention fields.

The app remains Android-first, built with Flutter/Dart, Riverpod, go_router, and Drift over SQLite. Normal capture, search, filtering, and reporting must work without internet access. No backend or automatic synchronization is introduced.

### In scope

- Household registration and one head of family per completed household.
- Member details and relationships, including spouse and mother-child links.
- General information: Aadhaar number, education, job, abroad status, blood group.
- Health information: existing illness multi-select and conditional Other text; cancer, asthma, heart disease.
- Marriage and conditional special-care/counselling fields.
- Pregnancy details and calculated trimester for pregnant members.
- Child birth details for children below five, with additional special-care details for children below one.
- Temporary/permanent pregnancy-prevention plan and method/date/remarks.
- Filters, summaries, local export, encrypted backup/restore, English and Malayalam UI.

### Out of scope unless separately approved

- Government Aadhaar verification or retrieval.
- Clinical diagnosis, medical advice, due-date prediction, or replacement of a health professional.
- Cloud storage, remote reporting, or automatic sync.
- Automatic import from hospital or government systems.

## 2. Changes from v1

| Area | Version 2 change |
|---|---|
| Ration card | Replace v1 suggested colour categories with BPL, APL, AAY. Store stable codes BPL/APL/AAY. |
| General member data | Add Aadhaar number, education, job, is-abroad, blood group. |
| Health | Add existing illness multi-select: Diabetic, Blood Pressure, Cholesterol, Other; conditional other text; cancer, asthma, heart disease. |
| Marriage | Add married flag and conditional marriage date, special-care-required flag/details, and pre-marriage counselling received. |
| Pregnancy | Add pregnant flag and conditional ABA ID, last menses date, consulting hospital, previous pregnancy count, previous child birth date when applicable, and trimester derived from last menses date. |
| Child details | For age under 5: birth weight, birth time, delivery type. For age under 1: also special-care flag/details. |
| Relationships | Add explicit spouse and mother-child relationship links, beyond relationship-to-head. |
| Pregnancy prevention | Add planning-to-stop-pregnancy flag/plan type (temporary/permanent), temporary method/date/remarks, or permanent procedure/date/remarks. |

## 3. Recommended technology and architecture

| Layer | Recommendation |
|---|---|
| UI / language | Flutter + Dart |
| State | Riverpod |
| Navigation | go_router |
| Local database | Drift over SQLite with migrations and foreign keys |
| Dates / localization | intl; English and Malayalam labels |
| Export | CSV only on explicit user action; warn that CSV is unencrypted |
| Backup | Versioned encrypted backup with integrity validation |
| Security | Review Aadhaar and health data threat model; prefer encrypted database at rest, OS-protected key, app lock, no sensitive logs |

Use feature modules: households, members, relationships, health, marriage, pregnancy, child details, family planning, filters/reports, backup/settings. Keep conditional-field validation in domain services and all multi-table writes transactional.

## 4. Data model

### 4.1 Household (existing, revised)

| Field | Type / rule |
|---|---|
| household_id | UUID text primary key |
| house_name | Required text |
| house_number | Optional text; preserve values like 12/A |
| address_line | Required text; locality/post office/pincode optional |
| contact_phone | Optional text |
| ration_card_type | Required enum: BPL, APL, AAY |
| has_own_well | Required yes/no; add unknown state if collection process needs it |
| house_type | Stable code with localized label, e.g. ODU/TILED, CONCRETE/TERRACE, SHEET, OTHER, UNKNOWN |
| timestamps/status | created_at, updated_at, draft/complete, is_archived |

### 4.2 Member (core person table)

| Field | Type / rule |
|---|---|
| member_id | UUID text primary key |
| household_id | Required FK to household |
| full_name | Required text |
| date_of_birth | Required date-only YYYY-MM-DD; no future dates |
| gender | Configured enum |
| relationship_to_head | Required stable code/text |
| is_head | Boolean; one active head per completed household |
| person_phone | Optional text |
| aadhaar_number | Optional encrypted-at-rest text; validate format/checksum only if a validated library/rule is selected; never log or show full number by default |
| education_level | Optional configured code; include OTHER + text if required |
| job_title | Optional text or configured job category |
| is_abroad | Boolean/unknown if needed |
| blood_group | Optional enum: A+, A-, B+, B-, AB+, AB-, O+, O-; include Unknown/Not provided as UI choice, not clinical inference |
| created_at/updated_at/archive | Standard audit fields |

### 4.3 Health details (one-to-one with member)

| Field | Type / rule |
|---|---|
| member_id | Primary key and FK to member |
| existing_illnesses | Normalized rows in member_illness; multi-select codes DIABETIC, BLOOD_PRESSURE, CHOLESTEROL, OTHER |
| other_illness_text | Required only when OTHER selected; do not store free text otherwise |
| has_cancer | Yes/No/Unknown if permitted |
| has_asthma | Yes/No/Unknown if permitted |
| has_heart_disease | Yes/No/Unknown if permitted |
| updated_at | Timestamp |

Use a member_illness table (member_id, illness_code, other_text) rather than a comma-separated list. Add a uniqueness constraint on (member_id, illness_code). This makes multi-select filtering and future additions reliable.

### 4.4 Marriage details (conditional)

| Field | Type / rule |
|---|---|
| member_id | Primary key and FK to member |
| is_married | Yes/No/Unknown if the collection process needs it |
| marriage_date | Required when married = Yes if known; confirm whether unknown date is allowed |
| special_care_required | Yes/No; visible when married = Yes per current request |
| special_care_details | Required when special_care_required = Yes |
| premarital_counselling_received | Yes/No/Not applicable/Unknown; confirm desired options |

### 4.5 Pregnancy details (conditional and time-sensitive)

| Field | Type / rule |
|---|---|
| pregnancy_id | UUID primary key |
| mother_member_id | FK to member |
| aba_id | Text; confirm the official identifier name, format, and whether it is mandatory |
| last_menses_date | Date; required to calculate trimester if available |
| consulting_hospital | Text; avoid unnecessary hospital details |
| previous_pregnancy_count | Non-negative integer; clarify whether this means previous pregnancies excluding current pregnancy |
| last_child_birth_date | Optional date; show when prior child exists / count > 0 |
| is_current | Boolean/status; allows a history of pregnancies if needed |
| created_at/updated_at | Timestamps |

Do not store trimester as a permanent value. Derive gestational age from last menstrual period (LMP) and the current local date, and display an estimated trimester: first trimester before 14 weeks, second trimester from 14 weeks to before 28 weeks, third trimester from 28 weeks onward. This is an approximate administrative calculation, not a clinical determination. If LMP is missing, in the future, or produces an implausible result, show “Unable to calculate” and request professional confirmation. Confirm trimester thresholds with the responsible health program before release.

### 4.6 Child birth details (age-derived form)

| Field | Type / rule |
|---|---|
| member_id | Primary key and FK to child member |
| birth_weight_kg | Decimal; validate a reasonable configured range and allow unknown if approved |
| birth_time | Optional local time; confirm whether time is required |
| delivery_type | Enum: NORMAL/VAGINAL, CAESAREAN; use neutral labels and confirm preferred local wording |
| special_care_required | Yes/No; only required for children under 1 per request |
| special_care_details | Required when special care = Yes and age under 1 |
| updated_at | Timestamp |

Show birth details for members whose calculated age is under five. For members under one, show the same fields plus special-care fields. Age is calculated from DOB each time the form is opened; do not persist age or delete child details automatically when the child ages out of the threshold.

### 4.7 Pregnancy-prevention / family-planning record

| Field | Type / rule |
|---|---|
| family_planning_id | UUID primary key |
| member_id | FK to member; confirm whether this should instead link to a couple/household |
| plan_status | Yes/No/Not decided/Unknown; user wording needs clarification |
| plan_type | TEMPORARY or PERMANENT when planning = Yes |
| temporary_method | CU-T, PPIUCD, PAIUCD; confirm exact official labels/expansions and spelling |
| action_date | Date of method/procedure; label differs by method |
| remarks | Optional text; limit access and avoid unnecessary sensitive details |
| created_at/updated_at | Timestamps |

For TEMPORARY, require method and date; remarks optional. For PERMANENT, require date and allow remarks. Keep this as a separate record rather than putting all fields on the member row, so updates/history can be handled safely. Clarify whether “planning to stop pregnancy?” means intention to avoid future pregnancy, current contraceptive use, or a completed procedure.

## 5. Relationship design: mother-child and husband-wife

Keep relationship_to_head for display, but add a separate member_relationship table for explicit links between two people. This is needed because two people can be spouses even if one is not the head, and a child must link to a specific mother rather than merely to the household.

| Field | Type / rule |
|---|---|
| relationship_id | UUID primary key |
| from_member_id | FK to member |
| to_member_id | FK to member |
| relationship_type | MOTHER_OF, CHILD_OF, SPOUSE_OF; use one canonical direction or enforce symmetric spouse links consistently |
| valid_from | Optional date |
| valid_to | Optional date for relationship end if needed |
| notes | Optional, avoid unnecessary sensitive notes |

- A member can have at most one active mother link unless the business rules explicitly allow otherwise.
- A spouse link must connect two distinct members; if both members belong to different households, require explicit approval and ensure both households are in the same local dataset.
- For each pregnancy, mother_member_id must match the member with the pregnancy record; optionally link a child after birth through MOTHER_OF/CHILD_OF.
- Do not infer parent/spouse relationships solely from age, gender, or relationship-to-head.
- Deleting or archiving a person must not silently delete linked relationships or pregnancy records; show the user the impact and use archive-first behavior.

## 6. Screens and workflows

| Screen | Key behavior |
|---|---|
| Dashboard | Household/person counts; sensitive health counts only if explicitly needed and authorized. |
| Household list/profile | Existing v1 household capture and linked members; card choices BPL/APL/AAY. |
| Member basic details | Name, DOB, gender, relationship-to-head, phone, Aadhaar, education, job, abroad, blood group. |
| Health details | Illness multi-select; conditional Other text; cancer, asthma, heart disease. |
| Marriage details | Married toggle; conditionally reveal marriage date, special care/details, premarital counselling. |
| Pregnancy details | Pregnant toggle; ABA ID, LMP, hospital, previous pregnancy count, last child birth date; derived trimester preview. |
| Child details | Age-based section under 5; under 1 includes special-care question/details. |
| Relationships | Select existing member to link mother/child or spouse; prevent self-links and duplicates. |
| Family planning | Plan status; temporary/permanent branches; method/date/remarks. |
| People search/filters | Gender, age, BPL/APL/AAY, education, job, abroad, blood group, illness flags where authorized. |
| Reports/export | Aggregates and filtered exports; show warning before exporting sensitive health/Aadhaar fields. |
| Settings/data protection | App lock, database security status, encrypted backup/restore, access and retention guidance. |

### Suggested form sequence

1. Create household and head; save as draft until required household/head data is valid.
2. Capture basic member details and save.
3. Capture optional general, health, marriage, pregnancy, child, and family-planning sections; use conditional sections and save drafts safely.
4. Link spouse and mother/child records using an existing member picker.
5. Review a summary page for missing conditional fields before marking the member complete.

## 7. Filtering and processing

- Existing filters remain: gender, inclusive age range, ration-card type BPL/APL/AAY.
- Additional filters can include education, job, abroad status, blood group, selected illness, cancer, asthma, heart disease, married, currently pregnant, and child-age bands. Treat health/reproductive filters as restricted views and include only if there is a defined operational need.
- Use AND across filter dimensions and OR within a multi-select dimension; provide Apply and Reset.
- Filter by current pregnancy status from active pregnancy records, not merely a stale boolean on the member row.
- Age and child thresholds are calculated from DOB and current local date. Test birthday boundaries and leap-day behavior.
- Trim search text but preserve Malayalam Unicode; use parameterized SQL only.
- Default reports exclude archived records and incomplete drafts. Health/reproductive report totals should be opt-in and role/access controlled even in a single-device app.

### Trimester calculation

Approximate gestational age in days = current date − LMP date. Gestational weeks = floor(days / 7). If weeks < 14, show first trimester; if 14 ≤ weeks < 28, second trimester; if weeks ≥ 28, third trimester. Display the estimated weeks and “approximate—confirm with consulting health professional.” Do not calculate if LMP is absent or after today. The program owner must approve this rule before production use.

## 8. Validation and business rules

- Ration card is exactly one of BPL, APL, AAY for complete households; do not silently map old colour categories. Existing v1 records need a reviewed migration/mapping screen because colour categories may not map unambiguously to the new categories.
- Aadhaar is optional unless the program owner explicitly approves it as required. Store as text to preserve formatting; mask on screen; never include it in default CSV export, logs, analytics, or error messages.
- If illness OTHER is selected, other_illness_text is required; otherwise clear or preserve it according to a documented edit policy.
- If married = No, hide marriage-only fields and do not treat missing marriage details as errors.
- If special_care_required = Yes, require details.
- If pregnant = Yes, require fields according to the approved policy. At minimum, trimester calculation requires LMP. Decide whether ABA ID and hospital may be unknown.
- If previous_pregnancy_count > 0, show last child birth date; do not assume it must be the last pregnancy outcome unless clarified.
- Child birth fields show based on age under five; special-care details show for age under one only. Never erase saved data just because the child crosses an age threshold.
- Temporary family-planning type requires a method and date; permanent requires date; remarks optional.
- Reject future DOB, LMP, marriage date, child birth date, and procedure/method dates where logically invalid. Use configurable validation for historical exceptions.
- Use database transactions for member plus conditionally related records; rollback all related writes if any validation or database operation fails.
- Use archive-first behavior and explicit confirmation for deletion or relationship changes.

## 9. Privacy and security

Version 2 introduces highly sensitive identifiers and health/reproductive data, including Aadhaar, pregnancy, illness, marriage, and child information. Treat this as a release-level security change, not a routine form update.

- Before collecting real data, document the purpose, legal basis/notice/consent as applicable, authorized users, retention period, correction process, and deletion process with the responsible organization.
- Strongly recommend encrypted database-at-rest (e.g. a maintained SQLCipher integration) with keys protected by Android Keystore/iOS Keychain; validate package maintenance and recovery design before selection.
- Use an app PIN/biometric lock with a safe recovery policy. A biometric prompt alone does not encrypt SQLite.
- Mask Aadhaar by default and require explicit confirmation to reveal it. Do not use Aadhaar as the primary key or a member lookup key.
- Do not log any Aadhaar, DOB, phone, address, illness, pregnancy, counselling, or family-planning values.
- Default export omits Aadhaar and health/reproductive fields. Require explicit field selection and a warning for any sensitive export.
- Encrypted backup must use authenticated encryption, a versioned format, integrity checks, preview, and transactional restore. Do not store the backup password in the app.
- Check Android backup configuration so private database files are not copied to unapproved cloud backups.
- Keep app offline and do not add analytics, crash payloads, network calls, or sync that can transmit personal data.

### Implemented backup/export format

- The current encrypted backup envelope is format version 1 and contains a schema-versioned JSON snapshot. It uses PBKDF2-HMAC-SHA-256 (310,000 iterations, 16-byte random salt) to derive a 256-bit key and AES-256-GCM with a 12-byte random nonce and 16-byte authentication tag. The format identifier and version are authenticated as additional data.
- The current reader accepts the current database schema version only. When a database schema change is introduced, add a validated backup-snapshot migration before accepting older snapshots.
- Restore previews household/member counts and ID conflicts. Merge keeps local records on ID conflict, skips dependent details for conflicting member IDs, and reports skipped rows. Replace requires a second confirmation and restores in one SQLite transaction.
- CSV export starts with active households and active members, allows selecting households or exporting the current filtered member-search results, and allows selecting fields. It omits Aadhaar and health/reproductive fields by default. Selecting any sensitive field requires a separate warning confirmation. CSV is unencrypted; sharing is initiated only by the user.
- Android automatic backup is disabled for the application. On iOS, the app marks the documents and application-support directories excluded from device backups and stores newly written database keys with a ThisDeviceOnly Keychain accessibility class.

## 10. Migration from v1 to v2

1. Increment the database schema version and implement a tested Drift migration; create new health, marriage, pregnancy, child-detail, relationship, and family-planning tables.
2. Add new member columns/tables without deleting existing records. New optional fields remain null/unknown until collected.
3. Replace ration-card choices in the UI with BPL/APL/AAY. Do not auto-map old Yellow/Pink/Blue/White/Other/Unknown categories to BPL/APL/AAY unless the data owner provides an explicit mapping. Show unmapped households in a migration review flow.
4. Preserve household/member IDs and all existing relationships-to-head. Generate new relationship links only when explicitly captured; never infer spouse/mother-child links automatically.
5. Back up the existing database before migration and test both successful migration and rollback/failure behavior.
6. Provide a migration report: households retained, members retained, records needing ration-card review, and any invalid data requiring correction.

## 11. Testing and acceptance criteria

- Household card options are exactly BPL/APL/AAY and filters return the correct linked people.
- Migration preserves all v1 household/member records and flags unmapped old card categories for review.
- Member general details save/reload correctly, including masked Aadhaar handling.
- Illness multi-select persists across restart; Other requires text; deselecting Other follows the documented cleanup policy.
- Marriage fields and validation respond correctly to married Yes/No.
- Pregnancy fields appear only when pregnant; trimester boundaries at 13w6d, 14w0d, 27w6d, and 28w0d are tested.
- Missing/future LMP shows unable-to-calculate rather than an invented trimester.
- Mother-child and spouse relationships prevent self-linking, duplicates, invalid references, and accidental cascade deletion.
- Child fields follow age thresholds (<1 and <5) without losing saved data as age changes.
- Temporary/permanent family-planning branches enforce their required method/date rules.
- Sensitive values never appear in logs; default export excludes Aadhaar and health/reproductive fields.
- Backup encryption, wrong-password handling, tampered backup rejection, merge/replace preview, and rollback are tested.
- All normal workflows work in airplane mode; English/Malayalam Unicode data is preserved.

## 12. Implementation plan

| Phase | Deliverables | Exit criteria |
|---|---|---|
| 1. Requirements confirmation | Approve data dictionary, field requiredness, enum choices, relation semantics, trimester policy, and privacy rules. | Open questions resolved and signed off. |
| 2. Schema/migration | Drift schema, v1→v2 migration, indexes, new related tables, migration report. | Existing data preserved; migration and rollback tests pass. |
| 3. Core member details | Aadhaar, education, job, abroad, blood group; UI masking and validation. | Member data persists offline and is protected. |
| 4. Health and marriage | Illness multi-select, Other text, disease flags, married and conditional fields. | Conditional form and repository tests pass. |
| 5. Pregnancy and child | Pregnancy records, LMP-derived trimester, child birth details and age-based UI. | Boundary and data-retention tests pass. |
| 6. Relationships and family planning | Spouse/mother-child links; temporary/permanent prevention records. | Relationship integrity and conditional validation tests pass. |
| 7. Filters/reports | BPL/APL/AAY, new filters, sensitive-view rules and aggregates. | Results match test fixtures. |
| 8. Security/export/release | Encrypted database decision, app lock, safe export, encrypted backup, device QA. | Security review and acceptance checklist pass. |

### Recommended build order

Do not implement all new fields in one large Copilot request. First review and approve the schema and migration, then implement one feature group at a time with tests. Because the new fields include Aadhaar and reproductive/medical information, do not use real household records during development.

## 13. Open decisions requiring confirmation

| Question | Recommended default / action |
|---|---|
| Aadhaar required? | Optional by default; mask it and exclude from default exports. Confirm necessity and access rules before collecting. |
| Education values | Confirm exact dropdown values and whether “Other” requires free text. |
| Job values | Free text for v2 simplest; optionally add configured occupation categories later. |
| Is Abroad | Clarify whether this means currently abroad, ever worked abroad, or household member currently living abroad. |
| Illness answers | For cancer/asthma/heart disease, decide whether Yes/No/Unknown is needed; recommend Yes/No/Unknown rather than forcing a guess. |
| Marriage date | Decide whether unknown date is allowed when married = Yes. |
| Special care | Clarify whether the marriage special-care question is intended only for married members or all members. |
| ABA ID | Confirm exact official name, format, and whether mandatory. |
| Pregnancy count | Clarify whether this means previous pregnancies excluding current pregnancy, and how pregnancy losses are counted. |
| Last child birth date | Clarify whether this means most recent live birth or last pregnancy outcome. |
| Trimester | Approve LMP-based approximate boundaries and required health-program guidance. |
| Delivery terminology | Confirm whether to display “Normal/Caesarean” or more neutral “Vaginal/Caesarean” labels. |
| CU-T / PPIUCD / PAIUCD | Confirm official spelling/expansions and which date is captured (insertion, procedure, or counselling date). |
| Family planning meaning | Clarify whether the question asks intention, current method use, or completed permanent procedure. |
| Relationship scope | Can spouses belong to different household records? Can a child have a mother in another household record? |
| Ration-card migration | Provide an explicit mapping from old v1 categories or require manual review; never infer mapping. |

## Appendix A. Suggested stable codes

| Domain | Codes |
|---|---|
| Ration card | BPL, APL, AAY |
| Illness | DIABETIC, BLOOD_PRESSURE, CHOLESTEROL, OTHER |
| Blood group | A_POS, A_NEG, B_POS, B_NEG, AB_POS, AB_NEG, O_POS, O_NEG, UNKNOWN |
| Delivery | VAGINAL, CAESAREAN, UNKNOWN |
| Family planning | TEMPORARY, PERMANENT |
| Temporary method | CU_T, PPIUCD, PAIUCD |
| Relationships | SPOUSE_OF, MOTHER_OF, CHILD_OF |

## Appendix B. Copilot implementation prompt

Use this prompt after adding this document to docs/family-details-collection-lld-v2.md and updating .github/copilot-instructions.md.

> Read `docs/family-details-collection-lld-v2.md` and compare it with the existing v1 implementation. Do not code yet. First inspect the current Drift schema and migrations, identify every v1→v2 schema change, flag any breaking changes or unresolved decisions, and propose a migration plan with tests. Never auto-map old ration-card categories to BPL/APL/AAY. Treat Aadhaar, health, pregnancy, counselling, and family-planning data as sensitive: do not log or export these fields by default. Wait for approval before changing files.
