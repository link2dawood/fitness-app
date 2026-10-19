# Original exercise starter library

The 366 exercise demonstrations in this implementation are drawn and animated by
`lib/widgets/exercises/exercise_avatar.dart`. The character artwork and motion
loops were created in this project. No animation files, GIFs, or character artwork
from the reference app are bundled or downloaded.

The catalog is in `lib/data/models/exercise.dart`. It includes the 366 exercise
names and default rep/time values visible in the supplied reference videos. These
are illustrative 2D exercise demonstrations, not an assertion of professionally
reviewed coaching form.

The application renders the avatar directly with Flutter. GIFs in
`build/exercise-previews` are optional review exports of the same original code,
not runtime dependencies. Drawing directly avoids bundling a duplicate bitmap
animation for each exercise. Loops respect reduced-motion preferences and app
backgrounding, and are isolated in repaint boundaries.

## Included exercises

1. Wall Push-ups
2. Punches
3. Side Arm Raise
4. Forward Arm Swings
5. Elbows Back
6. 90/90 Crunch
7. Abdominal Crunches
8. Arm Circles
9. Arm Raises
10. Adductor Stretch in Standing
11. Arm Circles Counterclockwise
12. Arm Scissors
13. Alt V-up
14. Arm Circles Clockwise
15. Alternating Hooks
16. Arm Curls Crunch Left
17. Arm Curls Crunch Right
18. Anterior Shoulder Stretch
19. Arnold Dumbbell Press
20. Alternating Dumbbell Shoulder Press
21. Alternate Hammer Curl
22. Arm Swings with Lateral Steps
23. Bicycle Crunches
24. Bird Dog
25. Bridge
26. Burpees
27. Backward Lunge with Front Kick Right
28. Backward Lunge with Front Kick Left
29. Butt Bridge
30. Box Push-ups
31. Bulgarian Split Squat Left
32. Bottom Leg Lift Right
33. Bottom Leg Lift Left
34. Bulgarian Split Squat Right
35. Backward Lunge
36. Backward Arm Swings
37. Butt Kicks
38. Bent Leg Twist
39. Bird Dog Left
40. Bird Dog Right
41. Bent Over Row
42. Back Bow Pulls
43. Backward Lunge (Timed)
44. Butt Bridge (Timed)
45. Bow Pose
46. Bent Over Dumbbell Rows Left
47. Bent Over Dumbbell Rows Right
48. Back Arches
49. Bent Knee Side Hip Raises Right
50. Bent Knee Side Hip Raises Left
51. Cobras
52. Cross Arm Crunches
53. Curtsy Lunges
54. Chest Press Pulse
55. Calf Raises
56. Crossover Crunch
57. Cross Touch and Reach
58. Cat Cow Pose
59. Chest Stretch
60. Child's Pose
61. Crab Kicks
62. Clapping Crunches
63. Claps Over Head
64. Cobra Stretch
65. Calf Stretch Left
66. Calf Stretch Right
67. Calf Raise with Splayed Foot
68. Calf Raise with Pigeon-toed
69. Crunches with Legs Raised
70. Cross Knee Plank
71. Clockwise Shoulder Rolls
72. Clasp Hands Behind Back
73. Crunch Kicks
74. Crab Kick Up
75. Crossbody Mountain Climber
76. Chair Triceps Side Bend Left
77. Chair Triceps Side Bend Right
78. Diamond Push-ups
79. Decline Push-ups
80. Donkey Kicks Right
81. Donkey Kicks Left
82. Diagonal Plank
83. Dynamic Chest
84. Dead Bug
85. Doorway Curls Left
86. Doorway Curls Right
87. Double Knees to Chest
88. Dumbbell Triceps Extension
89. Dumbbell Side Lateral Raise
90. Dumbbell Front Raise
91. Downward Facing Dog
92. Downward Facing Dog on the Wall
93. Dumbbell Upright-row
94. Dumbbell Concentration Curl Left
95. Dumbbell Concentration Curl Right
96. Dumbbell Kickbacks
97. Donkey Kicks Left Pulse
98. Donkey Kicks Right Pulse
99. Dumbbell Woodchop Left
100. Dumbbell Woodchop Right
101. Dumbbell V-up
102. Dumbbell Lying Triceps Extension
103. Dumbbell Punch
104. Dumbbell Shrug
105. Dumbbell Rear Delt Row
106. Dumbbell Single Arm Otis Up Left
107. Dumbbell Single Arm Otis Up Right
108. Elbow Plank Rotation Left
109. Froggy Glute Lifts
110. Floor Tricep Dips
111. Flutter Kicks
112. Forward Bend
113. Floor Y Raises
114. Frog Press
115. Floor Slides
116. Fast Spider Lunges
117. Flutter Kick Squats
118. Frog Pump
119. Forward Spine Stretch
120. Glute Kick Back
121. Glute Kick Back Left
122. Glute Kick Back Right
123. Glute Stretch Left
124. Glute Stretch Right
125. Glute Kickback Crossover with Left Leg
126. Glute Kickback Crossover with Right Leg
127. Glute Kickback Pulse Left
128. Glute Kickback Pulse Right
129. High Stepping
130. Hindu Push-ups
131. Hip Bridge & Leg Lift Left
132. Hip Bridge & Leg Lift Right
133. Heel Touch
134. Hops on the Spot
135. Hyperextension
136. Hover Push Up
137. Hip Hinge
138. Heels to the Heavens
139. Half Bending Pushing Forward
140. High Knee with Twist
141. Incline Push-ups
142. Inchworms
143. In & Outs
144. Jumping Jacks
145. Jumping Squats
146. Jumping Push-ups
147. Jumping Squats (Timed)
148. Knee Push-ups
149. Kneeling Lunge Stretch Left
150. Kneeling Lunge Stretch Right
151. Knee to Chest Stretch Left
152. Knee to Chest Stretch Right
153. Knee Circle
154. Knee to Elbow Crunches
155. Knee Plank
156. Kneeling Side Plank Left
157. Kneeling Side Plank Right
158. Leg Raises
159. Long Arm Crunches
160. Lunges
161. Left Lunge Knee Hops
162. Lunge Twist
163. Leaning Stretcher Raises
164. Left Quad Stretch with Wall
165. Lying Butterfly Stretch
166. Lying Twist Stretch Left
167. Lying Twist Stretch Right
168. Leg Barbell Curl Left
169. Leg Barbell Curl Right
170. Lying Swing Legs Left
171. Lying Swing Legs Right
172. Leg Spreads
173. Lateral Plank Walk
174. Left Leg Lateral Raise
175. Left Side Lying Forward Leg Lift
176. Lying Knee Hug
177. Leg In & Outs
178. Lumbar Cat Cow
179. Mountain Climber
180. Modified Push-up Low Hold
181. Military Push Ups
182. Modified Burpees
183. Military Press
184. Mountain Climber Squat Thrust
185. Mountain Climber (Timed)
186. Modified Burpees (Timed)
187. One Leg Push-ups
188. Oblique V-ups Left
189. Oblique V-ups Right
190. Overhead Arm Clockwise Circles
191. Overhead Arm Counterclockwise Circles
192. Oblique Crossover Crunch Left
193. Oblique Crossover Crunch Right
194. Oblique Crunch Reach
195. Offset Push-ups
196. Plank
197. Push-ups
198. Push-up & Rotation
199. Plie Squats
200. Plank Taps
201. Plank Leg Up
202. Plank and Reach
203. Prone Triceps Push Ups
204. Pike Push Ups
205. Pilates Clamshell Right
206. Pilates Clamshell Left
207. Pistol Box Squat Left
208. Pistol Box Squat Right
209. Plank Jacks
210. Prone Flutter Kicks
211. Plank Hip Dips
212. Pigeon Pose Left
213. Pigeon Pose Right
214. Push Up Hold
215. Quick Feet
216. Quad Stretch
217. Reverse Crunches
218. Russian Twist
219. Right Lunge Knee Hops
220. Reverse Flutter Kicks
221. Reverse Push-ups
222. Roundhouse Squat Kicks
223. Reclined Oblique Twist
224. Reclined Rhomboid Squeezes
225. Rhomboid Pulls
226. Reverse Snow Angels
227. Right Quad Stretch with Wall
228. Reverse Crunches with Leg Raised
229. Reverse Flys
230. Reverse Plank
231. Right Leg Lateral Raise
232. Right Side Lying Forward Leg Lift
233. Runner's Lunge Left
234. Runner's Lunge Right
235. Sit-ups
236. Straight-arm Plank
237. Step-up onto Chair
238. Squats
239. Side Lunges
240. Side Plank Right
241. Split Squat Right
242. Split Squat Left
243. Side Plank Left
244. Staggered Push-ups
245. Spiderman Push-ups
246. Standing Glute Kickbacks
247. Sumo Squat Calf Raises
248. Sumo Squat & Leg Raises
249. Side-lying Leg Lift Right
250. Single Right Leg Calf Raises
251. Single Left Leg Calf Raises
252. Side Leg Circles Left
253. Scissors
254. Side-lying Leg Lift Left
255. Side Leg Circles Right
256. Skater Jump
257. Side Hop
258. Superman
259. Shoulder Shrugs
260. Shoulder Stretch
261. Side Plank Front Kick Left
262. Side Plank Front Kick Right
263. Single Leg Hip Rotation
264. Squat Kicks
265. Standing Bicycle Crunches
266. Swimmer and Superman
267. Side Leg Raise Left
268. Side Leg Raise Right
269. Side Bridges Left
270. Side Bridges Right
271. Side-lying Floor Stretch Left
272. Side-lying Floor Stretch Right
273. Supine Push Up
274. Spine Lumbar Twist Stretch Right
275. Spine Lumbar Twist Stretch Left
276. Single Leg Calf Hop Left
277. Single Leg Calf Hop Right
278. Sumo Squat Calf Raises with Wall
279. Sumo Squat
280. Side Crunches Left
281. Side Crunches Right
282. Standing Side Bend
283. Sit-up Twist
284. Standing Glute Kickbacks Left
285. Standing Glute Kickbacks Right
286. Shoulder Gators
287. Standing Biceps Stretch Left
288. Standing Biceps Stretch Right
289. Skipping without Rope
290. Star Crawl
291. Shoulder Outward Rotation
292. Seated Side Bend Right
293. Seated Side Bend Left
294. Seated Spinal Twist Right
295. Seated Spinal Twist Left
296. Straight Leg Bounds
297. Standing Knee to Chest
298. Sitting Hamstring Stretch Left
299. Sitting Hamstring Stretch Right
300. Seated Butterfly Stretch
301. Squat Reach Ups
302. Star Jumps
303. Squat Pulses
304. Squat Jacks
305. Supine Hamstring Stretch Left
306. Supine Hamstring Stretch Right
307. Side Lunges (Timed)
308. Swimmer and Superman (Timed)
309. Straight Leg Raise Left
310. Straight Leg Raise Right
311. Spiderman Plank
312. Straight Arm Knee Plank
313. Side Lying Kickback Left
314. Side Lying Kickback Right
315. Standing Hip Circle
316. Spiderman Plank (Timed)
317. Single Leg Deadlift Left
318. Single Leg Deadlift Right
319. Side Plank Knee Crunch Left
320. Side Plank Knee Crunch Right
321. Starfish Crunch
322. Slow Mountain Climber
323. Single Leg Drops
324. Standing Crossover Toe Touches
325. Standing Oblique Crunches Left
326. Standing Oblique Crunches Right
327. Side Step Jacks
328. Single Arm Renegade Row Left
329. Single Arm Renegade Row Right
330. Straight Arm Plank to Pike
331. Seated Cat Cow
332. Triceps Dips
333. Toy Soldiers
334. Torso Twist
335. Trunk Rotation
336. Triceps Kickbacks
337. Triceps Stretch Left
338. Triceps Stretch Right
339. Triangle Pose Left
340. Triangle Pose Right
341. Toy Soldiers (Timed)
342. T Plank Left
343. T Plank Right
344. Twisting Piston
345. Thread the Needle Left
346. Thread the Needle Right
347. Up and Down Plank
348. V Crunch
349. V-up
350. V-hold
351. Wide Arm Push-ups
352. Wall Sit
353. Wall Calf Raises
354. Wall Resisting Single Leg Calf Raise Left
355. Wall Resisting Single Leg Calf Raise Right
356. Windshield Wipers
357. Wrists & Ankles Stretch Left
358. Wrists & Ankles Stretch Right
359. Wall Standing Glute Kickbacks Left
360. Wall Standing Glute Kickbacks Right
361. Walking Squats
362. Wall Glute Kickback Left Hold
363. Wall Glute Kickback Right Hold
364. Walk the Dog
365. X Man Crunch
366. X-Burpees

## Included workout flow

Create a named workout with difficulty; search/filter exercises; preview and
select exercises; edit repetitions, time, and rest; reorder or remove entries;
save and reopen workouts. Duplicate exercise entries are supported. Pending
changes prompt before being discarded. The actual available catalog count is
shown. Corrupt saved data is not silently replaced by a new save.

The persistent schema is versioned JSON under `custom_workouts_v1`, implemented by
`lib/data/repositories/custom_workout_repository.dart`. Exercise entries have
separate IDs so repeated exercises preserve their order and individual targets.

A timed session player and completed-session history remain a separate stage.
This implementation does not show a fake Start or completion action.

## Review exports

On the current Windows development environment:

```
flutter test --dart-define=EXPORT_EXERCISE_PREVIEWS=true test/custom_workout_test.dart
python tool/export_exercise_previews.py
```

The export-only tests load local review fonts; normal tests do not depend on
those font files. Pillow is needed only for assembling GIF previews. No new
runtime package was added for the exercise animations.

The second October 17 video adds 21 variants. Rep-based and timed Backward Lunge and Butt Bridge entries have separate stable IDs. Equipment requirements appear in preview descriptions. All added artwork and motion remain code-drawn originals.

The next October 19 video adds 31 entries; Elbows Back reuses its existing catalog entry. Equipment requirements are included in the exercise descriptions.

The 1:33 PM October 19 video adds 32 exercises. Forward Arm Swings reuses its existing entry. Glute kickback pulses use repetitions; donkey-kick pulses retain their separate timed defaults.

Preview exports can render only a new catalog suffix with `--dart-define=EXPORT_EXERCISE_START=108`. Normal avatar tests still paint every exercise. Existing frame exports must be present before assembling the complete preview grid.

The 1:33:50 PM October 19 video adds 41 entries, including distinct rep-based and timed Jumping Squats. These original drawings are illustrative and preserve the existing saved exercise IDs.

To review only the latest 41 entries, render with `--dart-define=EXPORT_EXERCISE_START=140`, then run `python tool/export_exercise_previews.py --start-index 140 --prefix i-to-m`. This creates a smaller batch preview while preserving earlier review exports.

The 1:34:15 PM October 19 video adds 41 entries. Punches reuses its existing ID. Timed Mountain Climber and Modified Burpees have distinct IDs from their rep-based entries.

Latest batch previews: render with `--dart-define=EXPORT_EXERCISE_START=181`, then run `python tool/export_exercise_previews.py --start-index 181 --prefix m-to-r`.

The 1:35:10 PM October 19 video adds 81 entries and reuses Side Arm Raise. The next video confirms the Squat Pulses target is 20 seconds.

Latest R/S batch preview: render with `--dart-define=EXPORT_EXERCISE_START=222`, then run `python tool/export_exercise_previews.py --start-index 222 --prefix r-and-s`.

The 1:35:45 PM October 19 video adds 50 entries. Squat Pulses and Wall Push-ups reuse existing entries. Timed Side Lunges, Swimmer and Superman, Spiderman Plank, and Toy Soldiers have separate stable IDs.

Latest S-to-W batch preview: render with `--dart-define=EXPORT_EXERCISE_START=303`, then run `python tool/export_exercise_previews.py --start-index 303 --prefix s-to-w`. Slow Mountain Climber uses a 5.2-second loop, twice the normal 2.6-second animation period; individual GIF previews preserve that timing.

The 1:36:01 PM October 19 video adds 13 entries. Both Wall Glute Kickback Hold entries retain the reference x10 rep target. Preview with `--dart-define=EXPORT_EXERCISE_START=353`, then `python tool/export_exercise_previews.py --start-index 353 --prefix w-and-x`.
