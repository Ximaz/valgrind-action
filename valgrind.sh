#!/usr/bin/env bash
# set -xeu

prepare_valgrind_flags() {
    local SUPPRESSIONS_FILE="valgrind.supp"

    echo "--leak-check=full"
    echo "--track-origins=yes"
    echo "--read-var-info=yes"
    echo "--trace-children=yes"
    echo "--show-leak-kinds=all"
    echo "--read-inline-info=yes"
    echo "--errors-for-leak-kinds=all"
    echo "--expensive-definedness-checks=yes"
    echo "--gen-suppressions=all"
    [[ "${INPUT_TRACK_FILE_DESCRIPTORS}" == "true" ]] && echo "--track-fds=yes"
    [[ "${INPUT_VERBOSE}" == "true" ]] && echo "--verbose"
    if [[ "${INPUT_VALGRIND_SUPPRESSIONS}" != "" ]]; then
        echo "${INPUT_VALGRIND_SUPPRESSIONS}" > "${SUPPRESSIONS_FILE}"
        echo "--suppressions=${SUPPRESSIONS_FILE}"
    fi
}

match_pattern() {
    if [[ $(echo "${1}" | grep "${2}") != "" ]]; then
        echo "1"
    else
        echo "0"
    fi
}

skip_criterion_pipe_leaks() {
    # Reason of this skip: https://github.com/Snaipe/Criterion/issues/533
    if [[ $(echo "${1}" | grep '^==.*==    by 0x.*: stdpipe_options (in /usr/local/lib/libcriterion.so.3.2.0)') == "" &&
          $(echo "${1}" | grep '^==.*== Open file descriptor .*: /dev/shm/bxf_arena_.* (deleted)') == "" ]]; then
        echo "1"
    else
        echo "0"
    fi
}

parse_valgrind_reports() {
    local VALGRIND_REPORTS="${1}"
    local report_id=1
    local status=0
    local error=""
    local kind="error"

    if [[ "${INPUT_TREAT_ERROR_AS_WARNING}" == "true" ]]; then
        kind="warning"
    fi
    while IFS= read -r line; do
        if [[ "${error}" != "" ]]; then
            if [[ $(echo "${line}" | grep '^==.*== $') && $(skip_criterion_pipe_leaks "${error}") == "1" ]]; then
                echo "::${kind} title=Valgrind Report '${INPUT_BINARY_PATH}' (${report_id})::${error}"
                report_id=$(( $report_id + 1 ))
                error=""
                status=1
            else
                error="${error}%0A${line}"
            fi
        fi
        if [[ $(echo "${line}" | grep '^==.*== .* bytes in .* blocks are definitely lost in loss record .* of .*$') ]]; then
            error="${line}"
        elif [[ $(echo "${line}" | grep '^==.*== .* bytes in .* blocks are still reachable in loss record .* of .*$') ]]; then
            error="${line}"
        elif [[ $(echo "${line}" | grep '^==.*== Invalid .* of size .*$') ]]; then
            error="${line}"
        elif [[ $(echo "${line}" | grep '^==.*== Open file descriptor .*: .*$') ]]; then
            error="${line}"
        elif [[ $(echo "${line}" | grep '^==.*== Invalid free().*$') ]]; then
            error="${line}"
        elif [[ $(echo "${line}" | grep '^==.*== Mismatched free() / delete / delete \[\].*$') ]]; then
            error="${line}"
        elif [[ $(echo "${line}" | grep '^==.*== Syscall param .* points to uninitialised byte(s).*$') ]]; then
            error="${line}"
        elif [[ $(echo "${line}" | grep '^==.*== Source and destination overlap in .*$') ]]; then
            error="${line}"
        elif [[ $(echo "${line}" | grep '^==.*== Argument .* of function .* has a fishy (possibly negative) value: .*$') ]]; then
            error="${line}"
        elif [[ $(echo "${line}" | grep '^==.*== .*alloc() with size 0$') ]]; then
            error="${line}"
        elif [[ $(echo "${line}" | grep '^==.*== Invalid alignment value: .* (should be power of 2)$') ]]; then
            error="${line}"
        fi
    done < "${VALGRIND_REPORTS}"
    rm -f "${VALGRIND_REPORTS}"
    if [[ "${kind}" == "warning" ]]; then
        exit 0
    fi
    exit "${status}"
}

main() {
    local VALGRIND_REPORTS="valgrind-reports.log"
    local VALGRIND_FLAGS=$(prepare_valgrind_flags)

    if [[ "${INPUT_LD_LIBRARY_PATH}" == "" ]]; then
        export LD_LIBRARY_PATH="${INPUT_LD_LIBRARY_PATH}"
    fi
    valgrind $VALGRIND_FLAGS "${INPUT_BINARY_PATH}" $INPUT_BINARY_ARGS 2>"${VALGRIND_REPORTS}"
    parse_valgrind_reports "${VALGRIND_REPORTS}"
}

main
