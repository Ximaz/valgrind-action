# Valgrind Checker Action

A GitHub action allowing you to check for memory leaks on your binaries, libraries and unit tests.

# Usage

Here is how you may use the action :

```yml
name: Valgrind Tester

on:
    - push

jobs:
    check-memory-leaks:
        runs-on: ubuntu-latest
        steps:
            -   name: "Checkout"
                uses: actions/checkout@v4.1.4

            -   name: "Compile program"
                run: gcc -g src/*.c -o program

            -   name: "Valgrind Checks"
                uses: Ximaz/valgrind-action
                with:
                    binary_path: "./program"
                    binary_args: "--arg1 value1 --arg2 value2"
```

# Customization

`binary_args`: The args to pass to the binary when checked (string format)

`ld_library_path`: Custom library path (for dymanic locally-compiled libraries)

`track_file_descriptors`: Whether or not to track file descriptors (default: `true`)

`treat_error_as_warning`: The workflow won't exit as error, and error annotations will be replaced by warnings (default: `false`)

`valgrind_suppressions`: String containing Valgrind suppressions (will be put inside a suppressions file)

`verbose`: Asking Valgrind to be verbose (default: `false`)
