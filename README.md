CS 489 – Topics in CS: Video Game Development (Spring 2025)
Assignment #4 – Completing and Improving Match-3 Jewels
Grade: 5 points (which is 5% of the semester)
Due Date: Set on Moodle.
Late Submissions: There is a cumulative penalty of -0.5 points per day after the deadline.
Assignment
You may work on this assignment in teams of up to two people (yes, you can also work
alone if you prefer). In this assignment, you will have to complete and make improvements on
our Match-3 Jewels game implementation. For this one, you must clone the professor's Match-3
repository (link available on Moodle) as a starting point.
First and foremost, you must complete the game. In the course materials for Match-3, we
haven’t finished all the features and code in there. Therefore, you must complete the Timer,
Game-Over screen, “Level-up”, and Sounds for this game. You can use the code in the materials
as guide for this, just remember to adapt it (since our classroom code is slightly different). Just
like in the materials, you must use a tween effect for the “level up” that is really noticeable. When
the timer runs out, you must switch to the Game Over screen and display the score and level
reached (with the option for replay). Completing the game is 50% of your grade in this
assignment, and it must be done before any of the improvements bellow.
Second, you need to implement the following improvements for the game:
• Change the color of the “explosions” (particles) to match the color of the Jewels/Gems on
the tile it occurs. For example, if you match 3 red gems and 4 green ones on the same
click, then the explosions on the red gems should look red-ish and the explosions on the
green gems should look green-ish.
• Add “chain/combo” bonus scoring, when multiple matches happen without player click.
For example, you match some tiles and when the new ones fall into place there are
additional matches *chain/combo 2*; after if the new-new ones also created additional
matches *chain/combo 3*, and so on. You also need to use Tweens to do an “animation
text” of the chain/combo to highlight that there are chain/combos happening.
• Add one “coin” per level, which will vanish if a match is adjacent to it. The coin should
give bonus scoring.
Grading Criteria
The number of fully functioning features you implement will determine your grade:
• Completing the game code: 50%
• Implementing one improvement: 60%
• Implementing two improvements: 80%
• Implementing three improvements: 100%
Partially functional implementations will also be considered, so make your best effort.
Generated AI tools are forbidden, as detailed in our syllabus (suspect code will be penalized)
