### **App Summary: Planetary Presence**
Planetary Presence is a gamified travel and cultural exploration application. It encourages users to explore the world by completing location-based "quests" in various categories (Nature, Culture, Food, Landmarks). Quests are crowd-sourced and community-voted, with points dynamically assigned based on rarity and difficulty. Users earn points to climb local, city, country, and global leaderboards, with a 2x point bonus applied to quests completed in their designated "Home City."

### **Global Navigation Architecture**
The app is anchored by a persistent bottom navigation bar containing five primary destinations. The central button is visually distinct to encourage the primary action of the app (recording a quest).
*   **Navigation Items:** `[ Map ]`, `[ Quests ]`, `[ + (Record) ]`, `[ Stats ]`, `[ Profile ]`

---

### **Screen Breakdown & Required Features**

#### **1. Map Screen (Homepage)**
This acts as the default landing page, focusing on geographic discovery.
*   **Features:**
    *   **Interactive Map:** Displays the user's current location (e.g., Guelph) or a selected city (e.g., Toronto, Mississauga) with dropped pins indicating available quests.
    *   **Pin Popups:** Tapping a pin reveals a quick summary of the quest (e.g., a "New!" badge).
    *   **Split-View Mode:** An option to view the map on the top half of the screen and a list of nearby quests on the bottom half.
    *   **Quest List UI (in Split-View):** Displays quest titles, point values (e.g., "See a bird 10 pts", "Eat a bird 50 pts"), and badges ("New!").
    *   **Progress Tracker:** A footer in the split-view showing local completion progress (e.g., "3/100 quests completed in Toronto").
    *   **Filtering (From Text):** A side menu to filter pins by completion status, friends' activity, popularity, and categories.

#### **2. Quests Screen**
Accessed via the second navigation icon, this screen manages the user's quest queue and community voting.
*   **Features:**
    *   **Tabs:** Two main tabs at the bottom: **Active** and **Pending**.
    *   **Active Tab:** A list of quests the user is currently tracking or has available nearby.
    *   **Pending Tab:** A list of user-submitted community quests that require voting to become officially active in the game.
    *   **List Items:** Each item displays the quest name, point value, and an icon/checkbox.

#### **3. Record / Add Quest Flow (+ Button)**
Accessed via the prominent central navigation button. This is a multi-step flow for logging a completed quest or creating a new one.
*   **Screen 3a: Category Selection**
    *   A grid layout allowing users to select the domain of their quest: **Landmark**, **Food**, **Nature**, or **Culture**.
*   **Screen 3b: Search & Select**
    *   A search bar at the top to find existing quests within the chosen category.
    *   A scrollable list of quests matching the search (e.g., "eat a bird 10 pts") with selection radio buttons/circles.
*   **Screen 3c: Submit/Record Details**
    *   **Header:** Displays the selected quest and its point value (e.g., "Visit the CN Tower 150pts").
    *   **Input Fields:**
        *   **Add Friends:** Tag friends who participated.
        *   **Tagline:** A short description or comment about the experience.
        *   **Rating/Difficulty:** User input to help dynamically adjust point values.
        *   **Add Picture:** Upload photographic proof.
    *   **Primary CTA:** A large "Record" button to finalize the submission (which then redirects the user back to the active Quests page).

#### **4. Stats Screen**
Accessed via the fourth navigation icon, dedicated to competitive gamification and data visualization.
*   **Features:**
    *   **Dynamic Leaderboards:**
        *   **Points Leaderboard:** Lists top users by points.
        *   **Quest Leaderboard:** Lists top users by number of quests completed.
        *   **Scope Filter:** A dropdown/toggle next to the leaderboard titles to filter rankings by **Local**, **City**, **Country**, or **Globe**.
        *   Displays rank, username (e.g., "John Pork", "Le Goat James"), and score. Includes a "Load More..." button.
    *   **Charts (fl_charts integration):**
        *   A line chart comparing the user's XP against their friends' XP.
        *   **Timeframe Filter:** Options to view chart data by **Day**, **Week**, or **Month**.

#### **5. Profile Screen**
Accessed via the fifth navigation icon, displaying user identity and personal achievements.
*   **Features:**
    *   **Header:** User avatar, Username, total points, and join date (e.g., "5001 pts Since 2017").
    *   **Home City Tag:** Displays the user's base location (e.g., "Home City: Guelph"), which activates the 2x point multiplier for quests in that area.
    *   **Activity Graph:** A GitHub-style contribution calendar using green squares to visualize daily quest completion consistency.
    *   **Personal Records:** Text stats displaying milestones like "Most points in a day" and "Most quests in a day".
    *   **Settings Access:** A gear icon leading to the settings page.

#### **6. Settings Screen**
Accessed from the Profile screen.
*   **Features:**
    *   UI toggles for app preferences, specifically showing a **Dark Mode** toggle.
    *   Placeholders for other standard account settings ("etc.").
