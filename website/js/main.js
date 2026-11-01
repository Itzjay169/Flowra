/**
 * Flowra Website Client Logic
 * Handles dynamic release data loading, live version search, theme switching,
 * roadmap rendering, and serverless suggestion form handling.
 */

document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initNavigation();
  initFooterAndRoadmap();
  loadReleases();
  initSuggestionForm();
  initFaqAccordion();
});

// Global state
let allReleases = [];
let latestRelease = null;

/**
 * Theme Management (Dark / Light mode)
 */
function initTheme() {
  const themeToggleBtn = document.getElementById('themeToggleBtn');
  const storedTheme = localStorage.getItem('flowra_theme');
  const systemPrefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  const initialTheme = storedTheme || (systemPrefersDark ? 'dark' : 'light');

  setTheme(initialTheme);

  if (themeToggleBtn) {
    themeToggleBtn.addEventListener('click', () => {
      const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
      const nextTheme = currentTheme === 'dark' ? 'light' : 'dark';
      setTheme(nextTheme);
    });
  }
}

function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('flowra_theme', theme);
  const themeToggleBtn = document.getElementById('themeToggleBtn');
  if (themeToggleBtn) {
    themeToggleBtn.innerHTML = theme === 'dark' ? '☀️' : '🌙';
    themeToggleBtn.setAttribute('title', `Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`);
    themeToggleBtn.setAttribute('aria-label', `Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`);
  }
}

/**
 * Mobile Navigation & Keyboard Shortcuts
 */
function initNavigation() {
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  const navLinks = document.getElementById('navLinks');
  const navSearchInput = document.getElementById('navSearchInput');

  if (mobileMenuBtn && navLinks) {
    mobileMenuBtn.addEventListener('click', () => {
      navLinks.classList.toggle('open');
      mobileMenuBtn.textContent = navLinks.classList.contains('open') ? '✕' : '☰';
    });

    // Close on link click
    navLinks.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        navLinks.classList.remove('open');
        mobileMenuBtn.textContent = '☰';
      });
    });
  }

  // Keyboard shortcut '/' to search
  window.addEventListener('keydown', (e) => {
    if (e.key === '/' && document.activeElement.tagName !== 'INPUT' && document.activeElement.tagName !== 'TEXTAREA') {
      e.preventDefault();
      if (navSearchInput) {
        navSearchInput.focus();
        navSearchInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
    }
  });

  if (navSearchInput) {
    navSearchInput.addEventListener('input', (e) => {
      const query = e.target.value.trim();
      const versionSearchInput = document.getElementById('versionSearchInput');
      if (versionSearchInput) {
        versionSearchInput.value = query;
      }
      filterVersions(query);
      // Smooth scroll down to versions if user searches from header
      if (query.length > 0 && window.scrollY < 400) {
        const versionsSection = document.getElementById('versions');
        if (versionsSection) {
          versionsSection.scrollIntoView({ behavior: 'smooth' });
        }
      }
    });
  }
}

/**
 * Load releases from releases.json
 */
async function loadReleases() {
  const releasesContainer = document.getElementById('versionsTimeline');
  const releasesUrl = FlowraConfig.app.releasesJsonUrl || 'releases.json';

  try {
    const res = await fetch(releasesUrl);
    if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
    const data = await res.json();
    allReleases = Array.isArray(data) ? data : [];
  } catch (err) {
    console.warn('Could not fetch releases.json directly, using embedded fallback:', err);
    // Embedded fallback ensures website renders nicely even when opened as file:// locally
    allReleases = [
      {
        version: "1.0.0",
        buildNumber: 1,
        releaseDate: "2026-09-28",
        title: "Flowra v1.0.0 — Initial Official Release",
        apkFileName: "Flowra-v1.0.0.apk",
        "fileSizeMb": 62.0,
        "sha256": "c0d18e3916f58f40fd73b6159a025162c30cebfb2398cd70174b5a6341b3fa23",
        downloadUrl: "Flowra-v1.2.0.apk",
        githubReleaseUrl: "https://github.com/Itzjay169/Flowra/releases",
        changes: {
          Added: [
            "Study Timetable & Routine Planner: Daily/weekly interactive timelines, subject filtering, and overlap detection.",
            "Exact Alarms & Offline Notifications: Survives phone restarts with high-priority Android alarm channels.",
            "Study Focus & Pomodoro Mode: Clean focus timer with 25m, 45m, and 60m presets.",
            "Daily Expense Tracker & Budget: Fast expense logging, category filtering, and 80%/100% budget alerts.",
            "Visual Analytics & Reports: Weekly task completion charts and 30-day expense breakdowns.",
            "100% Offline SQLite Storage with CSV export for all expense data.",
            "Optional Developer Support screen with instant UPI deep-linking.",
            "Automated CI/CD build pipeline for APK and AAB binaries."
          ],
          Changed: [
            "Full brand refresh to Flowra with deep indigo Material 3 theme and new app icons.",
            "Modular app footer and updated copyright info.",
            "Configured secure keystore release signing."
          ],
          Fixed: [
            "Notification alarm triggers for Android 13/14+ exact alarm policies.",
            "StudyFocusScreen layout overflow on smaller screen heights.",
            "Resolved all analysis warnings and lints."
          ],
          Removed: []
        }
      }
    ];
  }

  if (allReleases.length > 0) {
    latestRelease = allReleases[0];
    updateHeroSection(latestRelease);
    populateVersionSelect(allReleases);
    renderVersions(allReleases);
  } else {
    if (releasesContainer) {
      releasesContainer.innerHTML = '<p class="text-muted" style="text-align: center;">No releases found.</p>';
    }
  }

  initVersionFilters();
}

/**
 * Update Hero Section with dynamic latest release info
 */
function updateHeroSection(latest) {
  const heroDownloadBtn = document.getElementById('heroDownloadBtn');
  const heroVersionLabel = document.getElementById('heroVersionLabel');
  const heroSizeLabel = document.getElementById('heroSizeLabel');
  const heroDateLabel = document.getElementById('heroDateLabel');

  if (heroDownloadBtn && latest) {
    heroDownloadBtn.href = latest.downloadUrl || `${FlowraConfig.developer.githubRepoUrl}/releases`;
  }
  if (heroVersionLabel && latest) {
    heroVersionLabel.textContent = `Download v${latest.version}`;
  }
  if (heroSizeLabel && latest) {
    heroSizeLabel.textContent = `${latest.fileSizeMb || '61.9'} MB`;
  }
  if (heroDateLabel && latest) {
    heroDateLabel.textContent = `Released on ${latest.releaseDate}`;
  }

  // Footer latest version badge
  const footerVersionSpan = document.getElementById('footerCurrentVersion');
  if (footerVersionSpan && latest) {
    footerVersionSpan.textContent = `v${latest.version}`;
  }
}

/**
 * Render Version Cards into All Versions Timeline
 */
function renderVersions(releases) {
  const container = document.getElementById('versionsTimeline');
  if (!container) return;

  if (releases.length === 0) {
    container.innerHTML = `
      <div style="text-align: center; padding: 48px; background: var(--bg-surface); border-radius: 16px; border: 1px solid var(--border-color);">
        <p style="font-size: 1.1rem; color: var(--text-muted); margin-bottom: 8px;">No matching versions found.</p>
        <p style="font-size: 0.875rem; color: var(--text-subtle);">Try searching for another keyword, e.g. "alarm", "pomodoro", or "1.0".</p>
      </div>
    `;
    return;
  }

  const html = releases.map((rel, index) => {
    const isLatest = index === 0;
    const downloadUrl = rel.downloadUrl || `${FlowraConfig.developer.githubRepoUrl}/releases/tag/v${rel.version}`;
    const sha = rel.sha256 || '';
    const shortSha = sha.length > 16 ? `${sha.substring(0, 16)}...` : sha;

    // Render categorized changes
    let changesHtml = '';
    const changesObj = rel.changes || {};
    const categories = ['Added', 'Changed', 'Fixed', 'Removed'];

    categories.forEach(cat => {
      const items = changesObj[cat];
      if (Array.isArray(items) && items.length > 0) {
        const catClass = `category-${cat.toLowerCase()}`;
        changesHtml += `
          <div class="changes-category">
            <span class="category-title ${catClass}">${cat}</span>
            <ul class="changes-list">
              ${items.map(item => `<li>${escapeHtml(item)}</li>`).join('')}
            </ul>
          </div>
        `;
      }
    });

    if (!changesHtml && Array.isArray(rel.notes)) {
      changesHtml = `
        <div class="changes-category">
          <span class="category-title category-changed">Changes</span>
          <ul class="changes-list">
            ${rel.notes.map(item => `<li>${escapeHtml(item)}</li>`).join('')}
          </ul>
        </div>
      `;
    }

    return `
      <article class="version-card ${isLatest ? 'is-latest' : ''}" id="v-${rel.version}">
        <div class="version-header">
          <div class="version-title-area">
            <span class="version-number">v${escapeHtml(rel.version)}</span>
            ${isLatest ? '<span class="badge badge-latest">Latest</span>' : ''}
            <span class="badge badge-build">Build ${rel.buildNumber || 1}</span>
            <span class="version-date">📅 ${escapeHtml(rel.releaseDate)}</span>
          </div>
          <a href="${downloadUrl}" class="btn btn-primary" style="padding: 10px 20px; font-size: 0.9rem;" download>
            <span>⬇ Download APK</span>
          </a>
        </div>

        <div class="version-meta-row">
          <div class="version-specs">
            <div class="spec-item">
              <span>File:</span>
              <strong>${escapeHtml(rel.apkFileName || `Flowra-v${rel.version}.apk`)}</strong>
            </div>
            <div class="spec-item">
              <span>Size:</span>
              <strong>${rel.fileSizeMb || '61.9'} MB</strong>
            </div>
          </div>
          ${sha ? `
            <button class="sha256-copy-btn" onclick="copyToClipboard('${sha}', 'SHA-256 Checksum copied!')" title="Click to copy full SHA-256 checksum">
              <span>SHA-256: <code>${shortSha}</code></span>
              <span>📋 Copy</span>
            </button>
          ` : ''}
        </div>

        <div class="version-changes-block">
          ${changesHtml}
        </div>
      </article>
    `;
  }).join('');

  container.innerHTML = html;
}

/**
 * Filter & Sort Versions
 */
function initVersionFilters() {
  const versionSearchInput = document.getElementById('versionSearchInput');
  const versionSortSelect = document.getElementById('versionSortSelect');

  if (versionSearchInput) {
    versionSearchInput.addEventListener('input', (e) => {
      filterVersions(e.target.value.trim());
    });
  }

  if (versionSortSelect) {
    versionSortSelect.addEventListener('change', () => {
      filterVersions(versionSearchInput ? versionSearchInput.value.trim() : '');
    });
  }
}

function filterVersions(query) {
  const sortOrder = document.getElementById('versionSortSelect')?.value || 'newest';
  const q = query.toLowerCase();

  let filtered = allReleases.filter(rel => {
    if (!q) return true;
    if (rel.version.toLowerCase().includes(q)) return true;
    if (rel.releaseDate && rel.releaseDate.toLowerCase().includes(q)) return true;

    // Check changes
    if (rel.changes) {
      for (const cat in rel.changes) {
        const list = rel.changes[cat];
        if (Array.isArray(list) && list.some(item => item.toLowerCase().includes(q))) {
          return true;
        }
      }
    }
    return false;
  });

  if (sortOrder === 'oldest') {
    filtered = [...filtered].reverse();
  }

  renderVersions(filtered);
}

/**
 * Populate Version Dropdown in Suggestion Form
 */
function populateVersionSelect(releases) {
  const select = document.getElementById('suggestVersion');
  if (!select) return;

  select.innerHTML = '';
  releases.forEach(rel => {
    const opt = document.createElement('option');
    opt.value = rel.version;
    opt.textContent = `v${rel.version} (${rel.releaseDate})`;
    select.appendChild(opt);
  });

  const notInstalledOpt = document.createElement('option');
  notInstalledOpt.value = 'Not installed yet';
  notInstalledOpt.textContent = 'Not installed yet / Exploring';
  select.appendChild(notInstalledOpt);
}

/**
 * Suggestion & Feature Request Form
 */
function initSuggestionForm() {
  const form = document.getElementById('suggestionForm');
  const messageInput = document.getElementById('suggestMessage');
  const charCounter = document.getElementById('charCount');
  const submitBtn = document.getElementById('suggestSubmitBtn');
  const alertSuccess = document.getElementById('formAlertSuccess');
  const alertError = document.getElementById('formAlertError');
  const fallbackActions = document.getElementById('fallbackActions');
  const emailFallbackBtn = document.getElementById('emailFallbackBtn');
  const githubFallbackBtn = document.getElementById('githubFallbackBtn');

  if (!form) return;

  // Live character counter (max 1000)
  if (messageInput && charCounter) {
    messageInput.addEventListener('input', () => {
      const len = messageInput.value.length;
      charCounter.textContent = `${len} / 1000`;
      if (len > 1000) {
        charCounter.style.color = 'var(--danger)';
      } else {
        charCounter.style.color = 'var(--text-subtle)';
      }
    });
  }

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    // Reset alert states
    hideElement(alertSuccess);
    hideElement(alertError);
    hideElement(fallbackActions);

    // 1. Anti-spam honeypot verification
    const honeypot = document.getElementById('hp_website_url')?.value;
    if (honeypot && honeypot.trim().length > 0) {
      console.warn('Bot detected via honeypot.');
      showElement(alertSuccess);
      alertSuccess.textContent = 'Thank you! Your suggestion was received.';
      form.reset();
      return;
    }

    // 2. Cooldown check
    const lastSubmitted = localStorage.getItem('flowra_suggestion_timestamp');
    const cooldown = FlowraConfig.forms.cooldownSeconds || 60;
    if (lastSubmitted) {
      const elapsed = Math.floor((Date.now() - parseInt(lastSubmitted, 10)) / 1000);
      if (elapsed < cooldown) {
        showElement(alertError);
        alertError.textContent = `Please wait ${cooldown - elapsed} seconds before sending another suggestion.`;
        return;
      }
    }

    const name = document.getElementById('suggestName')?.value.trim() || 'Anonymous';
    const email = document.getElementById('suggestEmail')?.value.trim() || 'Not provided';
    const type = document.getElementById('suggestType')?.value || 'Feature request';
    const version = document.getElementById('suggestVersion')?.value || 'Unknown';
    const message = messageInput?.value.trim() || '';

    if (!message) {
      showElement(alertError);
      alertError.textContent = 'Please enter your suggestion or feedback message.';
      messageInput.focus();
      return;
    }

    if (message.length > 1000) {
      showElement(alertError);
      alertError.textContent = 'Message exceeds the 1000-character limit.';
      messageInput.focus();
      return;
    }

    // Configure Fallback Links
    setupFallbacks(name, email, type, version, message);

    // Disable button & show spinner
    submitBtn.disabled = true;
    const originalBtnText = submitBtn.innerHTML;
    submitBtn.innerHTML = '<span>Sending... ⏳</span>';

    const targetEmail = FlowraConfig.forms?.targetEmail || FlowraConfig.developer?.email || 'magicianbusiness30@gmail.com';

    try {
      const response = await fetch(`https://formsubmit.co/ajax/${targetEmail}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          _subject: `[Flowra ${type}] Suggestion from ${name} (v${version})`,
          name: name,
          email: email,
          type: type,
          version: version,
          message: message,
          _replyto: email !== 'Not provided' ? email : targetEmail,
        })
      });

      const result = await response.json();
      if (response.ok && (result.success === 'true' || result.success === true || result.message?.toLowerCase().includes('success'))) {
        showElement(alertSuccess);
        alertSuccess.textContent = `Thank you! Your suggestion was sent successfully to ${targetEmail}. We appreciate your feedback!`;
        localStorage.setItem('flowra_suggestion_timestamp', Date.now().toString());
        form.reset();
        if (charCounter) charCounter.textContent = '0 / 1000';
      } else {
        throw new Error(result.message || 'Submission failed');
      }
    } catch (err) {
      console.warn('Form submission service error:', err);
      showElement(alertError);
      alertError.innerHTML = `
        <strong>Could not send automatically.</strong><br>
        You can still send it directly to <strong>${targetEmail}</strong> using the buttons below:
      `;
      showElement(fallbackActions);
    } finally {
      submitBtn.disabled = false;
      submitBtn.innerHTML = originalBtnText;
    }
  });

  function setupFallbacks(name, email, type, version, message) {
    if (emailFallbackBtn) {
      const subject = encodeURIComponent(`[Flowra ${type}] Suggestion`);
      const body = encodeURIComponent(
        `Name: ${name}\nEmail: ${email}\nVersion: ${version}\nType: ${type}\n\nMessage:\n${message}`
      );
      emailFallbackBtn.href = `mailto:${FlowraConfig.developer.email}?subject=${subject}&body=${body}`;
    }

    if (githubFallbackBtn) {
      const title = encodeURIComponent(`[${type}] ${message.substring(0, 45)}...`);
      const body = encodeURIComponent(
        `### Suggestion Details\n- **Type**: ${type}\n- **Version**: ${version}\n- **Submitted by**: ${name}\n\n### Description\n${message}`
      );
      githubFallbackBtn.href = `${FlowraConfig.developer.githubIssuesUrl}?title=${title}&body=${body}`;
    }
  }
}

/**
 * FAQ Accordion
 */
function initFaqAccordion() {
  const faqItems = document.querySelectorAll('.faq-item');
  faqItems.forEach(item => {
    const question = item.querySelector('.faq-question');
    const answer = item.querySelector('.faq-answer');

    if (question && answer) {
      question.addEventListener('click', () => {
        const isOpen = item.classList.contains('is-open');
        // Close others
        faqItems.forEach(other => {
          if (other !== item) {
            other.classList.remove('is-open');
            const otherAnswer = other.querySelector('.faq-answer');
            if (otherAnswer) otherAnswer.style.maxHeight = null;
          }
        });

        if (isOpen) {
          item.classList.remove('is-open');
          answer.style.maxHeight = null;
        } else {
          item.classList.add('is-open');
          answer.style.maxHeight = `${answer.scrollHeight + 20}px`;
        }
      });
    }
  });
}

/**
 * Populate Footer, Social Links & Roadmap
 */
function initFooterAndRoadmap() {
  // Current year auto-update
  const yearSpan = document.getElementById('currentYear');
  if (yearSpan) {
    yearSpan.textContent = new Date().getFullYear();
  }

  // Developer info in footer
  const devNameEl = document.getElementById('footerDevName');
  const devBioEl = document.getElementById('footerDevBio');
  const devLocationEl = document.getElementById('footerDevLocation');

  if (devNameEl) devNameEl.textContent = FlowraConfig.developer.name;
  if (devBioEl) devBioEl.textContent = FlowraConfig.developer.bio;
  if (devLocationEl) devLocationEl.textContent = FlowraConfig.developer.location ? `📍 Based in ${FlowraConfig.developer.location}` : '';

  // Social Links
  const instagramLink = document.getElementById('footerInstagramLink');
  const githubProfileLink = document.getElementById('footerGithubProfileLink');
  const githubRepoLink = document.getElementById('footerGithubRepoLink');
  const emailLink = document.getElementById('footerEmailLink');
  const donationUpiText = document.getElementById('footerDonationUpi');

  if (instagramLink) instagramLink.href = FlowraConfig.developer.instagramUrl;
  if (githubProfileLink) githubProfileLink.href = FlowraConfig.developer.githubProfileUrl;
  if (githubRepoLink) githubRepoLink.href = FlowraConfig.developer.githubRepoUrl;
  if (emailLink) {
    emailLink.href = `mailto:${FlowraConfig.developer.email}`;
    emailLink.textContent = FlowraConfig.developer.email;
  }
  if (donationUpiText) {
    donationUpiText.textContent = FlowraConfig.donation.upiId;
  }

  // Roadmap Items
  const roadmapContainer = document.getElementById('roadmapList');
  if (roadmapContainer && Array.isArray(FlowraConfig.roadmap)) {
    roadmapContainer.innerHTML = FlowraConfig.roadmap.map(item => {
      const statusClass = `status-${(item.status || 'planned').toLowerCase().replace(/\s+/g, '-')}`;
      return `
        <div class="roadmap-item">
          <div class="roadmap-item-top">
            <span class="roadmap-item-title">${escapeHtml(item.title)}</span>
            <span class="roadmap-status-badge ${statusClass}">${escapeHtml(item.status)}</span>
          </div>
          <p class="roadmap-item-desc">${escapeHtml(item.description)}</p>
        </div>
      `;
    }).join('');
  }

  // Back to top
  const backToTopBtn = document.getElementById('backToTopBtn');
  if (backToTopBtn) {
    backToTopBtn.addEventListener('click', () => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }
}

/**
 * Copy to Clipboard with Toast Notification
 */
window.copyToClipboard = function(text, successMsg = 'Copied to clipboard!') {
  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(text).then(() => {
      showToast(successMsg);
    }).catch(() => {
      fallbackCopyText(text, successMsg);
    });
  } else {
    fallbackCopyText(text, successMsg);
  }
};

function fallbackCopyText(text, successMsg) {
  const textArea = document.createElement('textarea');
  textArea.value = text;
  textArea.style.position = 'fixed';
  textArea.style.left = '-999999px';
  textArea.style.top = '-999999px';
  document.body.appendChild(textArea);
  textArea.focus();
  textArea.select();
  try {
    document.execCommand('copy');
    showToast(successMsg);
  } catch (err) {
    alert(`Could not copy automatically. Text: ${text}`);
  }
  document.body.removeChild(textArea);
}

function showToast(message) {
  let toast = document.getElementById('siteToast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'siteToast';
    toast.className = 'toast';
    document.body.appendChild(toast);
  }
  toast.textContent = message;
  toast.classList.add('show');
  setTimeout(() => {
    toast.classList.remove('show');
  }, 2800);
}

// Helpers
function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function showElement(el) {
  if (el) el.style.display = 'block';
}

function hideElement(el) {
  if (el) el.style.display = 'none';
}
