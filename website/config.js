/**
 * Flowra Website Configuration
 * Single source of truth for all personal details, links, donation information,
 * roadmap items, and form API keys.
 * 
 * Edit this file to update details across the entire website without touching HTML.
 */

const FlowraConfig = {
  // App Information
  app: {
    name: "Flowra",
    tagline: "Offline planner & expense tracker. Zero cloud. Zero ads. Complete privacy.",
    description: "Flowra is a 100% offline-first Android productivity app combining a routine & task planner with strong alarms, focus timer, and an intuitive daily expense tracker.",
    logoPath: "assets/icon.png",
    faviconPath: "assets/favicon.png",
    packageId: "com.flowra.flowra",
    license: "MIT",
    releasesJsonUrl: "releases.json",
    minAndroidVersion: "Android 8.0 (Oreo) or higher",
  },

  // Developer Information
  developer: {
    name: "Jay (Itz30jay)",
    bio: "Independent developer and creator of Flowra. Passionate about building fast, clean, privacy-first offline utilities that give users 100% control over their data.",
    location: "India",
    avatar: "assets/icon.png", // Replace with your personal photo if desired
    email: "magicianbusiness30@gmail.com",
    instagramUrl: "https://www.instagram.com/jay_dev._._",
    githubProfileUrl: "https://github.com/Itz30jay",
    githubRepoUrl: "https://github.com/Itz30jay/Flowra",
    githubIssuesUrl: "https://github.com/Itz30jay/Flowra/issues/new",
  },

  // Donation & Support Configuration
  donation: {
    upiId: "jaykishandas30@oksbi",
    upiName: "Flowra Developer",
    donationNote: "Support Flowra Development",
    // Preset amounts in INR
    presets: [10, 20, 50, 100],
    // Optional external payment link (e.g. BuyMeACoffee, Ko-fi, Razorpay)
    paymentLink: "",
  },

  // Suggestion & Feature Request Form Configuration
  // Uses Web3Forms (100% free, no backend required, delivers directly to your email)
  // How to get your free key:
  // 1. Visit https://web3forms.com
  // 2. Enter your email: magicianbusiness30@gmail.com
  // 3. Check your inbox and paste the received Access Key below.
  forms: {
    service: "web3forms", // "web3forms" or "formsubmit"
    web3formsAccessKey: "00fdf361-5f5e-48fc-98f9-4044f679a93d",
    fallbackEmail: "magicianbusiness30@gmail.com",
    // Cooldown in seconds before allowing another submission from the same client
    cooldownSeconds: 60,
  },

  // Roadmap & Top Requested Features
  roadmap: [
    {
      title: "Encrypted User-Owned Cloud Backup",
      description: "Optional encrypted sync via personal Google Drive or local WiFi WebDAV. Keeps zero-knowledge privacy.",
      status: "In Progress",
      category: "Data Privacy"
    },
    {
      title: "Custom Alarm Ringtones & Vibrations",
      description: "Allow picking custom audio tracks and vibration patterns for critical schedule alarms.",
      status: "Planned",
      category: "Planner"
    },
    {
      title: "Recurring Expenses & Subscription Tracker",
      description: "Track monthly recurring subscriptions (Netflix, internet, gym) with due-date reminders.",
      status: "Planned",
      category: "Expenses"
    },
    {
      title: "Calendar Sync (Import/Export .ics)",
      description: "Bi-directional or read-only import from system device calendars and timetable export.",
      status: "Considering",
      category: "Planner"
    }
  ]
};

// Freeze configuration to prevent accidental modification
Object.freeze(FlowraConfig);
