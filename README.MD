<p align="center">
  <a href="https://github.com/swiftly-solution/swiftly">
    <img src="https://cdn.swiftlycs2.net/swiftly-logo.png" alt="SwiftlyLogo" width="80" height="80">
  </a>

  <h3 align="center">[Swiftly] Quests</h3>

  <p align="center">
    <strong>Quests</strong> is a plugin designed to manage quests for players in CS2 used Swiftly. It provides a straightforward way to create, configure, and manage quests directly from a configuration file, making it easy to expand your game with new content.
    <br/>
  </p>
</p>
    <h2>🛠️ Requirements</h2>
    <ul>
        <li><a href="https://github.com/swiftly-solution/shop-core/releases" target="_blank">Shop Core</a></li>
    </ul>
    <h2>✨ Features</h2>
    <ul>
        <li><strong>Simple Configuration:</strong> Define quests easily using configuration files.</li>
        <li><strong>Dynamic Quest Creation:</strong> Supports various quest types like fetch, kill, and exploration quests.</li>
        <li><strong>Automatic Quest Tracking:</strong> Monitors player progress and quest states in real-time.</li>
        <li><strong>Player Rewards:</strong> Grants experience points, items, and other rewards upon quest completion.</li>
        <li><strong>Modular Design:</strong> Integrates seamlessly with other systems using player objects or player IDs.</li>
    </ul>
    <hr>
    <h2>⚙️ Configuration Guide</h2>
    <p>Quests allow you to track player progress on various quests and customize requirements for each quest type. This document explains the structure and required fields for configuring quests.</p>
    <h4>Predefined Quests</h4>
    <p>The following table lists all predefined quests, their goals, and the rewards granted upon completion:</p>
    <table border="1">
        <thead>
            <tr>
                <th>Quest ID</th>
                <th>Progress Key</th>
                <th>Goal</th>
                <th>Reward</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>planter_1</td>
                <td>planted_bombs</td>
                <td>5</td>
                <td>500 shop points</td>
            </tr>
            <tr>
                <td>planter_2</td>
                <td>planted_bombs</td>
                <td>50</td>
                <td>5000 shop points</td>
            </tr>
            <tr>
                <td>defuser_1</td>
                <td>defused_bombs</td>
                <td>5</td>
                <td>500 shop points</td>
            </tr>
            <tr>
                <td>defuser_2</td>
                <td>defused_bombs</td>
                <td>5</td>
                <td>500 shop points</td>
            </tr>
            <tr>
                <td>striker_1</td>
                <td>dealed_damages</td>
                <td>500</td>
                <td>500 shop points</td>
            </tr>
            <tr>
                <td>striker_2</td>
                <td>dealed_damages</td>
                <td>5000</td>
                <td>500 shop points</td>
            </tr>
            <tr>
                <td>killer_1</td>
                <td>killed_enemies</td>
                <td>5</td>
                <td>500 shop points</td>
            </tr>
            <tr>
                <td>killer_2</td>
                <td>killed_enemies</td>
                <td>50</td>
                <td>500 shop points</td>
            </tr>
            <tr>
                <td>assister_1</td>
                <td>assisted_killed_enemies</td>
                <td>5</td>
                <td>500 shop points</td>
            </tr>
            <tr>
                <td>assister_2</td>
                <td>assisted_killed_enemies</td>
                <td>50</td>
                <td>500 shop points</td>
            </tr>
            <tr>
                <td>winner_1</td>
                <td>won_rounds</td>
                <td>5</td>
                <td>500 shop points</td>
            </tr>
            <tr>
                <td>winner_2</td>
                <td>won_rounds</td>
                <td>50</td>
                <td>500 shop points</td>
            </tr>
            <tr>
                <td>mvp_1</td>
                <td>mvp_rounds</td>
                <td>5</td>
                <td>500 shop points</td>
            </tr>
            <tr>
                <td>mvp_2</td>
                <td>mvp_rounds</td>
                <td>50</td>
                <td>500 shop points</td>
            </tr>
        </tbody>
    </table>
    <hr>
    <h2>Quest-Specific Requirements</h2>
    <p>Each quest tracks a specific progress key with additional fields to filter player actions. Below are the required and optional fields for each progress key:</p>
    <h3>1. planted_bombs</h3>
    <table border="1">
        <thead>
            <tr>
                <th>Field</th>
                <th>Description</th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>site</td>
                <td>Site number (22 = A, 23 = B)</td>
                <td>Integer</td>
            </tr>
            <tr>
                <td>map</td>
                <td>Map name(s)</td>
                <td>String or List of Strings</td>
            </tr>
        </tbody>
    </table>
    <h3>2. defused_bombs</h3>
    <table border="1">
        <thead>
            <tr>
                <th>Field</th>
                <th>Description</th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>site</td>
                <td>Site number (22 = A, 23 = B)</td>
                <td>Integer</td>
            </tr>
            <tr>
                <td>map</td>
                <td>Map name(s)</td>
                <td>String or List of Strings</td>
            </tr>
        </tbody>
    </table>
    <h3>3. dealed_damages</h3>
    <table border="1">
        <thead>
            <tr>
                <th>Field</th>
                <th>Description</th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>map</td>
                <td>Map name(s)</td>
                <td>String or List of Strings</td>
            </tr>
            <tr>
                <td>weapon</td>
                <td>Weapon name(s)</td>
                <td>String or List of Strings</td>
            </tr>
            <tr>
                <td>team</td>
                <td>Team (2 = T, 3 = CT)</td>
                <td>Integer</td>
            </tr>
        </tbody>
    </table>
    <h3>4. killed_enemies</h3>
    <table border="1">
        <thead>
            <tr>
                <th>Field</th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>map</td>
                <td>String or List of Strings</td>
            </tr>
            <tr>
                <td>weapon</td>
                <td>String or List of Strings</td>
            </tr>
            <tr>
                <td>team</td>
                <td>Integer</td>
            </tr>
            <tr>
                <td>assistedflash</td>
                <td>Boolean</td>
            </tr>
            <tr>
                <td>headshot</td>
                <td>Boolean</td>
            </tr>
            <tr>
                <td>noscope</td>
                <td>Boolean</td>
            </tr>
            <tr>
                <td>thrusmoke</td>
                <td>Boolean</td>
            </tr>
            <tr>
                <td>distance</td>
                <td>Integer/Float</td>
            </tr>
            <tr>
                <td>hitgroup</td>
                <td>Integer</td>
            </tr>
        </tbody>
    </table>
    <h3>5. assisted_killed_enemies</h3>
    <table border="1">
        <thead>
            <tr>
                <th>Field</th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>map</td>
                <td>String or List of Strings</td>
            </tr>
        </tbody>
    </table>
    <h3>6. won_rounds</h3>
    <table border="1">
        <thead>
            <tr>
                <th>Field</th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>map</td>
                <td>String or List of Strings</td>
            </tr>
            <tr>
                <td>team</td>
                <td>Integer</td>
            </tr>
        </tbody>
    </table>
    <h3>7. mvp_rounds</h3>
    <table border="1">
        <thead>
            <tr>
                <th>Field</th>
                <th>Type</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>map</td>
                <td>String or List of Strings</td>
            </tr>
            <tr>
                <td>team</td>
                <td>Integer</td>
            </tr>
        </tbody>
    </table>
    <hr>
    <h2>Reward Type Options</h2>
    <p>The <code>reward.type</code> field can have the following values:</p>
    <ul>
        <li><strong>shop_points</strong> – Grants shop points to the player.</li>
        <li><strong>shop_items</strong> – Grants specific items to the player.</li>
    </ul>
    <hr>
    <h2>⚠️ Customization</h2>
    <p>You can modify the reward and progress conditions for each quest by adjusting the fields in the configuration. The system is designed to be flexible, so you can define your own quests and set the requirements as needed.</p>
    <pre><code>
        {
            "id": "striker_2",
            "progress_key": "dealed_damages",
            "title": "quests.events.striker_2.title",
            "description": "quests.events.striker.description",
            "goal": 5000,
            "reward": {
                "type": "shop_points",
                "value": 500
            },
            "require": {
                "map":"de_inferno",
                "weapon": "weapon_ak47"
            }           
        },    
    <code></pre>
    <hr>
    <h2>🌍 Example of Translations</h2>
    <p>In your translation file, you can define the quest names and descriptions like this:</p>
    <pre><code>
{
    "events.planter_1.title": {
        "en": "Planter I"
    },
    "events.planter_2.title": {
        "en": "Planter II"
    },
    "events.planter.description": {
        "en": "You have to plant {QUEST_GOAL} bombs."
    },
    "events.defuser_1.title": {
        "en": "Defuser I"
    },
    "events.defuser_2.title": {
        "en": "Defuser II"
    },
    "events.defuser.description": {
        "en": "You have to defuse {QUEST_GOAL} bombs."
    },
    "events.striker_1.title": {
        "en": "Striker I"
    },
    "events.striker_2.title": {
        "en": "Striker II"
    },
    "events.striker.description": {
        "en": "You have to deal {QUEST_GOAL} damage."
    }
}
    </code></pre>
