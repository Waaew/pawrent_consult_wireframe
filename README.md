# Pawrent Consult — Flutter Hi-Fi Wireframe

Hi-fidelity Flutter prototype for the **Consult** feature of the Pawrent pet super-app. Built from the spec at https://pawrent-app.netlify.app/.

## What's covered

The Consult vertical slice from Phase 1:

| Screen | File |
| --- | --- |
| Consult Board feed (search, sort, category filter) | [lib/screens/consult_board_screen.dart](lib/screens/consult_board_screen.dart) |
| Question Detail (with answers, voting, accept solution) | [lib/screens/question_detail_screen.dart](lib/screens/question_detail_screen.dart) |
| Post Question | [lib/screens/post_question_screen.dart](lib/screens/post_question_screen.dart) |
| Vet Answer composer (with template insertion) | [lib/screens/vet_answer_screen.dart](lib/screens/vet_answer_screen.dart) |
| Bottom-tab app shell with placeholders for other 4 tabs | [lib/main.dart](lib/main.dart) |

## Design system

- Custom theme: lavender primary, teal accent, warm surface — see [lib/theme/app_theme.dart](lib/theme/app_theme.dart)
- Inter typography via `google_fonts`
- Material 3, light mode
- Reusable widgets: avatars with role badges, category pills, question/answer cards — see [lib/widgets/](lib/widgets/)

## Mock data

Pre-seeded with realistic Thai/English pet-care Q&A across all categories (Health, Nutrition, Behavior, Grooming, Emergency, Other), including:

- A verified vet **accepted answer** flow
- A **brand-sponsored** Royal Canin answer card
- An **urgent** question with priority badge
- A **vet-suggested clinic visit** callout with Telemet CTA

See [lib/data/mock_data.dart](lib/data/mock_data.dart).

## Run

Requires Flutter 3.19+. Install: https://docs.flutter.dev/get-started/install

```bash
cd ~/pawrent_consult_wireframe
flutter pub get
flutter run
```

To pick a device: `flutter devices` then `flutter run -d <id>`.

## Try the flows

1. **Browse** — open the app, you land on Consult. Filter by category, sort, search.
2. **Detail view** — tap a question card. Try upvoting an answer, or tap "Accept as solution".
3. **Ask** — tap the **Ask** FAB. Pick a category, fill title/body, attach photos, optionally mark urgent. Submit returns to feed with a success toast.
4. **Answer as vet** — from a question detail, tap **Answer as Vet**. Try the **Template** button to insert a triage skeleton, toggle "Suggest in-clinic visit", submit — the answer appears at the top of the thread.

## Not yet wired

This is a wireframe — out of scope for this pass:

- Real auth, network calls, or persistence (state lives in `setState`)
- Vet queue / dashboard view
- Notification center
- Brand admin tools
- i18n switcher (strings are mixed Thai/English to match the spec)

## Next likely additions

- Vet queue screen (filter by specialty, unanswered/flagged)
- Notification center for "Vet answered your question"
- Pet picker as a reusable bottom sheet
- Hook Consult card into Telemet booking flow (Phase 2B)
