import os
import shutil
import sys

def main():
    dist_dir = 'dist/NCPD_Tracker'

    if os.path.exists(dist_dir):
        shutil.rmtree(dist_dir)

    os.makedirs(os.path.join(dist_dir, 'modules'), exist_ok=True)
    os.makedirs(os.path.join(dist_dir, 'data'), exist_ok=True)

    try:
        shutil.copy('mod/init.lua', dist_dir)

        for file in os.listdir('mod/modules'):
            if file.endswith('.lua'):
                shutil.copy(os.path.join('mod/modules', file), os.path.join(dist_dir, 'modules'))

        shutil.copy('data/ncpd.json', os.path.join(dist_dir, 'data'))

        # Verification
        expected_files = [
            'init.lua',
            'modules/database.lua',
            'modules/logger.lua',
            'modules/mappins.lua',
            'modules/quest_state.lua',
            'modules/tracker.lua',
            'modules/ui.lua',
            'data/ncpd.json'
        ]

        missing = []
        for file in expected_files:
            if not os.path.exists(os.path.join(dist_dir, file)):
                missing.append(file)

        if missing:
            print(f"Build failed! Missing files in dist: {missing}")
            sys.exit(1)

        print("Build successful! dist/NCPD_Tracker is ready for installation.")
        sys.exit(0)

    except Exception as e:
        print(f"Build failed with error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
