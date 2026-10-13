LOW-LEVEL  
DESIGN DOCUMENT

Family Details Collection Mobile Application

Offline data capture • Household/member hierarchy • Local filtering and reporting


|  |
| --- |


Document type  Low-Level Design (LLD)

Version  1.0

Prepared on  10 October 2026

Recommended platform  Flutter (Dart) + SQLite

Connectivity model  Local-first / offline; no server required

Purpose

Provide an implementation-ready technical design for registering families and their members, storing all data locally on a mobile device, and filtering or summarizing records by gender, age, and ration-card category.


## Document control


| Item | Description |
| --- | --- |
| Status | Proposed design for implementation |
| Audience | Product owner, mobile developer, tester, field data-collection team |
| Target for first release | Android phones; architecture can support iOS later |
| Data ownership | Data remains on the phone unless an authorized user explicitly exports it |
| Design principle | Offline-first, privacy-aware, simple field entry, recoverable local data |



## Contents

1. Purpose and scope

2. Functional requirements

3. Recommended technology and rationale

4. Architecture and component design

5. Data model and database schema

6. Screens and user workflows

7. Filtering and data processing

8. Validation and business rules

9. Privacy, security, backup and recovery

10. Non-functional requirements

11. Error handling and edge cases

12. Testing strategy and acceptance criteria

13. Implementation plan

14. Assumptions and decisions to confirm


| Important boundary This design assumes a single-device application with no automatic server sync. The database and exports are local to the device. Moving data between devices requires an explicit, protected backup/export and import flow. |
| --- |



## 1. Purpose and scope

The application will collect household-level information and person-level information. A household (family) contains exactly one designated head of family and zero or more additional members. Each person is linked to one household. The app must remain usable in locations without internet connectivity.


### 1.1 In scope

- Create, view, edit, and archive family records.

- Register one head of family and add all other family members under the same family record.

- Capture household details: house name, house number, address, contact phone, ration-card type, well ownership, and house type.

- Capture person details: name, date of birth, gender, relationship to head, and optional personal phone number.

- Search families and people; filter people by gender, age range, and ration-card type.

- Show derived age, family size, member lists, counts, and simple summaries.

- Export selected/all records to a file and restore from a validated backup.

- Support English and Malayalam labels; preserve Malayalam Unicode text.


### 1.2 Out of scope for version 1

- Cloud accounts, multi-device synchronization, remote sharing, or centralized reporting.

- Government identity-number capture, document/photo storage, biometric data, or GPS collection.

- Automatic verification against official ration-card or civil-registration databases.

- Multi-user permission management across devices.


## 2. Functional requirements


| ID | Requirement | Priority |
| --- | --- | --- |
| FR-01 | Create a household with a unique internal ID and required household details. | Must |
| FR-02 | Register a single head-of-family person for each household. | Must |
| FR-03 | Add, edit, and view additional members within a household. | Must |
| FR-04 | Capture name, DOB, gender, relationship, and optional person-level phone. | Must |
| FR-05 | Capture ration-card type once at household level. | Must |
| FR-06 | Search by family/house name, house number, person name, or phone. | Must |
| FR-07 | Filter people by gender, calculated age/range, and household ration-card type. | Must |
| FR-08 | Display household profile and all linked members. | Must |
| FR-09 | Show counts such as households, people, gender, age bands, card categories, and well ownership. | Should |
| FR-10 | Export selected/all data and import a validated backup. | Should |
| FR-11 | Support Malayalam and English UI text and data entry. | Should |
| FR-12 | Protect access with an app PIN/biometric lock; encrypt backups. | Should |



## 3. Recommended technology and rationale


| Layer | Recommendation | Rationale |
| --- | --- | --- |
| Language/UI | Flutter with Dart | Single codebase, strong form/layout support, suitable for Android-first and potential iOS support. |
| Local storage | SQLite via sqflite, or Drift over SQLite | Relational tables and joins fit the household-to-member relationship; SQL provides dependable filtering. |
| State management | Riverpod | Keeps forms, search, filters, and repository state organized and testable. |
| Navigation | go_router or Flutter Navigator | Simple routes for household list, profile, member form, reports, settings. |
| Date/locale | intl | Date formatting and locale support; age calculations remain deterministic. |
| File export | csv plus path_provider/share_plus | Produces portable CSV files and invokes the phone's share sheet when requested. |
| Backup encryption | Encrypted archive using a maintained, reviewed cryptography package | Helps protect data when a backup leaves the app sandbox. |
| Optional app lock | local_auth and a PIN fallback | Adds access friction on shared or field-worker devices. |



| Technology decision Use Flutter/Dart + SQLite for a structured offline app. Use SQLCipher-backed SQLite (or another maintained encrypted SQLite integration) if database-at-rest encryption is required. Verify package maintenance, platform compatibility, and key-storage design before committing to a specific encryption plugin. Standard SQLite alone does not encrypt the database. |
| --- |



### 3.1 Why not store everything in a single JSON file?

A single JSON file is easy to start with but becomes harder to update safely, filter efficiently, and keep relationally consistent as the number of households grows. SQLite supports transactions, indexes, constraints, and joins while remaining fully local. The database should be the source of truth; CSV is an export format, not the primary store.


## 4. Architecture and component design

Presentation (Flutter screens/widgets)

|

v

State / ViewModels (Riverpod providers + form state)

|

v

Domain services (validation, age calculation, filters, summaries)

|

v

Repositories (HouseholdRepository, MemberRepository, ExportRepository)

|

v

SQLite database (local device storage)

|

+-- Encrypted backup/export files (created only on user action)


### 4.1 Component responsibilities


| Component | Responsibilities |
| --- | --- |
| Household screens | List, search, create, edit, archive, and open family profiles. |
| Member screens | Add/edit people, choose relationship, validate DOB/gender, assign head/member role. |
| Filter controller | Maintain selected gender, age minimum/maximum, card type, and reset/apply state. |
| Domain services | Calculate age from DOB, validate single head, build report aggregates, normalize search input. |
| Repositories | Own SQL statements, transactions, pagination, mapping between database rows and typed Dart models. |
| Database manager | Create/migrate schema, enable foreign keys, create indexes, execute transactions. |
| Export/import service | Generate export file, encrypt backup, validate import, detect duplicates/conflicts, report outcome. |
| Settings | Language, app lock, backup location/workflow, master-list values, and data-management actions. |



### 4.2 Suggested project structure

lib/

app/        # routes, theme, localization

core/       # constants, date/age helpers, errors

data/       # SQLite, migrations, models, repositories

export/     # CSV, encrypted backup and import

domain/     # validation, filters, age/report services

features/   # households, members, filters, reports, settings

l10n/       # English and Malayalam translations


## 5. Data model and database schema


### 5.1 Entity relationship

Relationship: HOUSEHOLD (one) to MEMBER (many). Each member has a required household_id foreign key. A completed household must contain exactly one member marked is_head = 1; that person has relationship_to_head = “Head”. Shared home and ration-card attributes belong to HOUSEHOLD; personal details belong to MEMBER.


### 5.2 Household table


| Field | Type | Required | Rules / meaning |
| --- | --- | --- | --- |
| household_id | TEXT UUID | Yes | Primary key generated on device. |
| house_name | TEXT | Yes | House name; trim leading/trailing spaces. |
| house_number | TEXT | Recommended | Text, not numeric; supports values such as 12/A. |
| address_line | TEXT | Yes | Full/local address. Optional subfields can be added if needed. |
| locality | TEXT | No | Ward, locality, or place. |
| post_office | TEXT | No | Optional. |
| pincode | TEXT | No | Text to preserve leading zeroes; validate format when provided. |
| contact_phone | TEXT | No | Household contact phone; store as text. |
| ration_card_type | TEXT enum | Yes | Configured category; see master values below. |
| has_own_well | INTEGER 0/1 | Yes | 1 = yes; 0 = no. If unknown must be supported, add a third state explicitly. |
| house_type | TEXT enum | Yes | Tiled/odu, concrete/terrace, sheet, other, unknown. |
| notes | TEXT | No | Optional non-sensitive field; avoid unnecessary personal notes. |
| created_at | TEXT ISO-8601 | Yes | UTC timestamp. |
| updated_at | TEXT ISO-8601 | Yes | UTC timestamp updated on every edit. |
| record_status | TEXT enum | Yes | draft or complete; complete only after a head is registered. |
| is_archived | INTEGER 0/1 | Yes | Soft archive; default 0. |



### 5.3 Member table


| Field | Type | Required | Rules / meaning |
| --- | --- | --- | --- |
| member_id | TEXT UUID | Yes | Primary key generated on device. |
| household_id | TEXT UUID | Yes | Foreign key to household; ON DELETE RESTRICT by default. |
| full_name | TEXT | Yes | Trimmed display name; preserve local-language text. |
| date_of_birth | TEXT YYYY-MM-DD | Yes* | Use date-only format; *allow unknown only if business owner agrees. |
| gender | TEXT enum | Yes | Female, Male, Other, Prefer not to say, Unknown (configurable). |
| relationship_to_head | TEXT enum/text | Yes | Head, Spouse, Son, Daughter, Parent, Sibling, Grandparent, Other. |
| is_head | INTEGER 0/1 | Yes | Exactly one row with 1 per complete household. |
| person_phone | TEXT | No | Optional individual phone; do not require if household contact is sufficient. |
| created_at | TEXT ISO-8601 | Yes | UTC timestamp. |
| updated_at | TEXT ISO-8601 | Yes | UTC timestamp updated on every edit. |
| is_archived | INTEGER 0/1 | Yes | Optional member archive; use carefully to maintain household integrity. |



| Modeling decision Ration-card type, house type, well ownership, and main contact are household-level attributes. Gender, date of birth, name, and relationship are person-level attributes. This enables correct person filters through each person’s linked household without duplicating household data. |
| --- |



### 5.4 Configurable master values


| Attribute | Suggested initial values | Notes |
| --- | --- | --- |
| Ration-card type | Yellow, Pink, Blue, White, Other, Unknown | Confirm the required labels and official categories with the data owner. Keep values configurable rather than hardcoding local policy. |
| House type | Odu / tiled roof, concrete / terrace, sheet roof, other, unknown | Use local terms as a displayed label; store a stable code. |
| Gender | Female, Male, Other, Prefer not to say, Unknown | Confirm whether the data collection program needs these exact choices. |
| Relationship | Head, spouse, son, daughter, father, mother, sibling, grandparent, in-law, other | A dropdown with an optional relationship note can support local household structures. |



### 5.5 SQLite DDL

PRAGMA foreign_keys = ON;

CREATE TABLE household (

household_id TEXT PRIMARY KEY,

house_name TEXT NOT NULL,

house_number TEXT,

address_line TEXT NOT NULL,

locality TEXT,

post_office TEXT,

pincode TEXT,

contact_phone TEXT,

ration_card_type TEXT NOT NULL,

has_own_well INTEGER NOT NULL CHECK (has_own_well IN (0, 1)),

house_type TEXT NOT NULL,

notes TEXT,

created_at TEXT NOT NULL,

updated_at TEXT NOT NULL,

record_status TEXT NOT NULL DEFAULT 'draft' CHECK (record_status IN ('draft', 'complete')),

is_archived INTEGER NOT NULL DEFAULT 0 CHECK (is_archived IN (0, 1))

);

CREATE TABLE member (

member_id TEXT PRIMARY KEY,

household_id TEXT NOT NULL REFERENCES household(household_id)

ON UPDATE CASCADE ON DELETE RESTRICT,

full_name TEXT NOT NULL,

date_of_birth TEXT NOT NULL, -- ISO date: YYYY-MM-DD

gender TEXT NOT NULL,

relationship_to_head TEXT NOT NULL,

is_head INTEGER NOT NULL DEFAULT 0 CHECK (is_head IN (0, 1)),

person_phone TEXT,

created_at TEXT NOT NULL,

updated_at TEXT NOT NULL,

is_archived INTEGER NOT NULL DEFAULT 0 CHECK (is_archived IN (0, 1))

);

CREATE UNIQUE INDEX ux_member_one_head_per_household

ON member(household_id) WHERE is_head = 1;

CREATE INDEX ix_household_card ON household(ration_card_type, is_archived);

CREATE INDEX ix_member_household ON member(household_id, is_archived);

CREATE INDEX ix_member_gender ON member(gender, is_archived);

CREATE INDEX ix_member_dob ON member(date_of_birth, is_archived);

CREATE INDEX ix_household_house_number ON household(house_number);

Implementation note: the unique partial index prevents two heads, but it does not by itself guarantee every household has a head. Create the household and initial head in one database transaction and mark a household as complete only after that transaction succeeds. The household record_status should move from draft to complete in the same transaction that registers the head. A household with no active head should be treated as an incomplete draft and excluded from final reports by default.


## 6. Screens and user workflows


| Screen | Main controls / content | Actions |
| --- | --- | --- |
| Home / dashboard | Household count, people count, recent records, quick actions. | Add household, search, open reports. |
| Household list | Search box, family/house name, house number, contact phone, member count. | Open, edit, archive, add new. |
| Add household | House name/number, address, contact phone, ration card type, well, house type. | Save draft, continue to head registration. |
| Add/edit person | Name, DOB picker, gender, relation, optional personal phone, head indicator. | Save, cancel, add another member. |
| Household profile | Household attributes, head summary, member list, family size. | Add member, edit details, archive household. |
| Filter people | Gender, age range, card type; optional locality/house type/well filters. | Apply, reset, view matching people, export results. |
| Reports | Counts by gender, age bands, card type, house type, well ownership. | Refresh, export summary. |
| Settings & data | Language, app lock, backup/export/import, master labels, delete-data controls. | Create/restore backup, manage app settings. |



### 6.1 Create household workflow

1. Tap “Add Household”.

2. Enter house name, optional house number, address, contact phone, ration-card type, well ownership, and house type.

3. Tap “Add Head of Family”; enter the primary person’s details. Relationship is automatically set to “Head” and the head flag to true.

4. Save household and head in a single transaction. If validation or database write fails, roll back and show an actionable error.

5. Open the household profile and add other members, setting each relationship relative to the head.


### 6.2 Add/edit member workflow

1. Open a household profile and tap “Add Member”.

2. Enter required name, date of birth, gender, relationship to head, and optional phone.

3. Validate date, required fields, and phone format where provided.

4. Save with household_id from the profile. Disallow adding another head through the normal member form.

5. After saving, refresh the household profile and any active filtered result counts.


### 6.3 Delete and archive behavior

Prefer archive instead of destructive delete for normal field operations. Archived records are hidden from default counts/search but remain recoverable by an authorized user. A permanent-delete function, if included, must clearly warn that the record cannot be recovered and must handle the household/member relationship safely.


## 7. Filtering and data processing


### 7.1 Filter behavior

- Gender: single or multi-select; default All.

- Age: minimum and maximum age, with inclusive boundaries. Age is calculated from DOB at query time, not stored, so it updates as birthdays pass.

- Ration-card type: single or multi-select; evaluated through the household linked to each member.

- Combined filters: criteria use AND semantics across filter dimensions; selections within one dimension use OR semantics.

- Reset: clears all filter selections.

- Result behavior: show matching people, their family/house name, house number, card type, calculated age, gender, and relationship. Provide a tap-through to the full household profile.


### 7.2 Age calculation rules

Store DOB as YYYY-MM-DD with no time component. Calculate completed age using the device’s local calendar date. Before a birthday in the current year, subtract one from the year difference. Reject future DOBs. If the program permits unknown DOB, those records should be excluded from age-range filters by default and shown under an “Age unknown” indicator.

age = today.year - dob.year

if (today.month, today.day) < (dob.month, dob.day):

age -= 1


### 7.3 Example SQL for filters

-- Members matching gender and household card type.

-- Age bounds should be converted into date boundaries in Dart.

SELECT m.member_id, m.full_name, m.date_of_birth, m.gender,

m.relationship_to_head, h.house_name, h.house_number,

h.ration_card_type

FROM member m

JOIN household h ON h.household_id = m.household_id

WHERE m.is_archived = 0

AND h.is_archived = 0

AND (:gender IS NULL OR m.gender = :gender)

AND (:card_type IS NULL OR h.ration_card_type = :card_type)

AND m.date_of_birth >= :earliest_allowed_dob

AND m.date_of_birth <= :latest_allowed_dob

ORDER BY m.full_name COLLATE NOCASE;

Age date boundaries must be calculated carefully in Dart and bound as parameters; do not concatenate user input into SQL. For an inclusive age range [minAge, maxAge] on a reference date, the latest allowed DOB is the date the person born on it reaches minAge; the earliest allowed DOB is the day after the person would reach maxAge + 1. Test leap-day birthdays with an explicit, documented policy. If either age bound is omitted, omit that corresponding SQL predicate.


### 7.4 Reports and summaries


| Report | Calculation |
| --- | --- |
| Total households | Count of non-archived households with completed head registration. |
| Total people | Count of non-archived members belonging to non-archived households. |
| Gender distribution | People count grouped by gender. |
| Age-band distribution | People grouped into configurable bands, for example 0–5, 6–17, 18–59, 60+. |
| Ration-card distribution | Household count and person count grouped by card type. |
| Well ownership | Household count grouped by has-own-well. |
| House type distribution | Household count grouped by house type. |



## 8. Validation and business rules


| Rule ID | Rule | Handling |
| --- | --- | --- |
| BR-01 | Each completed household has exactly one head. | Enforce one-head unique index and transaction-based creation; verify before completing/importing. |
| BR-02 | Head’s relationship is “Head”. | Set automatically; do not allow another relationship while is_head=true. |
| BR-03 | Every non-head member has a relationship to the head. | Required dropdown; “Other” may enable a short note if added to schema. |
| BR-04 | DOB cannot be in the future. | Show inline error; block save. |
| BR-05 | Household required fields are present. | Validate house name, address, ration-card type, well answer, and house type. |
| BR-06 | Phone numbers are stored as text. | Preserve country prefix/leading zeroes; validate only when non-empty. Allow a local format policy. |
| BR-07 | House number remains text. | Support characters, slash, dash, and leading zeroes. |
| BR-08 | No duplicate record prevention based only on name. | Warn about possible duplicates using name + house number/phone; let user decide. |
| BR-09 | Archived records are excluded from default outputs. | Apply the archive condition consistently to lists, filters, and reports. |
| BR-10 | Import cannot silently overwrite records. | Preview counts and conflicts; require explicit merge/replace choice and backup first. |



## 9. Privacy, security, backup and recovery


| Privacy requirement Family records contain personal data, including children’s dates of birth and contact details. Collect only fields needed for the stated purpose, restrict device access, and establish who is authorized to view or export records. |
| --- |



### 9.1 Local storage and device security

- Keep the database inside the application’s private storage directory; do not place the live database in a public Downloads folder.

- Use OS app sandboxing and optionally require app PIN/biometric unlock. A biometric lock is a convenience control, not a replacement for database encryption.

- If physical extraction or loss of the phone is in scope, use an encrypted SQLite solution with a key protected by Android Keystore/iOS Keychain. Avoid hardcoding encryption keys.

- Exclude sensitive database files from unencrypted operating-system/cloud backups unless the data owner explicitly approves that behavior. Check Android/iOS backup settings.

- Do not log names, phone numbers, addresses, DOBs, or export contents in debug/production logs.

- Use a short automatic lock timeout if field workers may share devices; provide a clear app-lock recovery process that does not expose stored data.


### 9.2 Backup and restore design

1. User taps “Create Backup”.

2. App creates a consistent database snapshot or serializes a versioned export in a read transaction.

3. Encrypt the backup using a user-provided passphrase or a securely managed key; do not rely on renaming a CSV as protection.

4. Save/share the encrypted backup only after the user confirms the destination.

5. On import, verify format version, integrity, encryption, and required fields before changing the database.

6. Show a preview of household/member counts and potential conflicts. Restore transactionally; roll back on any failure.

CSV export is useful for analysis but is not a complete or confidential backup by itself. Clearly warn that a plain CSV can be read by other apps once shared. Offer field selection and filtered export to reduce unnecessary disclosure.


### 9.3 Data retention and consent

The organization collecting these records should define the lawful purpose, notice/consent or other applicable basis, authorized users, retention period, correction process, and secure deletion procedure before deployment. The app should not collect government ID numbers or extra sensitive fields unless explicitly approved and necessary.


## 10. Non-functional requirements


| Area | Target / design requirement |
| --- | --- |
| Offline behavior | All create/read/update/search/filter/report features work without internet. |
| Performance | Target common list/filter operations under 1 second for up to 10,000 members on the supported reference device; benchmark on real target hardware. |
| Data integrity | Use transactions for multi-table writes and database constraints for foreign keys and unique head enforcement. |
| Durability | Successful writes remain after app close/restart and phone reboot, subject to normal device/storage failure. |
| Usability | Large tap targets, clear validation, few fields per screen, search, save confirmation, and safe unsaved-change handling. |
| Localization | English and Malayalam UI strings; support Unicode names/addresses and appropriate text rendering. |
| Accessibility | Readable font size, semantic labels, sufficient contrast, and no color-only meaning. |
| Maintainability | Repository/service separation, schema migrations, automated tests, stable enum codes. |
| Portability | Backup format versioned so records can be moved between app versions and, where supported, Android/iOS. |



## 11. Error handling and edge cases


| Scenario | Expected behavior |
| --- | --- |
| App closed during save | Transaction either completes or rolls back; no half-created household/head. |
| Duplicate head attempted | Block save; explain that one head already exists. |
| Member moved to another household | Not part of standard workflow in v1; if later supported, validate old/new household head integrity. |
| Unknown DOB | Allow only if owner approves; omit from age filters and label unknown. |
| Household has no head | Keep as incomplete draft; exclude from finalized reports. |
| Database migration fails | Do not overwrite original data; show recovery guidance and ask for a backup before retry where possible. |
| Insufficient storage | Show clear error, do not report success, retain existing records. |
| Malformed backup | Reject before import; leave current database unchanged. |
| Name has Malayalam characters | Save/search/display without ASCII-only conversion or destructive normalization. |
| Age boundary / leap-day DOB | Verify against calendar-based completed-age rules in unit tests. |
| Ration card category changed | Edit household once; all linked member filter results use the updated household category. |



## 12. Testing strategy and acceptance criteria


### 12.1 Test layers


| Test type | Coverage |
| --- | --- |
| Unit tests | Age calculation, DOB boundary/leap day, validators, search normalization, filter predicate building, report aggregation. |
| Repository/database tests | CRUD, foreign keys, one-head rule, transactions, indexes, archive semantics, migrations, import rollback. |
| Widget tests | Household form validation, member form, filter panel, empty/loading/error states, language labels. |
| Integration tests | Create household + head + additional members; restart app; run filters; export and re-import backup. |
| Device tests | Airplane mode, low storage, app killed mid-save, device reboot, different screen sizes, Malayalam input, app lock. |



### 12.2 Release acceptance checklist

- ☐  A user can create a family and exactly one head of family.

- ☐  A user can add, edit, and view multiple members under that family.

- ☐  Household and member details survive force-close and device restart.

- ☐  Filters return correct people for gender, inclusive age range, and card type individually and in combination.

- ☐  Age shown in the UI is calculated from DOB and current local date.

- ☐  Search finds a household by house name/number and a person by name or phone.

- ☐  App works with no internet connection.

- ☐  Backup/export actions clearly explain data exposure and import does not silently overwrite records.

- ☐  Malayalam and English data entry/search work correctly.

- ☐  No sensitive personal data is printed to logs.


## 13. Implementation plan


| Phase | Deliverables | Exit criteria |
| --- | --- | --- |
| 1. Confirm requirements | Approved fields, language, card types, house types, age bands, consent/privacy policy. | Data dictionary and validation rules signed off. |
| 2. Foundation | Flutter project, theme/localization, app navigation, SQLite setup and schema migration. | App starts offline; schema created and migrated. |
| 3. Household/member capture | Forms, validation, relationship dropdown, household profile, transactional save. | Create/edit family and member flows pass tests. |
| 4. Search and filters | Search, gender/age/card filters, list result and family drill-down. | Filter tests pass for combinations and boundaries. |
| 5. Reports and export | Dashboard counts, CSV export, encrypted backup/restore. | Exports match UI results; invalid import safely rejected. |
| 6. Hardening and release | App lock, storage security, device QA, performance tests, user instructions. | Acceptance checklist passed; backup/restore tested. |



## 14. Assumptions and decisions to confirm


| Question | Proposed default |
| --- | --- |
| Primary platform? | Android first; Flutter keeps iOS as a later option. |
| Will multiple phones need to share data? | No automatic sync in v1. Use encrypted export/import when needed. |
| Can DOB be unknown? | Required by default; allow unknown only if field teams confirm it is needed. |
| Which ration-card types? | Configurable master list; confirm local labels/categories before release. |
| What do “Odu” and “terrace” mean in the field? | Offer local display labels (e.g., tiled roof and concrete/terrace) and verify with data collectors. |
| Can one household have multiple phone numbers? | One household contact phone plus optional per-member phone; add more contacts only if required. |
| Should archived records appear in reports? | No, not by default. Provide a separate authorized archived-record view. |
| Is app/database encryption mandatory? | Recommended for personal data; confirm requirements and test the selected encrypted SQLite implementation. |
| How many records are expected? | Design for 10,000 members as an initial performance target; confirm expected maximum. |



## Appendix A. Key design decisions at a glance


| Decision | Selected design |
| --- | --- |
| Mobile framework | Flutter / Dart |
| Local database | SQLite, preferably encrypted at rest for production |
| Record hierarchy | One household to many members; exactly one head per completed household |
| Ration card / house / well | Household-level attributes |
| DOB / gender / relationship | Member-level attributes |
| Age filtering | Calculated from DOB, not persisted |
| Offline requirement | Core functionality has no network dependency |
| Data movement | Explicit user initiated export/import with encryption for backups |
| Default deletion | Archive first; permanent delete only after confirmation |



| Implementation recommendation Build the database and household/member save flow first. This is the foundation for reliable filters and reports. Confirm the local ration-card categories, whether DOB can be unknown, the exact house-type choices, and whether devices need to exchange records before implementation begins. |
| --- |
