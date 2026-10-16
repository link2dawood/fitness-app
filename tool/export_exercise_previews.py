"""Assemble review GIFs from this project's original Flutter avatar frames.

First run:
  flutter test --dart-define=EXPORT_EXERCISE_PREVIEWS=true test/custom_workout_test.dart
Then run this script with a Python environment containing Pillow.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent / 'build' / 'exercise-previews'
EXERCISES = [
    ('wall_push_ups', 'Wall Push-ups'), ('punches', 'Punches'),
    ('side_arm_raise', 'Side Arm Raise'), ('forward_arm_swings', 'Forward Arm Swings'),
    ('elbows_back', 'Elbows Back'), ('90_90_crunch', '90/90 Crunch'),
    ('abdominal_crunches', 'Abdominal Crunches'), ('arm_circles', 'Arm Circles'),
    ('arm_raises', 'Arm Raises'), ('adductor_stretch_standing', 'Standing Adductor Stretch'),
    ('arm_circles_counterclockwise', 'Arm Circles Counterclockwise'),
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
    sheet = Image.new('RGB', (1280, 1080), 'white')
    draw = ImageDraw.Draw(sheet)
    for index, (key, label) in enumerate(EXERCISES):
        x, y = (index % 4) * 320, (index // 4) * 360
        image = frame_image(key, frame)
        sheet.paste(image, (x, y + 32))
        image.close()
        draw.text((x + 12, y + 8), label, fill='#253541', font=FONT)
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
