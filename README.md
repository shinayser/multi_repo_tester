A repo tester for multi modules Flutter app.

---
# Compiling

To compile this project you must execute:

`dart compile exe multi_repo_tester.dart`

The "exe" parameter refers to a self contained binary, this is not related to Windows 'exe' files.

# Usage

Place the compiled executable in the root of your multi-repo Flutter project. The execute it via command line passing the prefix of your packages as a parameter, like:

`.\multi_repo_tester.exe -p my_app_prefix`

