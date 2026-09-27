#!/bin/bash
# Escapes text for Telegram HTML: & < > only, which is all Telegram requires.
# Use it on anything a person typed (commit messages, PR titles, branch names).
printf '%s' "${1-}" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
