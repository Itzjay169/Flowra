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

  // Company & Developer Information
  company: {
    name: "Vexora Technology",
    tagline: "Innovating Today. Building Tomorrow.",
    logoPath: "assets/vexora_logo.png",
    mission: "This project was made by Vexora Technology to help students succeed.",
    about: "Vexora Technology is a software development company dedicated to creating innovative digital products and smart technology solutions. We focus on web development, mobile applications, artificial intelligence, and custom software development. Our goal is to transform ideas into powerful, reliable, and user-friendly solutions that simplify everyday challenges and create meaningful digital experiences. Driven by innovation and creativity, we aim to build technology that makes a difference.",
  },

  developer: {
    name: "Vexora Technology",
    role: "Development Team",
    company: "Vexora Technology",
    bio: "Flowra is developed by Vexora Technology to provide students with distraction-free, privacy-first productivity. Lead Developer: Jay",
    location: "India",
    avatar: "assets/vexora_logo.png",
    email: "magicianbusiness30@gmail.com",
    instagramUrl: "https://www.instagram.com/jay_dev._._",
    githubProfileUrl: "https://github.com/Itzjay169",
    githubRepoUrl: "https://github.com/Itzjay169/Flowra",
    githubIssuesUrl: "https://github.com/Itzjay169/Flowra/issues/new",
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
  // Direct delivery to magicianbusiness30@gmail.com via FormSubmit AJAX API
  forms: {
    service: "formsubmit", // "formsubmit" routes directly to targetEmail
    targetEmail: "magicianbusiness30@gmail.com",
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
