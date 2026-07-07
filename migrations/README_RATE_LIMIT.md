# Захист від 429 на Supabase

## Проблема

Supabase `fmdnrxvylmbirkzrmvhz` отримує 429 (rate limit). Найімовірніша причина —
**сканери GitHub знаходять anon key у публічному репо і б'ють на
`/auth/v1/signup`**, вичерпуючи ліміт 30 signups/год на IP. Це блокує
легітимних користувачів.

## Що вже зроблено в коді (commit)

1. **`lib/core/utils/debouncer.dart`** — універсальний Debouncer, блокує
   повторні submit на 2 секунди. Захищає від випадкових подвійних кліків
   і зменшує кількість запитів з одного користувача.
2. **`lib/features/auth/presentation/auth_page.dart`** — debounce на submit,
   generic error messages (без розкриття чи існує email), розпізнавання 429
   і показ зрозумілого повідомлення.
3. **`lib/l10n/app_uk.arb`** — додані `errorTooManyRequests` і `errorGeneric`.
4. **`migrations/supabase_rate_limit.sql`** — готовий SQL для обмеження
   writes на `profiles` (20/год на IP).

## Що зробити в Supabase Dashboard (5 хвилин)

### A. Увімкнути CAPTCHA — це зупинить 90% атак

1. https://supabase.com/dashboard/project/fmdnrxvylmbirkzrmvhz/auth/providers
2. Розділ **Security → Bot Protection**
3. Увімкнути **hCaptcha** (безкоштовно) або **Cloudflare Turnstile**
4. Для hCaptcha потрібно:
   - Зареєструватись на https://www.hcaptcha.com/
   - Отримати site key + secret key
   - Вставити обидва у Supabase Dashboard
5. Готово. Усі signup/signin запити тепер вимагають CAPTCHA.

### B. Перевірити Auth Logs (діагностика)

1. https://supabase.com/dashboard/project/fmdnrxvylmbirkzrmvhz/logs/auth
2. Фільтр: `event_type = signup OR token_refresh`
3. Якщо бачите десятки `signup` з різних IP/країн за годину — це бот.
4. Якщо тільки ваш IP і нормальна кількість — проблема клієнтська, і debounce
   у коді має вирішити її.

### C. Обмежити RLS на profiles (якщо не хочете CAPTCHA)

Запустіть `migrations/supabase_rate_limit.sql` у SQL Editor.
Потім перевірте, що RLS увімкнений:
```sql
alter table public.profiles enable row level security;
```

Перевірте policy для INSERT:
```sql
select * from pg_policies where tablename = 'profiles';
```

Має бути policy типу: `auth.uid() = id` (тільки авторизований користувач
пише у свій профіль). Якщо policy дозволяє anon insert — це діра.

### D. Видалити anon key з репозиторію (опційно, але правильно)

Anon key не секрет, але його наявність у GitHub — запрошення для сканерів.
Можна перенести у `.env`:
```dart
// pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0

// lib/main.dart
await dotenv.load(fileName: ".env");
```

Після deploy у Firebase Hosting — env vars беруться з build-time, тому
треба або `flutter build --dart-define`, або тримати у Firebase config.

## Чого НЕ треба робити

- ❌ **Мігрувати на Firebase** — 1 MAU не виправдовує 2-3 тижні роботи
- ❌ **Rate limit на клієнті** (зараз уже зроблено) — клієнтський rate limit
  не захистить від ботів
- ❌ **Збільшити Supabase plan** — для 1 MAU це викинуті гроші

## Очікуваний результат

Після CAPTCHA + debounce:
- Боти отримують challenge → 99% здаються
- Легітимні користувачі: 1 запит = 1 дія, без 429
- Ваш billing: 0 (все ще в межах free plan)
