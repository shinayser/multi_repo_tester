A repo tester for multi modules Flutter app.

---
# Compiling

To compile this project you must execute:

`dart compile exe bin/multi_repo_tester.dart -o multi_repo_tester.exe`

This command will generate a "exe" on the root of the project.The "exe" parameter refers to a self contained binary, this is not related to Windows 'exe' files.

## Options
* `--fvm` or `-f`, set this flag if your use FVM (Flutter version Manager) to test your stuff.

# Usage

Place the compiled executable in the root of your multi-repo Flutter project. The execute it via command line passing the prefix of your packages as a parameter, like:

`.\multi_repo_tester.exe -p my_app_prefix`

