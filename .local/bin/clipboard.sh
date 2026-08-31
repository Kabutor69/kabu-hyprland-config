#!/bin/bash

CACHE_DIR="$HOME/.cache/cliphist_previews"
mkdir -p "$CACHE_DIR"

case "$1" in
    "preview")
        ITEM_ID="$2"
        OUT_FILE="$CACHE_DIR/${ITEM_ID}.png"
        
        if [ ! -s "$OUT_FILE" ]; then
            cliphist decode "$ITEM_ID" > "$OUT_FILE" 2>/dev/null
        fi
        
        if [ -s "$OUT_FILE" ]; then
            echo -n "$OUT_FILE"
        else
            rm -f "$OUT_FILE"
            echo -n ""
        fi
        ;;
    "clear")
        rm -rf "$CACHE_DIR"/*
        rm -f ~/.cache/cliphist/db
        cliphist wipe
        notify-send -a "Clipboard" "History cleared"
        ;;
    "delete")
        ITEM_ID="$2"
        rm -f "$CACHE_DIR/${ITEM_ID}.png"
        echo "$ITEM_ID" | cliphist delete
        notify-send -a "Clipboard" "Item deleted"
        ;;
    "copy")
        ITEM_ID="$2"
        cliphist decode "$ITEM_ID" | wl-copy
        notify-send -a "Clipboard" "Copied to clipboard"
        ;;
    *)
        cliphist list
        ;;
esac
