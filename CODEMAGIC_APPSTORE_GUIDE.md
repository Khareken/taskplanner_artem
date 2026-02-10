# Publishing TaskPlanner to App Store via Codemagic

## Prerequisites

You need:
- **Apple Developer Account** ($99/year) — https://developer.apple.com
- **App Store Connect** access — https://appstoreconnect.apple.com
- **Codemagic account** — https://codemagic.io (free tier: 500 min/month for macOS)
- Your code in a **Git repository** (GitHub, GitLab, Bitbucket)

---

## Step 1: Apple Developer Portal Setup

### 1.1 Register Bundle ID
1. Go to https://developer.apple.com/account/resources/identifiers/list
2. Click **"+"** → **"App IDs"** → **"App"**
3. Enter:
   - **Description**: `TaskPlanner`
   - **Bundle ID** (Explicit): `com.multi.planner`
4. Enable capabilities: **Push Notifications**, **Associated Domains** (if needed)
5. Click **Continue** → **Register**

### 1.2 Create App Store Connect Entry
1. Go to https://appstoreconnect.apple.com/apps
2. Click **"+"** → **"New App"**
3. Fill in:
   - **Platforms**: iOS
   - **Name**: `Task Planner - Paid Surveys`
   - **Primary Language**: English (or Russian)
   - **Bundle ID**: Select `com.multi.planner`
   - **SKU**: `com.multi.planner` (or any unique string)
4. Click **Create**
5. **Note the Apple ID** (number shown on app page) — you'll need it for Codemagic

---

## Step 2: App Store Connect API Key

Codemagic needs an API key to publish automatically.

1. Go to https://appstoreconnect.apple.com/access/integrations/api
2. Click **"+"** to generate a new key
3. Fill in:
   - **Name**: `Codemagic`
   - **Access**: `App Manager`
4. Click **Generate**
5. **Download the .p8 file** (you can only download it ONCE!)
6. Note down:
   - **Issuer ID** (shown at top of page)
   - **Key ID** (shown in the table)

---

## Step 3: Codemagic Setup

### 3.1 Connect Repository
1. Go to https://codemagic.io and sign in
2. Click **"Add application"**
3. Select your Git provider and repository
4. Choose **"Flutter App"** → select **codemagic.yaml** config

### 3.2 App Store Connect Integration
1. Go to your app in Codemagic → **Settings** → **Integrations**
2. Click **"App Store Connect"**
3. Enter:
   - **Issuer ID** (from Step 2)
   - **Key ID** (from Step 2)
   - Upload the **.p8 file** (from Step 2)
4. Click **Save**

### 3.3 iOS Code Signing
1. Go to your app → **Settings** → **Code signing (iOS)**
2. Select **"Automatic"** (recommended for Codemagic)
3. Codemagic will auto-manage provisioning profiles and certificates
4. Make sure the **Bundle ID** is set to `com.multi.planner`

### 3.4 Environment Variables (optional)
1. Go to **Settings** → **Environment variables**
2. Create group `app_store_credentials` if you prefer manual setup
3. Add:
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`  
   - `APP_STORE_CONNECT_PRIVATE_KEY` (contents of .p8 file)

---

## Step 4: Push & Build

### 4.1 Commit and Push
```bash
git add .
git commit -m "Add Codemagic CI/CD for App Store"
git push origin main
```

### 4.2 Start Build
1. Go to Codemagic dashboard
2. Select your app
3. Click **"Start new build"**
4. Select workflow: **"iOS Release"**
5. Select branch: **main**
6. Click **"Start new build"**

### 4.3 What Happens Automatically
1. Codemagic provisions a macOS build machine
2. Installs Flutter, Xcode, CocoaPods
3. Sets up code signing
4. Builds the IPA
5. Uploads to **TestFlight** automatically

---

## Step 5: App Store Submission

### 5.1 TestFlight Testing
1. After build succeeds, go to App Store Connect → **TestFlight**
2. The build will appear after Apple's processing (~15-30 min)
3. Add testers and test the app

### 5.2 Submit for Review
1. Go to App Store Connect → your app → **App Store** tab
2. Fill in required metadata:

**App Information:**
- Name: `Task Planner - Paid Surveys`
- Subtitle: `Earn coins, beat deadlines`
- Category: `Productivity`

**Description:**
```
Turn your tasks into a rewarding game! Complete tasks on time, earn game coins, and use them to extend deadlines when you need more time.

GAMIFICATION SYSTEM:
• Easy tasks: +10 coins reward
• Medium tasks: +25 coins reward
• Hard tasks: +50 coins reward

EXTEND DEADLINES:
Running out of time? Spend your earned coins:
• Easy task: 5 coins for +1 day
• Medium task: 15 coins for +1 day
• Hard task: 30 coins for +1 day

FEATURES:
• Create tasks with priorities and categories
• Three difficulty levels for each task
• Game currency for completed tasks
• Calendar view for task planning
• Productivity statistics
• Subtasks with progress tracking
• Dark and light themes
• Push notifications for deadlines

The harder the task — the bigger the reward. Earn coins to extend deadlines when it truly matters.
```

**Keywords:** task planner, productivity, gamification, to-do list, performance tracker, deadline, time management

**Screenshots:** Upload at least 3 screenshots (required sizes below)
- iPhone 6.7" (1290 × 2796) — iPhone 15 Pro Max
- iPhone 6.5" (1284 × 2778) — iPhone 14 Plus
- iPad 12.9" (2048 × 2732) — if supporting iPad

**Privacy Policy URL:** Required — you need a privacy policy page hosted somewhere

3. Select the TestFlight build
4. Click **"Submit for Review"**

---

## Step 6: App Review

- Apple review typically takes **24-48 hours**
- If rejected, check the resolution center in App Store Connect

### Common Rejection Reasons:
1. **No Privacy Policy** — must provide a URL
2. **Broken functionality** — test everything before submission
3. **Incomplete metadata** — fill all required fields
4. **com.example.* bundle ID** — already fixed ✅

---

## Troubleshooting

### Build fails with code signing errors
→ Make sure App Store Connect integration is configured in Codemagic
→ Check that bundle ID `com.multi.planner` is registered in Apple Developer Portal

### Build fails with CocoaPods errors
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```
Then commit and push again.

### "Missing compliance" warning on TestFlight
→ Go to App Store Connect → TestFlight → click on the build → set Export Compliance to "No" (if you don't use custom encryption)

---

## File Structure
```
taskplanner_artem/
├── codemagic.yaml          ← CI/CD configuration
├── ios/
│   ├── Runner.xcodeproj/
│   │   └── project.pbxproj ← Bundle ID: com.multi.planner
│   └── Runner/
│       └── Info.plist       ← App display name, permissions
└── pubspec.yaml             ← Version: 2.1.0+3
```
