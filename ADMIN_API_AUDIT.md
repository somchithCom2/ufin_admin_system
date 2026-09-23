# Admin API and UI audit

Reviewed on 2026-09-23 against the local `../workspace/ufin-back-end` checkout. Changes span that Spring Boot repository and this Flutter repository. This is a source-code and automated-test review; it is not certification of the deployed service or all production workflows.

## Implemented fixes

| Area | Problem found | Result |
| --- | --- | --- |
| Plans | Create button was a placeholder | Shared create/edit form calls the real admin API |
| Plan translations | UI sent strings; backend required locale maps | Typed locale maps; existing translations are retained and editable |
| Plan prices | Editing rounded decimal prices; free-plan creation failed validation | Decimal prices retained; zero allowed; negative/overprecision values rejected |
| Plan limits | Blank fields could not reset a limit | Explicit JSON null clears a limit; omitted fields preserve it |
| Plan status | API returns empty success but app tried to parse a plan | Activation/deactivation accepts and validates the actual response |
| Plan details | Admin detail loaded the public plan endpoint | Uses the admin endpoint and its complete DTO |
| Pagination | Spring page number/size/last flag ignored | Spring Page, PagedModel and custom page DTOs supported, including full final pages |
| Search races | Old responses could replace a new search or append old rows | Generation checks on shop, user, subscription and payment list loads |
| Users | Type filters used unsupported enum values and were ignored | `CLIENT`/`STAFF` filters are applied in the database alongside status and search |
| User deletion | UI sent the nonexistent `deleted` status | Protected `DELETE /admin/users/{id}` soft-deletes and revokes device sessions |
| User restoration | Deleted timestamp absent; reused contacts could collide | DTO includes deletedAt; restore checks active username/email/phone collisions |
| User security | Suspension/password reset retained existing sessions | Session deletion participates in the mutation transaction; destructive ADMIN-account changes rejected |
| Payments | Rows expected paymentDate instead of paidAt | paidAt supported, createdAt fallback for unpaid rows, invoice reference supported |
| Payment filters | Server ignored date/method filters; individual filters could not be cleared | SQL filtering, inclusive selected end date, and independent filter clearing |
| Manual payments | Invalid numbers could throw; reference/notes silently discarded | Validated form with submission guard and retained errors; transactionId and persistent notes |
| Revenue | Backend supplied only total; UI expected counts and incompatible list shapes | SQL aggregates supply counts, daily totals, plan/method breakdowns; UI supports day/week/month |
| Expiring subscriptions | Wrong expiry field and localized-name parsing | Reads expiresAt and locale maps |
| Subscription lifecycle | Create/cancel/reactivate existed only in repository code | Management screens connected to the existing APIs |
| Cancellation | Wrong request key; immediate cancellation retained auto-renewal | Uses immediateEffect; both cancellation modes disable renewal; trial history retained |
| Reactivation | Old trial/pricing/currency data and incorrect history | Resets state, validates active plan, uses correct price/currency/previous plan; lifetime handling corrected |
| Subscription detail | Refresh searched only the first subscription page | Fetches the specific shop subscription directly |
| Limits display | Zero and unlimited were conflated | Null means unlimited; zero remains a zero limit |
| App releases | Filtered platform lists stayed stale after changes | Invalidate both complete and platform lists after mutations |
| Debug logging | Tokens, passwords and response bodies were printed | HTTP logging retains method/path/status without headers or payloads |

## API contract notes

- `POST /admin/plans`: name/description are locale maps; prices are nonnegative decimal values with at most two decimal places.
- `PUT /admin/plans/{id}`: omitted limits remain unchanged; explicitly supplied null means unlimited. An empty description map and empty badge clear those values.
- `DELETE /admin/users/{id}`: soft deletion only. Existing `SYSTEM_ADMINISTRATION` permission enforcement applies. ADMIN accounts are protected from deletion/deactivation through these management actions.
- `GET /admin/users`: supports status, search and userType. `status=deleted` selects deleted accounts; other queries exclude deleted accounts.
- `GET /admin/payments`: supports status, shopId, paymentMethod, startDate inclusive, endDate exclusive. The Flutter app converts an inclusive selected end day to next-day midnight.
- AdminService page requests require page >= 0 and size 1–200, with stable date/id ordering.
- Subscription creation sends planCode, billingCycle, startAsTrial and notes. Trial duration comes from the selected plan.
- Cancellation sends reason, immediateEffect and notes. Reactivation requires billingCycle.
- Subscription management changes access; it does not itself insert a manual payment ledger entry.
- The revenue report is explicitly LAK. It includes completed payments as revenue, counts failed/refunded transactions separately, and excludes the following day's midnight. Plan breakdowns use the subscription's **current** plan, not a historical plan snapshot.

## Deployment requirements

1. Apply backend Flyway migration `V75__add_subscription_payment_notes.sql` through the normal deployment process. It adds a nullable notes column; no production migration was executed in this task.
2. Deploy the backend before this admin UI. The UI depends on the new user-delete endpoint, filter support, note persistence and explicit-null plan updates.
3. Run the checklist below against a staging database with representative data and admin/non-admin accounts before publishing.

## Automated verification

- Flutter: `flutter test --no-pub` passed 27 tests and covers contract parsing, full last pages, empty pages, error envelopes, translated plan edits, free-plan creation, validation failures, payment dates, revenue grouping, lifecycle forms, stale requests and filter clearing.
- Backend: `./gradlew test --tests 'com.ufin.pos.admin.*' --tests 'com.ufin.pos.user.service.UserServiceTest' --tests 'com.ufin.pos.subscription.controller.SubscriptionTenantIsolationTest' --offline --console=plain` passed 47 tests with no failures/skips.
- Revenue SQL is executed against H2 in PostgreSQL compatibility mode, including date-boundary, currency and status cases. This does not replace a PostgreSQL migration/query-plan check.
- Release JavaScript web build succeeded (`flutter build web --no-pub`). The optional Wasm dry run reports incompatibility in the existing flutter_secure_storage_web dependency; this build uses JavaScript.
- Flutter analyzer is checked with `--no-fatal-infos`; existing informational lints remain in older screens. No warnings/errors are accepted for this verification.

## Staging verification checklist

- Create a free plan, edit Lao/English/Thai text, preserve fractional prices, set a finite limit, then clear it to unlimited. Reload each time.
- Activate/deactivate a plan; verify public availability and admin detail agree.
- Search/filter users, load beyond page one, clear filters, and rapidly change search criteria. Confirm no repeated or stale rows.
- Delete a CLIENT account, verify its token is rejected, restore it, and confirm it reappears. Try protected ADMIN changes and reused-contact restoration.
- Reset a password or suspend an account; confirm all existing device sessions are rejected.
- Create a subscription with/without a trial; cancel immediately and at period end; reactivate on a different plan. Verify dates, renewal flags and history.
- Record a decimal payment with transaction reference and notes; reload and filter by method/date/status. Verify an end-day 23:59:59 payment is included and next-day midnight is excluded.
- Compare LAK report totals and counts with payment ledger rows; verify failed/refunded payments and USD entries are not added to completed LAK revenue.
- Mutate an app release while a platform filter is selected; verify that list refreshes.
- Exercise API mutations with non-admin credentials and expect denial. Check on-device session expiry and browser refresh behavior.

## Remaining gaps and production follow-up

The existing admin system is **not fully complete in every domain**. The following remain outside these fixes:

1. **Profile/product editing:** admin user/shop APIs primarily support status and lifecycle management; they do not expose general profile editing. The admin product endpoint is read-only. Dedicated privileged update contracts, field rules and UI forms are needed if admins should edit those records. Tenant employee APIs should not be used to impersonate shop staff.
2. **Payment idempotency and audit history:** submission guards prevent duplicate taps in the form, but server-side idempotency keys and an immutable actor/before/after audit trail are still needed for reliable retries and full accountability. Existing payment status mutations do not enforce a business-specific transition matrix.
3. **Historical reporting:** payment rows do not snapshot the purchased plan. Changing a shop's plan changes the current-plan attribution of old payments. Add historical plan references before presenting this as historical plan revenue. Other dashboard/statistics sums still need a currency policy if multiple currencies are used.
4. **Concurrency:** plans and subscriptions need an explicit concurrent-edit strategy (version checks/locking where appropriate). Restore checks reject existing contact conflicts, but race-proof uniqueness should also be enforced at the database boundary.
5. **Query scaling:** DTO conversion still performs per-row shop/employee/product/subscription lookups in several admin lists. Batch/projection queries and PostgreSQL EXPLAIN measurements are needed before claiming large-data performance. Date-filter aggregation would benefit from a measured index on the payment reporting timestamp expression.
6. **Error contracts and operations:** many existing controller methods map broad exceptions to HTTP 400. Standardized 400/403/404/409/500 handling, durable audit records, and authorization tests covering every admin controller remain worthwhile backend work.
7. **Deployment coverage:** no production API writes, production database migration, device tests, load tests, or full browser-to-live-backend workflow were performed.
