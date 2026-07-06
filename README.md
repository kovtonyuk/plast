# plast_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## щоб повністю видалити Ollama з усіма даними:
- bashrm -rf ~/.ollama
- rm -rf ~/Library/Application\ Support/Ollama/
- sudo rm /usr/local/bin/ollama

## Запуск на iOs емуляторі
flutter run -d "iPhone 16 Plus" 

## збілдити додаток
- ./scripts/build.sh

## білд локалізації
- flutter gen-l10n

## зібрати ipa
- flutter build ipa --export-method development 

🧪 Як відкрити і протестувати локально

Варіант 1 — Flutter run (рекомендовано, з hot reload):
cd /Users/serhii/Plast_app/plast_app
flutter run -d chrome

Варіант 2 — зібраний білд через простий сервер:
cd /Users/serhii/Plast_app/plast_app/build/web
python3 -m http.server 8080
# Потім відкрий http://localhost:8080

Варіант 3 — через npx serve:
npx serve /Users/serhii/Plast_app/plast_app/build/web -l 8080

⚠️ Не відкривай index.html через file:// — браузер заблокує Service Worker і запити до Supabase. Потрібен саме HTTP-сервер.

URL для тестування: http://localhost:8080 (або порт, який вкажеш).

---
🌐 Як залити на домен (деплой)

build/web — це статичний сайт. Можна залити на будь-який хостинг. Три найпростіших варіанти:

Варіант A — Firebase Hosting (найпростіше, безкоштовно, custom домен)

npm install -g firebase-tools
firebase login
cd /Users/serhii/Plast_app/plast_app
firebase init hosting   # public dir: build/web, single-page app: Yes
firebase deploy
# Далі у Firebase Console → Hosting → "Add custom domain" → вказуєш свій домен

Варіант B — Netlify (drag-and-drop, без терміналу)

1. Зайди на https://app.netlify.com/drop
2. Перетягни папку /Users/serhii/Plast_app/plast_app/build/web
3. Отримаєш *.netlify.app URL
4. Custom domain: Site settings → Domain management → Add custom domain

Або через CLI:
npm i -g netlify-cli
cd /Users/serhii/Plast_app/plast_app/build/web
netlify deploy --prod

Варіант C — Vercel

npm i -g vercel
cd /Users/serhii/Plast_app/plast_app/build/web
vercel --prod

Варіант D — Свій хостинг (VPS/Shared) з Nginx

Скопіюй вміст build/web на сервер:
scp -r build/web/* user@server:/var/www/plast/
Nginx конфіг:
server {
    listen 80;
    server_name plast.example.com;
    root /var/www/plast;
    index index.html;

    # SPA routing — всі шляхи на index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Кешування JS/CSS/зображень
    location ~* \.(?:js|css|png|jpg|svg|ico|woff2?)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

---
⚠️ Важливі нюанси для веб-версії

1. Supabase — твій supabaseUrl і anonKey в lib/core/constants/app_constants.dart будуть публічно видимі в JS. Це нормально для anon-key (він створений для публічного використання), але переконайся, що RLS (Row Level Security) у Supabase увімкнено для всіх таблиць — інакше будь-хто зможе читати/писати дані.
2. Auth redirect — Supabase email-верифікація використовує redirectTo. Якщо захочеш deep-link після реєстрації, доведеться додати emailRedirectTo у signUp() для web-домену.
3. Нативні плагіни на web не працюють:
  - flutter_local_notifications — на web не буде пушів (треба підключити web-push окремо, якщо потрібно).
  - image_picker — на web працює через <input type="file">, але обмежено.
  - Додаток запуститься, але ці фічі будуть no-op.
4. GoRouter SPA — на хостингу обов'язково налаштуй try_files ... /index.html (Nginx) або redirects: [{source: "/*", destination: "/index.html", type: 404}] (Netlify), інакше при оновленні сторінки буде 404.
5. HTTPS — для Supabase Auth і Service Worker потрібен HTTPS (Netlify/Vercel/Firebase дають його автоматично).

---
🔗 Що тобі треба зробити, щоб запустити

1. Локально → запусти cd /Users/serhii/Plast_app/plast_app/build/web && python3 -m http.server 8080 → відкрий http://localhost:8080.
2. На домені → обери один із варіантів деплою вище (Firebase/Netlify/Vercel рекомендую), запуш build/web, додай свій домен у налаштуваннях хостингу. Якщо потрібна допомога з конкретним хостингом — скажи, який у тебе домен і де зареєстрований, допоможу з DNS.

✻ Churned for 7m 0s
