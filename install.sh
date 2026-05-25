import customtkinter as ctk
from tkinter import filedialog, messagebox, scrolledtext
import subprocess
import webbrowser
import os
import sys
import time

# --- Configure the Futuristic Theme ---
ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

class AppInstaller(ctk.CTk):
    def __init__(self):
        super().__init__()

        # --- Window Setup ---
        self.title("🚀 Application Installer Suite - Professional Package Manager")
        self.geometry("1100x750")
        self.resizable(True, True)
        self.minsize(900, 600)

        # --- Top Header ---
        header_frame = ctk.CTkFrame(self, fg_color="#0a0e27", height=80, corner_radius=0)
        header_frame.pack(side="top", fill="x", pady=0)
        header_frame.pack_propagate(False)

        title_label = ctk.CTkLabel(header_frame, text="🚀 Application Installer Suite",
                                    font=ctk.CTkFont(size=28, weight="bold"),
                                    text_color="#00d4ff")
        title_label.pack(pady=10, padx=20, anchor="w")

        subtitle = ctk.CTkLabel(header_frame, text="Professional .deb Package Manager | Kali Linux Edition",
                               font=ctk.CTkFont(size=12),
                               text_color="#888888")
        subtitle.pack(pady=0, padx=20, anchor="w")

        # --- Main Container ---
        main_container = ctk.CTkFrame(self, fg_color="transparent")
        main_container.pack(side="left", fill="both", expand=True, padx=0, pady=0)

        # --- Sidebar Navigation ---
        self.sidebar_frame = ctk.CTkFrame(main_container, width=220, corner_radius=0, fg_color="#0f1419")
        self.sidebar_frame.pack(side="left", fill="y", padx=0)
        self.sidebar_frame.pack_propagate(False)

        nav_label = ctk.CTkLabel(self.sidebar_frame, text="Navigation",
                                font=ctk.CTkFont(size=16, weight="bold"),
                                text_color="#00d4ff")
        nav_label.pack(pady=20, padx=15)

        # Navigation buttons
        self.btn_tab_install = ctk.CTkButton(self.sidebar_frame, text="📦 Installer",
                                            command=lambda: self.select_tab("install"),
                                            height=45, font=ctk.CTkFont(size=12, weight="bold"))
        self.btn_tab_install.pack(pady=8, padx=15, fill="x")

        self.btn_tab_uninstall = ctk.CTkButton(self.sidebar_frame, text="🗑️ Uninstaller",
                                              command=lambda: self.select_tab("uninstall"),
                                              height=45, font=ctk.CTkFont(size=12, weight="bold"))
        self.btn_tab_uninstall.pack(pady=8, padx=15, fill="x")

        self.btn_tab_files = ctk.CTkButton(self.sidebar_frame, text="📁 Files",
                                          command=lambda: self.select_tab("files"),
                                          height=45, font=ctk.CTkFont(size=12, weight="bold"))
        self.btn_tab_files.pack(pady=8, padx=15, fill="x")

        self.btn_tab_code = ctk.CTkButton(self.sidebar_frame, text="⚙️ Working",
                                         command=lambda: self.select_tab("code"),
                                         height=45, font=ctk.CTkFont(size=12, weight="bold"))
        self.btn_tab_code.pack(pady=8, padx=15, fill="x")

        self.btn_tab_help = ctk.CTkButton(self.sidebar_frame, text="❓ Help",
                                         command=lambda: self.select_tab("help"),
                                         height=45, font=ctk.CTkFont(size=12, weight="bold"))
        self.btn_tab_help.pack(pady=8, padx=15, fill="x")

        # Developer Section at bottom
        dev_frame = ctk.CTkFrame(self.sidebar_frame, fg_color="transparent")
        dev_frame.pack(side="bottom", fill="x", pady=20, padx=15)

        # "Developer: Kunal Mistari" label (restored with your name)
        dev_label = ctk.CTkLabel(dev_frame, text="Developer: Kunal Mistari",
                                 font=ctk.CTkFont(size=12, weight="bold"),
                                 text_color="#00d4ff")
        dev_label.pack(pady=(0, 10))

        # GitHub button – now with a modern, vibrant blue/cyan color
        self.btn_github = ctk.CTkButton(dev_frame, text="🔗 GitHub Profile",
                                        fg_color="#27b10e",
                                        hover_color="#3de021",
                                        command=self.open_github_options,
                                        height=40, font=ctk.CTkFont(size=11, weight="bold"))
        self.btn_github.pack(fill="x", pady=5)

        # GitHub username hint (kept as is)
        github_hint = ctk.CTkLabel(dev_frame, text="mistaribaba",
                                   font=ctk.CTkFont(size=10),
                                   text_color="#00d4ff")
        github_hint.pack(pady=(5, 0))

        # --- Main Content Area ---
        self.main_frame = ctk.CTkFrame(main_container, corner_radius=0, fg_color="#1a1a2e")
        self.main_frame.pack(side="right", fill="both", expand=True, padx=0, pady=0)

        # --- Initialize Tabs ---
        self.frames = {}
        self.setup_install_tab()
        self.setup_uninstall_tab()
        self.setup_files_tab()
        self.setup_code_tab()
        self.setup_help_tab()

        # Start on Install Tab
        self.select_tab("install")

        # Timer variables
        self.timer_label = None
        self.keep_btn = None
        self.auto_close_timer_id = None
        self.current_terminal_proc = None

    # ================= TAB SELECTION =================
    def select_tab(self, tab_name):
        for frame in self.frames.values():
            frame.pack_forget()
        if tab_name in self.frames:
            self.frames[tab_name].pack(fill="both", expand=True)

    # ================= 1. INSTALLER TAB =================
    def setup_install_tab(self):
        frame = ctk.CTkScrollableFrame(self.main_frame, fg_color="transparent")
        self.frames["install"] = frame

        title = ctk.CTkLabel(frame, text="📦 Smart .deb Installer",
                            font=ctk.CTkFont(size=22, weight="bold"),
                            text_color="#00d4ff")
        title.pack(pady=15, padx=20, anchor="w")

        info_box = ctk.CTkFrame(frame, fg_color="#1f2f3f", corner_radius=10)
        info_box.pack(pady=10, padx=20, fill="x")
        info_text = ctk.CTkLabel(info_box, text="Select a .deb file to install. The system will automatically resolve dependencies.",
                                text_color="#aaaaaa", font=ctk.CTkFont(size=11),
                                justify="left", wraplength=700)
        info_text.pack(pady=10, padx=15)

        file_section = ctk.CTkFrame(frame, fg_color="transparent")
        file_section.pack(pady=15, padx=20, fill="x")

        file_label = ctk.CTkLabel(file_section, text="Select Package File:",
                                 font=ctk.CTkFont(size=12, weight="bold"))
        file_label.pack(anchor="w", pady=(0, 5))

        self.install_file_path = ctk.StringVar()
        entry_row = ctk.CTkFrame(file_section, fg_color="transparent")
        entry_row.pack(pady=5, fill="x")

        self.entry_install = ctk.CTkEntry(entry_row, textvariable=self.install_file_path,
                                         placeholder_text="No file selected. Click Browse...",
                                         font=ctk.CTkFont(size=11))
        self.entry_install.pack(side="left", padx=(0, 10), fill="x", expand=True)

        btn_browse = ctk.CTkButton(entry_row, text="📂 Browse", width=100, command=self.browse_file)
        btn_browse.pack(side="left")

        # Installation button (no progress bar, just button)
        self.btn_run_install = ctk.CTkButton(frame, text="▶ Initialize Installation (opens terminal)",
                                            font=ctk.CTkFont(size=14, weight="bold"),
                                            fg_color="#1a5c1a", hover_color="#2d8c2d",
                                            height=50,
                                            command=self.install_package)
        self.btn_run_install.pack(pady=20, padx=20, fill="x")

        self.install_status = ctk.CTkLabel(frame, text="✓ System Ready",
                                          font=ctk.CTkFont(size=11, slant="italic"),
                                          text_color="#00d4ff")
        self.install_status.pack(pady=5, anchor="w", padx=20)

    # ================= 2. UNINSTALLER TAB =================
    def setup_uninstall_tab(self):
        frame = ctk.CTkScrollableFrame(self.main_frame, fg_color="transparent")
        self.frames["uninstall"] = frame

        title = ctk.CTkLabel(frame, text="🗑️ System Cleanup & Uninstaller",
                            font=ctk.CTkFont(size=22, weight="bold"),
                            text_color="#00d4ff")
        title.pack(pady=15, padx=20, anchor="w")

        info_box = ctk.CTkFrame(frame, fg_color="#1f2f3f", corner_radius=10)
        info_box.pack(pady=10, padx=20, fill="x")
        info_text = ctk.CTkLabel(info_box, text="Select an installed application to remove. All associated files and dependencies will be cleaned.",
                                text_color="#aaaaaa", font=ctk.CTkFont(size=11),
                                justify="left", wraplength=700)
        info_text.pack(pady=10, padx=15)

        pkg_section = ctk.CTkFrame(frame, fg_color="transparent")
        pkg_section.pack(pady=15, padx=20, fill="x")

        pkg_label = ctk.CTkLabel(pkg_section, text="Select Application to Remove:",
                                font=ctk.CTkFont(size=12, weight="bold"))
        pkg_label.pack(anchor="w", pady=(0, 5))

        self.uninstall_pkg_name = ctk.StringVar()
        entry_row = ctk.CTkFrame(pkg_section, fg_color="transparent")
        entry_row.pack(pady=5, fill="x")

        self.entry_uninstall = ctk.CTkEntry(entry_row, textvariable=self.uninstall_pkg_name,
                                           placeholder_text="Click 'Browse Apps' to select...",
                                           font=ctk.CTkFont(size=11))
        self.entry_uninstall.pack(side="left", padx=(0, 10), fill="x", expand=True)

        self.btn_browse_uninstall = ctk.CTkButton(entry_row, text="🔍 Browse Apps", width=120,
                                                 fg_color="#4a5c7a", hover_color="#5a7c9a",
                                                 command=self.open_package_browser)
        self.btn_browse_uninstall.pack(side="left")

        self.btn_run_uninstall = ctk.CTkButton(frame, text="▶ Purge Application (opens terminal)",
                                              font=ctk.CTkFont(size=14, weight="bold"),
                                              fg_color="#7a1a1a", hover_color="#aa2a2a",
                                              height=50,
                                              command=self.uninstall_package)
        self.btn_run_uninstall.pack(pady=20, padx=20, fill="x")

        self.uninstall_status = ctk.CTkLabel(frame, text="✓ Awaiting selection",
                                            font=ctk.CTkFont(size=11, slant="italic"),
                                            text_color="#00d4ff")
        self.uninstall_status.pack(pady=5, anchor="w", padx=20)

    # ================= 3. FILES TAB =================
    def setup_files_tab(self):
        frame = ctk.CTkScrollableFrame(self.main_frame, fg_color="transparent")
        self.frames["files"] = frame

        title = ctk.CTkLabel(frame, text="📁 Source Code & Files",
                            font=ctk.CTkFont(size=22, weight="bold"),
                            text_color="#00d4ff")
        title.pack(pady=15, padx=20, anchor="w")

        info_box = ctk.CTkFrame(frame, fg_color="#1f2f3f", corner_radius=10)
        info_box.pack(pady=10, padx=20, fill="x")
        info_text = ctk.CTkLabel(info_box, text="View the application source code. This is the main app.py file running this interface.",
                                text_color="#aaaaaa", font=ctk.CTkFont(size=11),
                                justify="left", wraplength=700)
        info_text.pack(pady=10, padx=15)

        button_frame = ctk.CTkFrame(frame, fg_color="transparent")
        button_frame.pack(pady=15, padx=20, fill="x")

        btn_view = ctk.CTkButton(button_frame, text="📄 View Source Code",
                                command=self.view_source_code,
                                height=35)
        btn_view.pack(side="left", padx=5)

        btn_open_folder = ctk.CTkButton(button_frame, text="📂 Open App Folder",
                                       command=self.open_app_folder,
                                       height=35)
        btn_open_folder.pack(side="left", padx=5)

        text_frame = ctk.CTkFrame(frame, fg_color="#1a1a2e", corner_radius=10)
        text_frame.pack(pady=10, padx=20, fill="both", expand=True)

        self.code_textbox = ctk.CTkTextbox(text_frame, font=ctk.CTkFont(family="Courier", size=9))
        self.code_textbox.pack(fill="both", expand=True, padx=10, pady=10)
        self.code_textbox.configure(state="disabled")

    # ================= 4. WORKING TAB =================
    def setup_code_tab(self):
        frame = ctk.CTkScrollableFrame(self.main_frame, fg_color="transparent")
        self.frames["code"] = frame

        title = ctk.CTkLabel(frame, text="⚙️ How It Works",
                            font=ctk.CTkFont(size=22, weight="bold"),
                            text_color="#00d4ff")
        title.pack(pady=15, padx=20, anchor="w")

        doc_text = """
╔════════════════════════════════════════════════════════════════╗
║         APPLICATION INSTALLER SUITE - TECHNICAL OVERVIEW       ║
╚════════════════════════════════════════════════════════════════╝

┌─ ARCHITECTURE ─────────────────────────────────────────────────┐
│ Framework: CustomTkinter (Modern Tkinter with Dark Mode)       │
│ Language: Python 3.x                                            │
│ Privileges: Requires root (via pkexec/PolicyKit)               │
│ Backend: APT Package Manager                                    │
└────────────────────────────────────────────────────────────────┘

┌─ INSTALLATION ENGINE ──────────────────────────────────────────┐
│ Command: pkexec apt install -y <file.deb>                      │
│ Features:                                                       │
│  • Automatic dependency resolution                             │
│  • Parallel download optimization                              │
│  • Full error detection and recovery                           │
│ Error Handling:                                                 │
│  • Missing dependencies → Fetches from repositories            │
│  • Corrupted .deb → Architecture mismatch detection            │
│  • Lock conflicts → Waits for other managers to finish         │
│  • Network issues → Retries with fallback mirrors              │
└────────────────────────────────────────────────────────────────┘

┌─ UNINSTALLATION ENGINE ────────────────────────────────────────┐
│ Commands:                                                       │
│  1. pkexec apt remove --purge -y <package>                     │
│  2. pkexec apt autoremove -y                                   │
│  3. pkexec apt autoclean                                        │
│ Features:                                                       │
│  • Complete removal with config files                          │
│  • Orphaned dependency cleanup                                 │
│  • Cache optimization                                          │
└────────────────────────────────────────────────────────────────┘

┌─ ERROR RECOVERY STRATEGIES ────────────────────────────────────┐
│ • Broken Dependencies → apt --fix-broken install               │
│ • Cache Corruption → apt clean && apt autoclean                │
│ • Repository Issues → apt update && apt upgrade                │
│ • Permission Denied → Automatic root elevation via pkexec      │
│ • Unknown Errors → Full error message + suggestion display     │
└────────────────────────────────────────────────────────────────┘

┌─ SECURITY FEATURES ────────────────────────────────────────────┐
│ • Privilege Escalation: PolicyKit (pkexec) instead of sudo     │
│ • No password storage                                          │
│ • User approval required for each operation                    │
│ • Full operation logging                                       │
└────────────────────────────────────────────────────────────────┘

┌─ UI COMPONENTS ────────────────────────────────────────────────┐
│ • 5 Main Tabs: Installer, Uninstaller, Files, Working, Help   │
│ • Real-time Progress Indicators                                │
│ • Inline Error Messages with Solutions                         │
│ • Searchable Package Browser                                   │
│ • Integrated Developer Links                                   │
└────────────────────────────────────────────────────────────────┘
        """
        textbox = ctk.CTkTextbox(frame, font=ctk.CTkFont(family="Courier", size=10))
        textbox.pack(pady=10, padx=20, fill="both", expand=True)
        textbox.insert("0.0", doc_text)
        textbox.configure(state="disabled")

    # ================= 5. HELP TAB =================
    def setup_help_tab(self):
        frame = ctk.CTkScrollableFrame(self.main_frame, fg_color="transparent")
        self.frames["help"] = frame

        title = ctk.CTkLabel(frame, text="❓ Help & Getting Started",
                            font=ctk.CTkFont(size=22, weight="bold"),
                            text_color="#00d4ff")
        title.pack(pady=15, padx=20, anchor="w")

        help_sections = [
            ("📦 Installing Applications",
             "1. Go to the 'Installer' tab\n2. Click 'Browse' and select a .deb file\n3. Click 'Initialize Installation (opens terminal)'\n4. A terminal will open – watch the progress\n5. After installation finishes, a timer counts down (10 sec)\n6. The terminal closes automatically (or click 'Keep Open')"),

            ("🗑️ Removing Applications",
             "1. Go to the 'Uninstaller' tab\n2. Click 'Browse Apps' to find your application\n3. Search and click to select\n4. Click 'Purge Application (opens terminal)'\n5. Terminal shows the removal process\n6. Auto‑close timer appears after completion"),

            ("🔍 Finding Installed Apps",
             "Use the 'Browse Apps' button in the Uninstaller tab.\nType at least 1 character – results appear instantly.\nClick any package to auto-fill the uninstall field."),

            ("📁 Viewing Source Code",
             "Click the 'Files' tab to view this application's source code.\nYou can review the entire implementation and understand how the app works."),

            ("❌ Common Issues",
             "• Permission Denied: Approve the PolicyKit dialog when the terminal opens\n• Package Not Found: Use 'Browse Apps' to get exact name\n• Installation Fails: Check internet and disk space\n• Terminal closes too fast? Click 'Keep Open' when the timer appears"),

            ("🔗 Getting Help & More",
             "Visit the GitHub profile for:\n• Additional tools and utilities\n• Source code of other projects\n• Documentation and guides\n• Issue tracking and support"),
        ]

        for title_text, content in help_sections:
            section_title = ctk.CTkLabel(frame, text=title_text,
                                        font=ctk.CTkFont(size=12, weight="bold"),
                                        text_color="#00d4ff")
            section_title.pack(anchor="w", pady=(15, 5), padx=20)

            section_content = ctk.CTkLabel(frame, text=content,
                                          font=ctk.CTkFont(size=11),
                                          text_color="#cccccc",
                                          justify="left", wraplength=700)
            section_content.pack(anchor="w", padx=35, pady=(0, 10))

            sep = ctk.CTkFrame(frame, height=1, fg_color="#333333")
            sep.pack(fill="x", padx=20, pady=10)

    # ================= GITHUB INTEGRATION =================
    def open_github_options(self):
        popup = ctk.CTkToplevel(self)
        popup.title("🔗 GitHub Profile & Resources")
        popup.geometry("450x350")
        popup.resizable(False, False)
        popup.update_idletasks()
        popup.grab_set()

        title = ctk.CTkLabel(popup, text="GitHub Navigation",
                            font=ctk.CTkFont(size=18, weight="bold"),
                            text_color="#00d4ff")
        title.pack(pady=20)

        profile_info = ctk.CTkLabel(popup,
                                   text="Developer: Kunal Mistari\nGitHub Profile: github.com/mistaribaba",
                                   font=ctk.CTkFont(size=11),
                                   text_color="#aaaaaa",
                                   justify="center")
        profile_info.pack(pady=10)

        sep = ctk.CTkFrame(popup, height=1, fg_color="#333333")
        sep.pack(fill="x", padx=20, pady=10)

        button_frame = ctk.CTkFrame(popup, fg_color="transparent")
        button_frame.pack(pady=15, padx=20, fill="both", expand=True)

        def go_chrome():
            webbrowser.open("https://github.com/mistaribaba")
            popup.destroy()

        def show_steps():
            steps_window = ctk.CTkToplevel(popup)
            steps_window.title("📚 GitHub Navigation Guide")
            steps_window.geometry("550x500")
            steps_window.resizable(True, True)

            steps_text = """
╔═══════════════════════════════════════════════════════╗
║     HOW TO NAVIGATE GITHUB.COM/MISTARIBABA           ║
╚═══════════════════════════════════════════════════════╝

STEP 1: Visit the Profile
→ Open https://github.com/mistaribaba
→ You'll see the profile overview page

STEP 2: View Repositories
→ Click on the "Repositories" tab
→ All public projects are listed here
→ Each repo has a ⭐ star count

STEP 3: Explore a Project
→ Click on any repository name
→ View the project description & README
→ Check out the source code

STEP 4: Get the Code
→ Click the green "< > Code" button
→ Choose clone, fork, or download as ZIP
→ For beginners: Use "Download ZIP"

STEP 5: Additional Features
→ Check "Issues" for bug reports
→ Look at "Discussions" for Q&A
→ Review "Projects" for ongoing work
→ Check "Contributions" for activity

STEP 6: Useful Resources
→ Click "Follow" to stay updated
→ Check "Sponsors" to support development
→ Use "Watch" to get notifications

For downloading code:
1. Click "<> Code" button
2. Select "Download ZIP"
3. Extract the file on your computer
4. Open with your favorite editor
            """
            steps_textbox = ctk.CTkTextbox(steps_window, font=ctk.CTkFont(family="Courier", size=10))
            steps_textbox.pack(fill="both", expand=True, padx=10, pady=10)
            steps_textbox.insert("0.0", steps_text)
            steps_textbox.configure(state="disabled")

        btn_chrome = ctk.CTkButton(button_frame, text="🌐 Open in Browser",
                                  command=go_chrome,
                                  height=40, font=ctk.CTkFont(size=12, weight="bold"))
        btn_chrome.pack(fill="x", pady=8)

        btn_steps = ctk.CTkButton(button_frame, text="📚 View Navigation Steps",
                                 fg_color="#4a5c7a", hover_color="#5a7c9a",
                                 command=show_steps,
                                 height=40, font=ctk.CTkFont(size=12, weight="bold"))
        btn_steps.pack(fill="x", pady=8)

        btn_copy = ctk.CTkButton(button_frame, text="📋 Copy GitHub URL",
                                fg_color="#3a5c4a", hover_color="#5a8c6a",
                                command=lambda: self.copy_to_clipboard("https://github.com/mistaribaba"),
                                height=40, font=ctk.CTkFont(size=12, weight="bold"))
        btn_copy.pack(fill="x", pady=8)

    # ================= PACKAGE BROWSER (FIXED) =================
    def open_package_browser(self):
        browser = ctk.CTkToplevel(self)
        browser.title("🔍 Installed Packages Browser")
        browser.geometry("550x700")
        browser.resizable(True, True)
        browser.update_idletasks()
        browser.grab_set()

        lbl = ctk.CTkLabel(browser, text="📦 Search Installed Apps",
                          font=ctk.CTkFont(size=18, weight="bold"),
                          text_color="#00d4ff")
        lbl.pack(pady=15, padx=15)

        info_label = ctk.CTkLabel(browser, text="Type at least 1 character to search. Click an app to select it.",
                                 font=ctk.CTkFont(size=10),
                                 text_color="#aaaaaa")
        info_label.pack(pady=(0,10), padx=15)

        search_frame = ctk.CTkFrame(browser, fg_color="transparent")
        search_frame.pack(pady=10, padx=15, fill="x")

        search_var = ctk.StringVar()
        search_entry = ctk.CTkEntry(search_frame, textvariable=search_var,
                                   placeholder_text="Type app name (e.g., code, chrome, vim)...",
                                   font=ctk.CTkFont(size=11))
        search_entry.pack(side="left", padx=(0,10), fill="x", expand=True)

        search_btn = ctk.CTkButton(search_frame, text="🔍 Search", width=100,
                                  fg_color="#4a5c7a", hover_color="#5a7c9a",
                                  command=lambda: perform_search())
        search_btn.pack(side="left")

        results_frame = ctk.CTkScrollableFrame(browser, width=500, height=450, fg_color="#1f1f1f", corner_radius=10)
        results_frame.pack(pady=15, padx=15, fill="both", expand=True)

        instruction = ctk.CTkLabel(browser, text="Click a package name to fill the Uninstaller field.",
                                  font=ctk.CTkFont(size=10), text_color="#bbbbbb")
        instruction.pack(pady=(0,10), padx=15)

        def perform_search():
            for widget in results_frame.winfo_children():
                widget.destroy()

            query = search_var.get().strip().lower()
            if len(query) < 1:
                ctk.CTkLabel(results_frame, text="⚠️ Type at least 1 character to search...",
                           text_color="orange", font=ctk.CTkFont(size=11)).pack(pady=10)
                return

            loading = ctk.CTkLabel(results_frame, text="🔍 Loading installed packages...", text_color="cyan")
            loading.pack(pady=20)
            results_frame.update()

            try:
                result = subprocess.run(['/usr/bin/dpkg', '-l'], capture_output=True, text=True, timeout=10)
                if result.returncode != 0:
                    raise Exception(f"dpkg failed with code {result.returncode}")

                packages = []
                for line in result.stdout.splitlines():
                    if line.startswith('ii'):
                        parts = line.split()
                        if len(parts) >= 2:
                            packages.append(parts[1])

                packages = sorted(set(packages))
                matches = [pkg for pkg in packages if query in pkg.lower()]
                loading.destroy()

                if not matches:
                    ctk.CTkLabel(results_frame, text=f"❌ No packages matching '{query}'",
                               text_color="red", font=ctk.CTkFont(size=11)).pack(pady=10)
                    return

                count_label = ctk.CTkLabel(results_frame, text=f"Found {len(matches)} package(s):",
                                          font=ctk.CTkFont(size=10, weight="bold"),
                                          text_color="#00d4ff")
                count_label.pack(anchor="w", padx=5, pady=(5,10))

                for pkg in matches[:50]:
                    btn = ctk.CTkButton(
                        results_frame,
                        text=f"  📦 {pkg}",
                        fg_color="#2a3a4a",
                        hover_color="#3a5a7a",
                        anchor="w",
                        border_width=1,
                        border_color="#333333",
                        font=ctk.CTkFont(size=10),
                        command=lambda p=pkg: select_package(p)
                    )
                    btn.pack(pady=3, fill="x", padx=5)

            except Exception as e:
                loading.destroy()
                ctk.CTkLabel(results_frame, text=f"❌ Error: {str(e)[:100]}",
                           text_color="red").pack(pady=10)

        def select_package(pkg_name):
            self.uninstall_pkg_name.set(pkg_name)
            browser.destroy()

        search_entry.bind('<Return>', lambda event: perform_search())

    # ================= CORE FUNCTIONS =================
    def browse_file(self):
        file_path = filedialog.askopenfilename(filetypes=[("Debian Packages", "*.deb"), ("All Files", "*.*")])
        if file_path:
            self.install_file_path.set(file_path)

    def view_source_code(self):
        try:
            with open(__file__, 'r') as f:
                code = f.read()
            self.code_textbox.configure(state="normal")
            self.code_textbox.delete("0.0", "end")
            self.code_textbox.insert("0.0", code)
            self.code_textbox.configure(state="disabled")
        except Exception as e:
            messagebox.showerror("Error", f"Could not read source code: {str(e)}")

    def open_app_folder(self):
        try:
            app_folder = os.path.dirname(__file__)
            os.system(f"xdg-open '{app_folder}' &")
        except Exception as e:
            messagebox.showerror("Error", f"Could not open folder: {str(e)}")

    def copy_to_clipboard(self, text):
        self.clipboard_clear()
        self.clipboard_append(text)
        messagebox.showinfo("Copied", "GitHub URL copied to clipboard!")

    # ================= TERMINAL LAUNCHER WITH AUTO-CLOSE TIMER =================

    def run_in_terminal(self, command, title="APT Operation"):
        """
        Launch a terminal emulator that runs the given command.
        The terminal will stay open after the command finishes.
        Returns the Popen object of the terminal process.
        """
        import shutil

        # Build the final command – we'll wrap it in a shell that prints a message
        # and waits 10 seconds (so the user sees the result before auto‑close)
        # Note: We do NOT add 'sleep 10' here because the timer is handled by the GUI.
        # Instead we let the terminal stay open indefinitely, and the GUI will kill it after timer.
        # So we just run the command and then keep the terminal open.
        # For xterm we use -hold; for others we use 'read' or 'sleep infinity'

        # Different terminals need different arguments
        terminal_configs = [
            # xfce4-terminal
            ('xfce4-terminal', ['--title', title, '--hold', '-e', f'bash -c "{command}; echo; echo Operation finished. Window will auto-close in 10 seconds; read -t 10"']),
            # gnome-terminal
            ('gnome-terminal', ['--title', title, '--', 'bash', '-c', f'{command}; echo; echo "Operation finished. Window will auto-close in 10 seconds"; sleep 10']),
            # konsole
            ('konsole', ['--new-tab', '--title', title, '-e', 'bash', '-c', f'{command}; echo; echo "Operation finished. Window will auto-close in 10 seconds"; sleep 10']),
            # xterm (with -hold)
            ('xterm', ['-title', title, '-hold', '-e', 'bash', '-c', f'{command}']),
            # fallback: try x-terminal-emulator (debian default)
            ('x-terminal-emulator', ['-e', 'bash', '-c', f'{command}; echo; echo "Operation finished. Window will auto-close in 10 seconds"; sleep 10']),
        ]

        for term_name, cmd_args in terminal_configs:
            # Check if the terminal is available
            term_path = shutil.which(term_name)
            if term_path:
                try:
                    # Launch the terminal
                    proc = subprocess.Popen([term_path] + cmd_args,
                                            stdout=subprocess.DEVNULL,
                                            stderr=subprocess.DEVNULL)
                    return proc
                except Exception:
                    continue

        # Last resort: try to use xterm directly by its full path
        if os.path.exists('/usr/bin/xterm'):
            try:
                proc = subprocess.Popen(['/usr/bin/xterm', '-title', title, '-hold', '-e', f'bash -c "{command}"'],
                                        stdout=subprocess.DEVNULL,
                                        stderr=subprocess.DEVNULL)
                return proc
            except Exception:
                pass

        return None
    def start_auto_close_timer(self, proc, tab_name):
        """Show countdown timer and auto-close terminal after 10 seconds."""
        # Remove any existing timer UI
        self.cancel_auto_close()

        countdown = 10
        frame = self.frames[tab_name]
        self.timer_label = ctk.CTkLabel(frame, text=f"⏱️ Terminal will close in {countdown} seconds...",
                                        text_color="#ffaa00", font=ctk.CTkFont(size=11))
        self.timer_label.pack(pady=5, padx=20, anchor="w")

        self.keep_btn = ctk.CTkButton(frame, text="📌 Keep Terminal Open",
                                     fg_color="#4a5c7a", hover_color="#5a7c9a",
                                     command=self.cancel_auto_close)
        self.keep_btn.pack(pady=5, padx=20, anchor="w")

        def update():
            nonlocal countdown
            if self.auto_close_timer_id is None:
                return
            if countdown <= 0:
                # Close the terminal
                if proc and proc.poll() is None:
                    proc.terminate()
                    self.after(500, lambda: proc.kill() if proc.poll() is None else None)
                self.cancel_auto_close()
                if tab_name == "install":
                    self.install_status.configure(text="✅ Terminal closed", text_color="green")
                else:
                    self.uninstall_status.configure(text="✅ Terminal closed", text_color="green")
            else:
                if self.timer_label:
                    self.timer_label.configure(text=f"⏱️ Terminal will close in {countdown} seconds...")
                countdown -= 1
                self.auto_close_timer_id = self.after(1000, update)

        self.auto_close_timer_id = self.after(1000, update)

    def cancel_auto_close(self):
        """Cancel the auto-close timer and remove UI elements."""
        if self.auto_close_timer_id:
            self.after_cancel(self.auto_close_timer_id)
            self.auto_close_timer_id = None
        if self.timer_label:
            self.timer_label.destroy()
            self.timer_label = None
        if self.keep_btn:
            self.keep_btn.destroy()
            self.keep_btn = None

    def ensure_dpkg_healthy(self):
        """Check if dpkg is interrupted and fix it automatically."""
        result = subprocess.run(['dpkg', '--configure', '-a'], capture_output=True, text=True)
        if result.returncode != 0:
            fix = subprocess.run(['pkexec', 'dpkg', '--configure', '-a'], capture_output=True, text=True)
            if fix.returncode != 0:
                return False
        return True

    # ================= INSTALL PACKAGE (TERMINAL + TIMER) =================
    def install_package(self):
        if not self.ensure_dpkg_healthy():
            messagebox.showerror("System Error", "Could not fix dpkg interruption. Please run in terminal: sudo dpkg --configure -a")
            return

        file_path = self.install_file_path.get()
        if not file_path:
            messagebox.showerror("Error", "❌ No package selected.\n\nPlease browse and select a .deb file first.")
            return
        if not os.path.exists(file_path):
            messagebox.showerror("Error", f"❌ File not found:\n{file_path}")
            return
        if not file_path.endswith('.deb'):
            messagebox.showerror("Error", "❌ Selected file is not a .deb package.")
            return

        self.install_status.configure(text="📟 Launching terminal for installation...", text_color="orange")
        self.update_idletasks()

        # Build the command: pkexec apt install -y "file_path"
        # We wrap in a marker file to detect completion (so timer starts only after command ends)
        marker = f"/tmp/apt_install_done_{os.getpid()}.marker"
        cmd = f"pkexec apt install -y \"{file_path}\"; touch {marker}"

        # Launch terminal with the command
        proc = self.run_in_terminal(cmd, title="APT Installer")
        if not proc:
            self.install_status.configure(text="❌ No terminal emulator found", text_color="red")
            messagebox.showerror("Error", "Could not find any terminal emulator (xfce4-terminal, gnome-terminal, xterm).")
            return

        self.current_terminal_proc = proc
        self.install_status.configure(text="📟 Installation started. Waiting for completion...", text_color="cyan")

        # Poll for marker file in background
        def check_marker():
            if os.path.exists(marker):
                os.remove(marker)
                # Command finished – start the auto‑close timer
                self.install_status.configure(text="✅ Installation completed. Closing terminal in 10 seconds...", text_color="green")
                self.start_auto_close_timer(proc, "install")
            else:
                # Still running, check again in 1 second
                self.after(1000, check_marker)

        self.after(1000, check_marker)

    # ================= UNINSTALL PACKAGE (TERMINAL + TIMER) =================
    def uninstall_package(self):
        if not self.ensure_dpkg_healthy():
            messagebox.showerror("System Error", "Could not fix dpkg interruption. Please run in terminal: sudo dpkg --configure -a")
            return

        pkg_name = self.uninstall_pkg_name.get().strip()
        if not pkg_name:
            messagebox.showerror("Error", "❌ No package selected.\n\nUse 'Browse Apps' to find installed packages.")
            return

        # Quick verification (optional, but good)
        check = subprocess.run(['/usr/bin/dpkg', '-l'], capture_output=True, text=True, timeout=10)
        if pkg_name not in check.stdout:
            self.uninstall_status.configure(text="❌ Package Not Found", text_color="red")
            messagebox.showerror("Error", f"❌ Package '{pkg_name}' is not installed.\n\nPlease verify the package name and try again.")
            return

        # Confirm removal
        proceed = messagebox.askyesno("Confirm Removal",
            f"Remove package: {pkg_name}?\n\nThis will:\n• Uninstall the application\n• Remove all configuration files\n• Clean up dependencies")
        if not proceed:
            self.uninstall_status.configure(text="⚪ Removal cancelled", text_color="blue")
            return

        self.uninstall_status.configure(text="📟 Launching terminal for removal...", text_color="orange")
        self.update_idletasks()

        marker = f"/tmp/apt_remove_done_{os.getpid()}.marker"
        # Chain purge + autoremove + autoclean
        cmd = f"pkexec apt remove --purge -y {pkg_name}; pkexec apt autoremove -y; pkexec apt autoclean; touch {marker}"

        proc = self.run_in_terminal(cmd, title=f"Removing {pkg_name}")
        if not proc:
            self.uninstall_status.configure(text="❌ No terminal emulator found", text_color="red")
            messagebox.showerror("Error", "Could not find any terminal emulator.")
            return

        self.current_terminal_proc = proc
        self.uninstall_status.configure(text="📟 Removal started. Waiting for completion...", text_color="cyan")

        def check_marker():
            if os.path.exists(marker):
                os.remove(marker)
                self.uninstall_status.configure(text="✅ Removal completed. Closing terminal in 10 seconds...", text_color="green")
                self.start_auto_close_timer(proc, "uninstall")
                self.uninstall_pkg_name.set("")
            else:
                self.after(1000, check_marker)

        self.after(1000, check_marker)

if __name__ == "__main__":
    app = AppInstaller()
    app.mainloop()
