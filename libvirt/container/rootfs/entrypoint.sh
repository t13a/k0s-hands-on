#!/bin/sh

set -eu

for file in /entrypoint.d/*
do
    case "${file}" in
        *.aug)
            echo "Loading ${file}" >&2
            augtool -sf "${file}"
            ;;
        *.sh)
            echo "Executing ${file}" >&2
            "${file}"
            ;;
    esac
done

echo "Executing ${@}" >&2
exec "${@}"
