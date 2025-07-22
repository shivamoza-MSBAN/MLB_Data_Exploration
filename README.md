# ⚾ MLB Player Data Analysis — SQL Portfolio Project

## Project Overview

This project simulates the role of a **Data Analyst for Major League Baseball (MLB)**. The goal was to explore and analyze comprehensive historical data about MLB players—ranging from their educational background to salary trends, career trajectories, and player physical attributes.

This project applies **advanced SQL techniques** like CTEs, window functions, aggregations, and joins to extract and summarize meaningful insights that could support decision-making in player scouting, salary structuring, and performance analytics.

---

## 🧪 Dataset Scope

- **Players**: Player demographics, debut/final game, handedness (bat/throw), height, and weight.
- **Salaries**: Annual player salaries across years and teams.
- **Schools & School Details**: College history of players.
- **Teams**: Franchises players played for during their careers.

---

## Analysis Breakdown

###  1. School Analysis
- **School Trends by Decade**: 
  - Player-producing schools increased from just **2 in the 1860s** to **372 by the 2000s**.
  - A noticeable dip was observed in the **1940s**, potentially due to World War II disruptions.
  
- **Top 5 Schools by Player Count**:
  - University of Texas at Austin (107)
  - University of Southern California (105)
  - Arizona State University (101)
  - Stanford University (86)
  - University of Michigan (76)

### 2. Salary Analysis
- **Top 20% of Teams by Average Spending**:
  - Highest spender: **San Francisco Giants (SFG)** – $143.5M
  - Lowest within top 20%: **Philadelphia Phillies (PHI)** – $66M

- **Cumulative Spending Over Time**:
  - Trend of increasing team-level spending was calculated year-over-year.
  - First year each team crossed **$1 Billion cumulative spend** was tracked.

### 3. Player Career Analysis
- **Career Length Calculations**:
  - Birth-to-debut and debut-to-retirement ages were calculated.
  - Players ranked by career length.

- **Loyalty Insight**:
  - **19 players** started and ended their careers on the **same team**, with careers lasting **over 10 years**.

### 4. Player Attribute Comparison
- **Batting Hand Distribution**:
  - On average, **60% of players bat right-handed**, across all teams.
  - Notably, **18.5% of SFG players** were switch hitters (bat both).

- **Physical Trends Over Time**:
  - Average **height and weight at debut** were tracked and compared by decade.
  - Decade-over-decade physical evolution was identified.

---

## Key SQL Techniques Used

- Common Table Expressions (CTEs)
- Window Functions (ROW_NUMBER, LAG)
- Aggregations & Grouping
- Joins (INNER, LEFT)
- Subqueries & Filtering
- Conditional Logic (CASE WHEN)

---

## Tools

- **SQL**: MySQL Workbench
- **Data Source**: MLB Historical Dataset (simulated)
- **Platform**: Local environment + GitHub for portfolio sharing

---

## Visual Outputs

> Sample images and SQL snippets have been added in the project folder to demonstrate real-time query results and EDA outputs.

---

## Author

**Shivam Oza**  

