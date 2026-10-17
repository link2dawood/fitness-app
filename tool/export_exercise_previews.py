"""Assemble review GIFs from this project's original Flutter avatar frames.

First run:
  flutter test --dart-define=EXPORT_EXERCISE_PREVIEWS=true test/custom_workout_test.dart
Then run this script with a Python environment containing Pillow.
"""
from pathlib import Path
from math import ceil
from textwrap import wrap
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent / 'build' / 'exercise-previews'
EXERCISES = [
    ('wall_push_ups', 'Wall Push-ups'), ('punches', 'Punches'),
    ('side_arm_raise', 'Side Arm Raise'), ('forward_arm_swings', 'Forward Arm Swings'),
    ('elbows_back', 'Elbows Back'), ('90_90_crunch', '90/90 Crunch'),
    ('abdominal_crunches', 'Abdominal Crunches'), ('arm_circles', 'Arm Circles'),
    ('arm_raises', 'Arm Raises'), ('adductor_stretch_standing', 'Standing Adductor Stretch'),
    ('arm_circles_counterclockwise', 'Arm Circles Counterclockwise'),
    ('arm_scissors', 'Arm Scissors'),
    ('alt_v_up', 'Alt V-up'),
    ('arm_circles_clockwise', 'Arm Circles Clockwise'),
    ('alternating_hooks', 'Alternating Hooks'),
    ('arm_curls_crunch_left', 'Arm Curls Crunch Left'),
    ('arm_curls_crunch_right', 'Arm Curls Crunch Right'),
    ('anterior_shoulder_stretch', 'Anterior Shoulder Stretch'),
    ('arnold_dumbbell_press', 'Arnold Dumbbell Press'),
    ('alternating_dumbbell_shoulder_press', 'Alternating Dumbbell Shoulder Press'),
    ('alternate_hammer_curl', 'Alternate Hammer Curl'),
    ('arm_swings_lateral_steps', 'Arm Swings with Lateral Steps'),
    ('bicycle_crunches', 'Bicycle Crunches'),
    ('bird_dog', 'Bird Dog'),
    ('bridge', 'Bridge'),
    ('burpees', 'Burpees'),
    ('backward_lunge_front_kick_right', 'Backward Lunge with Front Kick Right'),
    ('backward_lunge_front_kick_left', 'Backward Lunge with Front Kick Left'),
    ('butt_bridge', 'Butt Bridge'),
    ('box_push_ups', 'Box Push-ups'),
    ('bulgarian_split_squat_left', 'Bulgarian Split Squat Left'),
    ('bottom_leg_lift_right', 'Bottom Leg Lift Right'),
    ('bottom_leg_lift_left', 'Bottom Leg Lift Left'),
    ('bulgarian_split_squat_right', 'Bulgarian Split Squat Right'),
    ('backward_lunge', 'Backward Lunge'),
    ('backward_arm_swings', 'Backward Arm Swings'),
    ('butt_kicks', 'Butt Kicks'),
    ('bent_leg_twist', 'Bent Leg Twist'),
    ('bird_dog_left', 'Bird Dog Left'),
    ('bird_dog_right', 'Bird Dog Right'),
    ('bent_over_row', 'Bent Over Row'),
    ('back_bow_pulls', 'Back Bow Pulls'),
    ('backward_lunge_timed', 'Backward Lunge (Timed)'),
    ('butt_bridge_timed', 'Butt Bridge (Timed)'),
    ('bow_pose', 'Bow Pose'),
    ('bent_over_dumbbell_rows_left', 'Bent Over Dumbbell Rows Left'),
    ('bent_over_dumbbell_rows_right', 'Bent Over Dumbbell Rows Right'),
    ('back_arches', 'Back Arches'),
]
try:
    FONT = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 18)
except OSError:
    FONT = ImageFont.load_default()


def frame_image(key, frame):
    with Image.open(ROOT / key / f'{frame:02}.png') as source:
        image = source.convert('RGBA')
        background = Image.new('RGBA', image.size, 'white')
        return Image.alpha_composite(background, image).convert('RGB')


frames = []
for frame in range(24):
    sheet = Image.new('RGB', (1280, ceil(len(EXERCISES) / 4) * 384), 'white')
    draw = ImageDraw.Draw(sheet)
    for index, (key, label) in enumerate(EXERCISES):
        x, y = (index % 4) * 320, (index // 4) * 384
        image = frame_image(key, frame)
        sheet.paste(image, (x, y + 56))
        image.close()
        draw.multiline_text((x + 12, y + 8), '\n'.join(wrap(label, 29)), fill='#253541', font=FONT, spacing=2)
    frames.append(sheet)
frames[6].save(ROOT / 'catalog-preview.png')
frames[0].save(ROOT / 'original-exercise-animations.gif', save_all=True,
               append_images=frames[1:], duration=108, loop=0, optimize=True)
for key, _ in EXERCISES:
    images = [frame_image(key, frame) for frame in range(24)]
    images[0].save(ROOT / f'{key}.gif', save_all=True, append_images=images[1:],
                   duration=108, loop=0, optimize=True)
    for image in images:
        image.close()
print(f'Exported {len(EXERCISES)} original exercise GIF previews to {ROOT}')
